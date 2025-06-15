# Python SDK

The Hexabase.AI Python SDK provides a convenient way to interact with the HKS API from your Python applications. It is the same SDK used by AI Agent Functions, giving you access to the full power of the platform.

## Installation

```bash
pip install hks-sdk
```

## Authentication

### From an HKS Environment (e.g., an Agent Function)

When running within a managed HKS environment, the SDK is automatically authenticated. The `hks` client is pre-configured and available for import.

```python
from hks_sdk import hks

# The 'hks' object is already authenticated and ready to use.
workspaces = hks.platform.workspaces.list()
print(f"Found {len(workspaces)} workspaces.")
```

### From an External Environment

When running outside of HKS (e.g., on a local machine or in a custom application), you must configure the client with an API key from a Service Account.

```python
from hks_sdk import HKSClient

# Best practice: Load the API key from an environment variable.
import os
api_key = os.environ.get("HKS_API_KEY")

if not api_key:
    raise ValueError("HKS_API_KEY environment variable not set.")

# You may also need to specify the HKS API endpoint if it's not the default.
# endpoint = "https://api.my-hks-instance.com"
# hks = HKSClient(api_key=api_key, endpoint=endpoint)

hks = HKSClient(api_key=api_key)

# Now you can use the client
deployments = hks.apps.deployments.list(workspace="my-production-space")
print(f"Found {len(deployments)} deployments.")
```

## Usage and Examples

The SDK is organized into modules that mirror the HKS API structure.

### Listing Resources

Most resources can be listed. You typically need to provide a `workspace` name.

```python
# List all pods in a workspace
pods = hks.apps.pods.list(workspace="production")
for pod in pods:
    print(f"Pod: {pod.name}, Status: {pod.status}, IP: {pod.ip}")

# List all serverless functions
functions = hks.functions.list(workspace="development")
```

### Getting a Specific Resource

You can retrieve a single resource by its name.

```python
# Get a specific deployment
try:
    deployment = hks.apps.deployments.get(workspace="production", name="my-frontend-app")
    print(f"Deployment '{deployment.name}' has {deployment.spec.replicas} replicas.")
except Exception as e:
    print(f"Could not find deployment: {e}")
```

### Creating Resources

You can create resources by providing a dictionary or a dataclass object that defines the resource spec.

```python
from hks_sdk.spec.apps import DeploymentSpec, ContainerSpec

# Define a new deployment
new_deployment_spec = DeploymentSpec(
    name="my-sdk-app",
    replicas=2,
    containers=[
        ContainerSpec(
            name="web",
            image="nginx:latest",
            ports=[{"containerPort": 80}]
        )
    ]
)

# Create the deployment in the 'development' workspace
created_deployment = hks.apps.deployments.create(
    workspace="development",
    spec=new_deployment_spec
)

print(f"Successfully created deployment '{created_deployment.name}'.")
```

### Updating Resources

To update a resource, you typically `get` it first, modify its spec, and then call the `update` method.

```python
# Scale a deployment up to 3 replicas
deployment = hks.apps.deployments.get(workspace="development", name="my-sdk-app")
deployment.spec.replicas = 3

updated_deployment = hks.apps.deployments.update(
    workspace="development",
    name=deployment.name,
    spec=deployment.spec
)

print(f"Scaled deployment to {updated_deployment.spec.replicas} replicas.")
```

### Deleting Resources

```python
# Delete the deployment
hks.apps.deployments.delete(workspace="development", name="my-sdk-app")
print("Deployment deleted.")
```

### AIOps LLM Integration

The SDK provides a simple interface to the secure LLM gateway.

```python
from hks_sdk import llm

prompt = "Translate the following English text to French: 'Hello, World!'"

# The LLM model used (e.g., GPT-4, Claude 3) is configured
# at the workspace level for security and governance.
response = llm.invoke(prompt, workspace="development")

print(f"LLM Response: {response}")
```

This interface handles data sanitization and secure credential management automatically.

This Python SDK enables you to build powerful automations, custom controllers, and AI-driven agents on top of the Hexabase.AI platform.
