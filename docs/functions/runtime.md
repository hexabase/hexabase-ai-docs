# Function Runtime Environment

When you deploy a function to Hexabase.AI, it runs in a managed, secure, and isolated environment. Understanding this runtime environment is key to developing reliable and performant functions.

## The Execution Environment

Each function runs inside a lightweight, isolated container based on [gVisor](https://gvisor.dev/), which provides a secure sandbox with a private filesystem and network stack. This "sandbox" approach ensures that one function cannot interfere with another, even if they are running on the same underlying node.

The base OS for the runtime container is a minimal, hardened Linux distribution.

## Lifecycle of a Function Invocation

1.  **Request**: An HTTP request arrives at the Function Gateway for a specific function endpoint.
2.  **Cold Start (if necessary)**: If there are no idle instances of your function's container available, the FaaS system performs a "cold start":
    - A new sandboxed container is created.
    - Your function's code and its dependencies are loaded into memory.
    - Your function's initialization code (any code outside the main `handler`) is run.
3.  **Warm Start**: If an idle "warm" container is available from a previous invocation, it is immediately used, skipping the cold start steps.
4.  **Invocation**: The FaaS system invokes your `handler` function, passing it the `event` and `context` objects.
5.  **Response**: Your function returns a response dictionary.
6.  **Shutdown**: The FaaS system serializes your response and sends it back to the client. The container is then either frozen (to keep it warm for a subsequent request) or terminated.

**Note**: Cold starts typically take a few hundred milliseconds, while warm starts are near-instantaneous. The system is optimized to keep frequently used functions warm.

## Resource Limits

The runtime environment imposes the following limits, which can be configured in your `function.yaml`:

- **Memory**: The maximum amount of memory your function can use. If it exceeds this limit, its process will be terminated.
  - _Default_: `128Mi`
  - _Max_: `2Gi`
- **Timeout**: The maximum execution time for your function. If it runs longer than this, the invocation will be terminated, and a `504 Gateway Timeout` error will be returned.
  - _Default_: `30s`
  - _Max_: `900s` (15 minutes)
- **CPU**: CPU is not a hard limit but is allocated proportionally to the memory setting. A function with more memory will receive more CPU time.

## Filesystem Access

- **Read-Only Code**: Your function's code and its dependencies are mounted into the container in a read-only directory. You cannot modify your code at runtime.
- **Temporary Writable Directory**: Each function container has access to a writable `/tmp` directory with a limited size (e.g., 512 MB). This directory is non-persistent; its contents are lost after the function invocation ends. It should only be used for temporary, intermediate file storage during a single execution.

## Environment Variables

The runtime environment exposes several standard environment variables.

### Standard Variables

| Variable            | Description                                               |
| :------------------ | :-------------------------------------------------------- |
| `AWS_REGION`        | The AWS region where the function is executing.           |
| `AWS_EXECUTION_ENV` | Identifies the runtime, e.g., `AWS_Lambda_python3.9`.     |
| `_HANDLER`          | The name of your handler function (e.g., `main.handler`). |

### HKS-Specific Variables

| Variable                      | Description                                                                            |
| :---------------------------- | :------------------------------------------------------------------------------------- |
| `HKS_FUNCTION_NAME`           | The name of your function.                                                             |
| `HKS_FUNCTION_VERSION`        | The deployed version of your function.                                                 |
| `HKS_WORKSPACE_NAME`          | The name of the workspace the function belongs to.                                     |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | The endpoint for the OpenTelemetry collector, used for manual tracing instrumentation. |

Additionally, any environment variables or secrets you define in your `function.yaml` will be available to your function's process.

## Networking

- **Outbound Connectivity**: By default, functions have access to the public internet. You can use this to make API calls to third-party services.
- **Private Networking (Enterprise Plan)**: For functions that need to access resources in a private VPC (like a database), you can configure them to attach to a specific VPC. This will route their outbound traffic through that VPC, but it may increase cold start times.
- **No Inbound Connectivity**: Functions cannot receive inbound traffic on arbitrary ports. All communication must come through the main HTTP invocation.
