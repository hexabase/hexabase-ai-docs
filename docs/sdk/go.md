# Go SDK

The Hexabase.AI Go SDK provides a statically typed, compiled interface for interacting with the HKS API, making it ideal for building robust backend services, custom controllers, and high-performance automation tools.

## Installation

```bash
go get github.com/hexabase/hks-sdk-go
```

## Authentication

### From an HKS Environment (e.g., an Agent Function)

When running within a managed HKS environment, the SDK is automatically authenticated via environment variables.

```go
package main

import (
	"fmt"
	"github.com/hexabase/hks-sdk-go/client"
	"log"
)

func main() {
	// The client will automatically use credentials from the environment.
	hks, err := client.New()
	if err != nil {
		log.Fatalf("Failed to create HKS client: %v", err)
	}

	workspaces, err := hks.Platform.Workspaces.List()
	if err != nil {
		log.Fatalf("Failed to list workspaces: %v", err)
	}

	fmt.Printf("Found %d workspaces.\n", len(workspaces))
}
```

### From an External Environment

When running outside of HKS, you must configure the client with an API key from a Service Account.

```go
package main

import (
	"fmt"
	"github.com/hexabase/hks-sdk-go/client"
	"log"
	"os"
)

func main() {
	apiKey := os.Getenv("HKS_API_KEY")
	if apiKey == "" {
		log.Fatal("HKS_API_KEY environment variable not set.")
	}

	// You can also provide a custom endpoint URL.
	// opts := client.Options{APIKey: apiKey, Endpoint: "..."}
	// hks, err := client.New(opts)
	hks, err := client.New(client.WithAPIKey(apiKey))
	if err != nil {
		log.Fatalf("Failed to create HKS client: %v", err)
	}

	deployments, err := hks.Apps.Deployments.List("production")
	if err != nil {
		log.Fatalf("Failed to list deployments: %v", err)
	}

	fmt.Printf("Found %d deployments.\n", len(deployments))
}
```

## Usage and Examples

The SDK is organized into packages that mirror the HKS API structure. All methods return the standard `(result, error)` tuple.

### Listing Resources

```go
// List all pods in a workspace
pods, err := hks.Apps.Pods.List("production")
if err != nil {
    // handle error
}

for _, pod := range pods {
    fmt.Printf("Pod: %s, Status: %s\n", pod.Name, pod.Status)
}
```

### Getting a Specific Resource

```go
// Get a specific deployment
deployment, err := hks.Apps.Deployments.Get("production", "my-frontend-app")
if err != nil {
    // handle error
}
fmt.Printf("Deployment '%s' has %d replicas.\n", deployment.Name, *deployment.Spec.Replicas)
```

### Creating Resources

You can create resources by providing a struct that defines the resource spec.

```go
import "github.com/hexabase/hks-sdk-go/spec/apps"

// Define a new deployment
spec := &apps.DeploymentSpec{
    Name:     "my-go-sdk-app",
    Replicas: 2,
    Containers: []apps.ContainerSpec{
        {
            Name:  "web",
            Image: "nginx:latest",
            Ports: []apps.ContainerPort{{ContainerPort: 80}},
        },
    },
}

// Create the deployment
created, err := hks.Apps.Deployments.Create("development", spec)
if err != nil {
    // handle error
}
fmt.Printf("Successfully created deployment '%s'.\n", created.Name)
```

### Updating Resources

To update a resource, you typically `get` it first, modify its spec, and then call the `update` method.

```go
// Scale a deployment up to 3 replicas
deployment, err := hks.Apps.Deployments.Get("development", "my-go-sdk-app")
if err != nil {
    // handle error
}

deployment.Spec.Replicas = 3

updated, err := hks.Apps.Deployments.Update("development", deployment.Name, deployment.Spec)
if err != nil {
    // handle error
}

fmt.Printf("Scaled deployment to %d replicas.\n", *updated.Spec.Replicas)
```

### Deleting Resources

```go
// Delete the deployment
err := hks.Apps.Deployments.Delete("development", "my-go-sdk-app")
if err != nil {
    // handle error
}
fmt.Println("Deployment deleted.")
```

### AIOps LLM Integration

The SDK provides a simple interface to the secure LLM gateway.

```go
prompt := "Translate the following English text to French: 'Hello, World!'"

// The workspace context determines the LLM model and data sanitization rules.
response, err := hks.AIOps.LLM.Invoke("development", prompt)
if err != nil {
    // handle error
}

fmt.Printf("LLM Response: %s\n", response)
```

This Go SDK is ideal for building performance-critical applications and custom Kubernetes operators that leverage the full capabilities of the Hexabase.AI platform.
