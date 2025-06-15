# AI Agent Functions

A unique and powerful feature of the Hexabase.AI platform is the ability to create **AI Agent Functions**. These are specialized HKS Functions that are designed to be invoked by the AIOps engine or to act as autonomous agents within your environment.

## What is an AI Agent Function?

An AI Agent Function is a serverless function that can:

- Be triggered by system events, alerts, or other AIOps signals.
- Interact with the HKS and Kubernetes APIs to observe and act upon the environment.
- Leverage a secure sandbox with built-in access to Large Language Models (LLMs).
- Execute complex, multi-step logic to perform autonomous tasks.

This enables you to create powerful, custom automations and "self-healing" workflows that go far beyond simple webhooks.

## Use Cases

- **Automated Diagnostics**: When an alert fires, an agent function can automatically run a series of diagnostic commands (`describe pod`, fetch logs, check metrics) and post a rich summary to Slack.
- **Cost-Optimization Agent**: A scheduled agent function can run daily, scan for under-utilized resources (like idle deployments or oversized PVCs), and suggest cost-saving actions.
- **Security Response Agent**: When a security vulnerability is detected, an agent can automatically check if the affected image is running in production, create a Jira ticket, and notify the relevant team.
- **Custom ChatOps Bot**: Create a chatbot that listens for commands in Slack (e.g., `@hks-bot deploy my-app to staging`) and uses an agent function to safely execute the requested action after performing validation checks.

## Developing an Agent Function

Developing an agent function is similar to developing a standard HKS Function, but with a few key differences.

### 1. The HKS SDK

The primary difference is the use of the **HKS SDK**, which is automatically available in the agent runtime. This SDK provides pre-authenticated clients for interacting with platform services.

**Python Agent Example:**

```python
# main.py
from hks_sdk import hks, llm

def handler(event, context):
    """
    This agent is triggered by an 'HighLatency' alert.
    The event payload contains details about the alert.
    """

    # --- 1. Observe ---
    # Get details from the alert payload
    app_name = event["alert"]["labels"]["app"]
    workspace = event["alert"]["labels"]["workspace"]

    # Use the SDK to get the pods for the affected application
    pods = hks.apps.pods.list(workspace=workspace, selector=f"app={app_name}")

    if not pods:
        return {"status": "noop", "reason": "No pods found for app."}

    # --- 2. Orient & Decide ---
    # Use the LLM to summarize the pod logs and suggest a cause
    pod_logs = hks.apps.pods.logs(workspace=workspace, name=pods[0].name, tail=100)

    prompt = f"""
    The following logs are from a pod experiencing high latency.
    Summarize the potential root cause in one sentence.
    Logs: {pod_logs}
    """

    summary = llm.invoke(prompt) # Secure, sandboxed call to an LLM

    # --- 3. Act ---
    # Post the findings to a Slack channel
    message = f"*[High Latency Alert for {app_name}]*\n" \
              f"*AI Summary:* {summary}\n" \
              f"Found {len(pods)} pods. Check dashboard for full logs."

    hks.notifications.slack.post(channel="#ops-alerts", text=message)

    return {"status": "complete", "action_taken": "posted_summary_to_slack"}
```

### 2. The Trigger

Instead of a standard HTTP trigger, an agent function is typically triggered by an `AIOpsTrigger`.

```yaml
# function.yaml for an AI Agent
apiVersion: hks.io/v1
kind: Function
metadata:
  name: high-latency-diagnostics-agent
spec:
  runtime:
    name: python-agent # Use the special 'agent' runtime
    version: "3.9"
  handler: main.handler

  # Trigger the function when a specific alert fires
  trigger:
    type: aiops
    filter:
      # Corresponds to the name of an AlertRule
      alertName: "HighAPILatency"

  # Grant the function permission to read pods and logs
  permissions:
    - resources: ["pods", "pods/log"]
      verbs: ["get", "list"]
    - resources: ["notifications"]
      verbs: ["create"]
```

When the `HighAPILatency` alert fires, the AIOps engine will invoke this function and pass the full alert object as the `event` payload.

### 3. Permissions (RBAC for Functions)

Because agent functions can interact with the HKS API, they are subject to RBAC. The `permissions` section in the `function.yaml` grants the function a specific, short-lived set of permissions that it can use during its execution. This ensures that even if a function has a bug, its potential impact is limited to its stated permissions (Principle of Least Privilege).

## Secure LLM Integration

A key feature of the agent runtime is the sandboxed LLM client (`hks_sdk.llm`).

- **No API Keys Needed**: You do not need to manage or embed your own OpenAI or other LLM provider keys.
- **Data Sanitization**: The HKS platform acts as a proxy, automatically sanitizing data sent to the LLM to remove sensitive information like PII, credentials, and internal hostnames.
- **Model Choice**: You can configure which underlying model the agent uses (e.g., GPT-4, Claude 3, or a fine-tuned model) at the workspace level.

This provides a secure and easy way to add powerful AI reasoning capabilities to your automated workflows.
