# JavaScript/TypeScript SDK

The Hexabase.AI JavaScript/TypeScript SDK allows you to interact with the HKS API from your Node.js applications, frontend web applications, or any other JavaScript-based environment.

## Installation

```bash
npm install @hexabase/hks-sdk
```

The package includes TypeScript definitions for a fully typed experience.

## Authentication

### From an HKS Environment (e.g., an Agent Function)

When running within a managed HKS environment (like a Node.js-based AI Agent Function), the SDK is automatically authenticated.

```typescript
import { hks } from "@hexabase/hks-sdk";

async function main() {
  // The 'hks' object is already authenticated.
  const workspaces = await hks.platform.workspaces.list();
  console.log(`Found ${workspaces.length} workspaces.`);
}

main();
```

### From an External Environment

When running outside of HKS, you must configure the client with an API key from a Service Account.

```typescript
import { HKSClient } from "@hexabase/hks-sdk";

// Best practice: Load the API key from an environment variable.
const apiKey = process.env.HKS_API_KEY;

if (!apiKey) {
  throw new Error("HKS_API_KEY environment variable not set.");
}

const hks = new HKSClient({ apiKey });

// Now you can use the client
async function getDeployments() {
  const deployments = await hks.apps.deployments.list({
    workspace: "production",
  });
  console.log(`Found ${deployments.length} deployments.`);
}

getDeployments();
```

## Usage and Examples

The SDK uses `async/await` and is organized into modules that mirror the HKS API structure.

### Listing Resources

```typescript
// List all pods in a workspace
async function listPods() {
  const pods = await hks.apps.pods.list({ workspace: "production" });
  for (const pod of pods) {
    console.log(`Pod: ${pod.name}, Status: ${pod.status}`);
  }
}
```

### Getting a Specific Resource

```typescript
// Get a specific deployment
async function getDeployment() {
  try {
    const deployment = await hks.apps.deployments.get({
      workspace: "production",
      name: "my-frontend-app",
    });
    console.log(
      `Deployment '${deployment.name}' has ${deployment.spec.replicas} replicas.`
    );
  } catch (error) {
    console.error(`Could not find deployment: ${error.message}`);
  }
}
```

### Creating Resources

You can create resources by providing an object that matches the resource's specification type.

```typescript
import { DeploymentSpec, ContainerSpec } from "@hexabase/hks-sdk/spec/apps";

// Define a new deployment
const newDeploymentSpec: DeploymentSpec = {
  name: "my-sdk-app",
  replicas: 2,
  containers: [
    {
      name: "web",
      image: "nginx:latest",
      ports: [{ containerPort: 80 }],
    },
  ],
};

// Create the deployment
async function createDeployment() {
  const created = await hks.apps.deployments.create({
    workspace: "development",
    spec: newDeploymentSpec,
  });
  console.log(`Successfully created deployment '${created.name}'.`);
}
```

### Updating Resources

To update a resource, you typically `get` it first, modify its spec, and then call the `update` method.

```typescript
// Scale a deployment up to 3 replicas
async function scaleUp() {
  const deployment = await hks.apps.deployments.get({
    workspace: "development",
    name: "my-sdk-app",
  });

  deployment.spec.replicas = 3;

  const updated = await hks.apps.deployments.update({
    workspace: "development",
    name: deployment.name,
    spec: deployment.spec,
  });

  console.log(`Scaled deployment to ${updated.spec.replicas} replicas.`);
}
```

### Deleting Resources

```typescript
// Delete the deployment
async function deleteDeployment() {
  await hks.apps.deployments.delete({
    workspace: "development",
    name: "my-sdk-app",
  });
  console.log("Deployment deleted.");
}
```

### AIOps LLM Integration

The SDK provides a simple interface to the secure LLM gateway.

```typescript
import { llm } from "@hexabase/hks-sdk";

async function getTranslation() {
  const prompt =
    "Translate the following English text to French: 'Hello, World!'";

  // The LLM model used is configured at the workspace level.
  const response = await llm.invoke({ prompt, workspace: "development" });

  console.log(`LLM Response: ${response}`);
}
```

This interface handles data sanitization and secure credential management automatically, making it safe to use even in frontend applications (with appropriate RBAC).
