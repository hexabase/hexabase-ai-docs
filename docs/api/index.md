# API Reference

Complete API documentation for integrating with Hexabase.AI platform programmatically.

## Overview

The Hexabase.AI API provides comprehensive programmatic access to all platform features. Built on REST principles with GraphQL support for complex queries, our API enables you to automate workflows, integrate with CI/CD pipelines, and build custom tools on top of our platform.

## API Documentation

<div class="grid cards" markdown>

-   :material-key:{ .lg .middle } **Authentication**

    ---

    API keys, OAuth, and service accounts

    [:octicons-arrow-right-24: Authentication Guide](authentication.md)

-   :material-api:{ .lg .middle } **REST API**

    ---

    RESTful endpoints for all resources

    [:octicons-arrow-right-24: REST Reference](rest-api.md)

-   :material-graphql:{ .lg .middle } **GraphQL API**

    ---

    Flexible queries for complex data needs

    [:octicons-arrow-right-24: GraphQL Schema](websocket-api.md)

-   :material-code-json:{ .lg .middle } **SDKs & Tools**

    ---

    Client libraries and developer tools

    [:octicons-arrow-right-24: SDK Documentation](../sdk/index.md)

</div>

## Quick Start

### 1. Get Your API Key
```bash
# Generate an API key
hks auth create-key --name "My API Key" --scope workspace:read,write

# Output:
# API Key: hks_live_a1b2c3d4e5f6...
# Key ID: key_123456
```

### 2. Make Your First Request
```bash
# Using curl
curl -H "Authorization: Bearer hks_live_a1b2c3d4e5f6..." \
  https://api.hexabase.ai/v1/workspaces

# Using HTTPie
http GET https://api.hexabase.ai/v1/workspaces \
  Authorization:"Bearer hks_live_a1b2c3d4e5f6..."
```

### 3. Use an SDK
```python
# Python SDK
from hexabase import Client

client = Client(api_key="hks_live_a1b2c3d4e5f6...")
workspaces = client.workspaces.list()
```

## API Design Principles

### RESTful Architecture
- **Resources**: Nouns represent entities (workspaces, projects, deployments)
- **HTTP Methods**: GET, POST, PUT, PATCH, DELETE
- **Status Codes**: Standard HTTP status codes
- **Hypermedia**: Links to related resources

### Consistent Patterns
```
GET    /v1/{resource}          # List resources
POST   /v1/{resource}          # Create resource
GET    /v1/{resource}/{id}     # Get specific resource
PUT    /v1/{resource}/{id}     # Update resource
DELETE /v1/{resource}/{id}     # Delete resource
```

### Pagination
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "pages": 5
  },
  "links": {
    "first": "https://api.hexabase.ai/v1/workspaces?page=1",
    "last": "https://api.hexabase.ai/v1/workspaces?page=5",
    "next": "https://api.hexabase.ai/v1/workspaces?page=2"
  }
}
```

## Common Operations

### Workspace Management
```python
# List workspaces
workspaces = client.workspaces.list()

# Create workspace
workspace = client.workspaces.create(
    name="production",
    description="Production environment"
)

# Update workspace
workspace.update(
    resource_quota={"cpu": "100", "memory": "200Gi"}
)
```

### Project Deployment
```python
# Deploy a project
deployment = client.projects.deploy(
    workspace_id="ws_123",
    name="my-app",
    source="github.com/myorg/myapp",
    environment={
        "DATABASE_URL": "postgresql://...",
        "API_KEY": {"from_secret": "api-key"}
    }
)

# Check deployment status
status = deployment.get_status()
print(f"Status: {status.phase}")
```

### Resource Monitoring
```python
# Get metrics
metrics = client.metrics.query(
    workspace_id="ws_123",
    metric="cpu_usage",
    period="1h"
)

# Set up alerts
alert = client.alerts.create(
    name="High CPU",
    condition="avg(cpu_usage) > 80",
    duration="5m",
    notifications=["email:ops@example.com"]
)
```

## API Features

### Rate Limiting
- **Default**: 1000 requests per hour
- **Burst**: 100 requests per minute
- **Headers**: X-RateLimit-Limit, X-RateLimit-Remaining

### Versioning
- **URL Path**: /v1/, /v2/
- **Header**: Accept: application/vnd.hexabase.v1+json
- **Deprecation**: 6-month notice period

### Error Handling
```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Workspace 'ws_123' not found",
    "details": {
      "resource_type": "workspace",
      "resource_id": "ws_123"
    },
    "request_id": "req_a1b2c3d4"
  }
}
```

### Webhooks
```python
# Register webhook
webhook = client.webhooks.create(
    url="https://myapp.com/webhook",
    events=["deployment.created", "deployment.failed"],
    workspace_id="ws_123"
)

# Webhook payload
{
  "event": "deployment.created",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "deployment": {...}
  },
  "signature": "sha256=..."
}
```

## Advanced Features

### Batch Operations
```python
# Batch create resources
operations = [
    {"method": "POST", "path": "/projects", "body": {...}},
    {"method": "POST", "path": "/projects", "body": {...}}
]

results = client.batch.execute(operations)
```

### GraphQL Queries
```graphql
query GetWorkspaceDetails($id: ID!) {
  workspace(id: $id) {
    name
    projects {
      name
      deployments {
        status
        replicas
        resources {
          cpu
          memory
        }
      }
    }
  }
}
```

### Streaming APIs
```python
# Stream logs
for log in client.logs.stream(deployment_id="dep_123"):
    print(f"{log.timestamp}: {log.message}")

# Stream metrics
for metric in client.metrics.stream(
    workspace_id="ws_123",
    metric="cpu_usage"
):
    print(f"CPU: {metric.value}%")
```

## Security

### API Key Scopes
- **read**: Read-only access
- **write**: Create and update resources
- **delete**: Delete resources
- **admin**: Full administrative access

### IP Whitelisting
```python
# Configure IP whitelist
client.security.update_ip_whitelist([
    "203.0.113.0/24",
    "198.51.100.0/24"
])
```

### Audit Logging
All API calls are logged with:
- Timestamp
- API key ID
- IP address
- Request details
- Response status

## SDK Examples

### Python
```python
from hexabase import Client, Workspace

async with Client(api_key="...") as client:
    workspace = await client.workspaces.create(
        name="staging",
        region="us-west-2"
    )
```

### JavaScript/TypeScript
```typescript
import { HexabaseClient } from '@hexabase/sdk';

const client = new HexabaseClient({
  apiKey: process.env.HEXABASE_API_KEY
});

const workspaces = await client.workspaces.list();
```

### Go
```go
import "github.com/hexabase-ai/hexabase-go"

client := hexabase.NewClient("hks_live_...")
workspaces, err := client.Workspaces.List()
```

## API Testing

### Sandbox Environment
Test API calls without affecting production:
```bash
export HEXABASE_API_URL=https://sandbox.api.hexabase.ai
```

### Mock Server
Run a local mock server for development:
```bash
hks api mock --port 8080
```

## Next Steps

- **Get Started**: Set up [Authentication](authentication.md)
- **REST API**: Explore [REST Endpoints](rest-api.md)
- **GraphQL**: Learn [GraphQL Queries](websocket-api.md)
- **Integration**: Download [SDKs & Tools](../sdk/index.md)

## Related Documentation

- [Function API](function-api.md)
- [Error Codes](error-codes.md)
- [OpenAPI Specification](https://api.hexabase.ai/openapi.json)