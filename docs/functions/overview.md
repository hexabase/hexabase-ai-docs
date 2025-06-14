# HKS Functions (Serverless Platform)

HKS Functions provides a managed Function-as-a-Service (FaaS) experience, enabling developers to deploy and run event-driven code without managing underlying infrastructure. This feature is built on top of **Knative**.

## Core Architecture

### Platform-Level Knative
- **Knative Serving** and **Knative Functions (`kn func`)** components are installed by platform administrators once on the **Host K3s Cluster**
- This forms the serverless backbone for all tenants

### Developer-Centric Experience (DevEx)
The primary interface for developers is a dedicated CLI tool:

- **`hks-func` CLI**: A wrapper around the standard `kn func` CLI
- Automates HKS authentication and context configuration
- Fetches the correct Kubeconfig for the target project

**Sample Workflow**:
```bash
$ hks login
$ hks project select my-serverless-project
$ hks-func create -l node my-function
# ... edit function code ...
$ hks-func deploy
```

### UI for Management
The HKS UI serves as a management and observability dashboard for deployed functions:
- View a list of all functions within a project
- See function status, invocation endpoints (URLs), and resource consumption
- Access real-time logs and performance metrics

## Function Invocation Patterns

### HTTP Trigger
- Knative automatically provides a public URL for every deployed function
- This is the primary way to invoke functions

### Scheduled Trigger
- Functions can be invoked on a schedule using the CronJob feature
- The CronJob runs a container with `curl` or similar tool to hit the function's HTTP endpoint at the scheduled time

## AI-Powered Dynamic Function Execution (Advanced)

This powerful capability allows AI agents to generate, deploy, and execute code on-the-fly in a secure sandbox.

### Execution Flow and Security Model

1. **Code Generation**: An AIOps agent generates a piece of code to perform a specific task

2. **Dynamic Deploy Request**: The agent calls a secure **Internal Operations API** on the HKS Control Plane (e.g., `POST /internal/v1/operations/deploy-function`), passing the code and the short-lived internal JWT

3. **Secure Build & Deploy**:
   - The HKS backend receives the request and uses a secure, isolated in-cluster builder (e.g., **Kaniko**) to build a temporary container image from the provided code
   - It then deploys this image as a new Knative Function to the user's vCluster
   - The function runs with a highly restricted, single-purpose Service Account

4. **Scoped Invocation**: The backend returns the function's internal URL to the agent. The agent invokes the function to get the result

5. **Automatic Cleanup**: After execution (or a timeout), the agent (or a garbage collector) calls another internal API (`delete-function`) to remove the temporary function and its associated resources

### Developer Tooling

- **HKS Internal SDK** (Python): Abstracts the entire flow
- AI agents can simply call methods like `hks_sdk.functions.execute(code="...")`
- The SDK handles the entire secure deploy-invoke-cleanup lifecycle
- Detailed documentation outlines capabilities and limitations (e.g., available libraries, resource quotas)