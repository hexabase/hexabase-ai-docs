# Workspaces API

Workspaces are isolated Kubernetes environments within an organization. Each workspace provides a dedicated virtual cluster for deploying and managing applications.

## Base URL

All workspace endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/organizations/:orgId/workspaces
```

## Workspace Object

```json
{
  "id": "ws-123",
  "name": "Development Workspace",
  "slug": "dev-workspace",
  "organization_id": "org-123",
  "status": "active",
  "plan": "standard",
  "kubernetes_version": "1.28",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "vcluster": {
    "name": "vcluster-ws-123",
    "namespace": "ws-123",
    "api_endpoint": "https://ws-123.api.hexabase.ai",
    "version": "0.19.0"
  },
  "resource_limits": {
    "cpu": "10 cores",
    "memory": "32Gi",
    "storage": "100Gi"
  },
  "resource_usage": {
    "cpu": "2.5 cores",
    "memory": "8Gi", 
    "storage": "50Gi"
  }
}
```

## Workspace Management

### List Workspaces

Get all workspaces in an organization.

```http
GET /api/v1/organizations/:orgId/workspaces
```

**Query Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20, max: 100)
- `status` (string) - Filter by status (`active`, `provisioning`, `suspended`, `terminating`)
- `plan` (string) - Filter by plan (`shared`, `dedicated`)
- `search` (string) - Search by workspace name

**Response:**
```json
{
  "data": [
    {
      "id": "ws-123",
      "name": "Development Workspace",
      "slug": "dev-workspace",
      "organization_id": "org-123",
      "status": "active",
      "plan": "standard",
      "created_at": "2024-01-01T00:00:00Z",
      "resource_usage": {
        "cpu": "2.5 cores",
        "memory": "8Gi",
        "storage": "50Gi"
      },
      "project_count": 5,
      "application_count": 12
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 3,
    "pages": 1
  }
}
```

### Create Workspace

Create a new workspace in the organization.

```http
POST /api/v1/organizations/:orgId/workspaces
```

**Request Body:**
```json
{
  "name": "Development Workspace",
  "plan": "standard",
  "kubernetes_version": "1.28",
  "region": "us-west-2",
  "resource_quota": {
    "cpu": "10",
    "memory": "32Gi",
    "storage": "100Gi"
  }
}
```

**Validation:**
- `name` - Required, 3-50 characters, alphanumeric with spaces and hyphens
- `plan` - Required, one of: `shared`, `dedicated`
- `kubernetes_version` - Optional, defaults to latest supported version
- `region` - Optional, defaults to organization's default region

**Response:**
```json
{
  "data": {
    "id": "ws-123",
    "name": "Development Workspace",
    "slug": "development-workspace",
    "organization_id": "org-123",
    "status": "provisioning",
    "plan": "standard",
    "kubernetes_version": "1.28",
    "region": "us-west-2",
    "created_at": "2024-01-20T10:00:00Z",
    "provisioning_task_id": "task-123"
  }
}
```

### Get Workspace

Get detailed information about a specific workspace.

```http
GET /api/v1/organizations/:orgId/workspaces/:wsId
```

**Response:**
```json
{
  "data": {
    "id": "ws-123",
    "name": "Development Workspace",
    "slug": "development-workspace",
    "organization_id": "org-123",
    "status": "active",
    "plan": "standard",
    "kubernetes_version": "1.28",
    "region": "us-west-2",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "vcluster": {
      "name": "vcluster-ws-123",
      "namespace": "ws-123",
      "api_endpoint": "https://ws-123.api.hexabase.ai",
      "version": "0.19.0",
      "status": "ready"
    },
    "resource_limits": {
      "cpu": "10 cores",
      "memory": "32Gi",
      "storage": "100Gi",
      "pods": 100
    },
    "resource_usage": {
      "cpu": "2.5 cores",
      "memory": "8Gi",
      "storage": "50Gi",
      "pods": 15
    },
    "network": {
      "cluster_cidr": "10.42.0.0/16",
      "service_cidr": "10.43.0.0/16",
      "ingress_class": "nginx"
    },
    "billing": {
      "current_monthly_cost": 250.00,
      "projected_monthly_cost": 275.00
    }
  }
}
```

### Update Workspace

Update workspace configuration. Some fields may require workspace restart.

```http
PUT /api/v1/organizations/:orgId/workspaces/:wsId
```

**Request Body:**
```json
{
  "name": "Updated Workspace Name",
  "plan": "dedicated",
  "resource_quota": {
    "cpu": "20",
    "memory": "64Gi",
    "storage": "200Gi"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "ws-123",
    "name": "Updated Workspace Name",
    "plan": "dedicated",
    "updated_at": "2024-01-20T15:00:00Z",
    "restart_required": true
  }
}
```

### Delete Workspace

Delete a workspace and all its resources. This action is irreversible.

```http
DELETE /api/v1/organizations/:orgId/workspaces/:wsId
```

**Query Parameters:**
- `force` (boolean) - Force deletion even if applications are running

**Response:**
```json
{
  "data": {
    "message": "Workspace deletion initiated",
    "task_id": "task-456"
  }
}
```

### Get Kubeconfig

Get the kubeconfig file for direct kubectl access to the workspace.

```http
GET /api/v1/organizations/:orgId/workspaces/:wsId/kubeconfig
```

**Response:** Returns a YAML kubeconfig file
```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: https://ws-123.api.hexabase.ai
    certificate-authority-data: LS0tLS1CRUdJTi...
  name: hexabase-ws-123
contexts:
- context:
    cluster: hexabase-ws-123
    user: hexabase-user
    namespace: default
  name: hexabase-ws-123
current-context: hexabase-ws-123
users:
- name: hexabase-user
  user:
    token: eyJhbGciOiJSUzI1NiIs...
```

### Get Resource Usage

Get detailed resource usage information for the workspace.

```http
GET /api/v1/organizations/:orgId/workspaces/:wsId/resource-usage
```

**Query Parameters:**
- `period` (string) - Time period for metrics (`1h`, `6h`, `24h`, `7d`, `30d`)

**Response:**
```json
{
  "data": {
    "current": {
      "cpu": {
        "used": "2.5",
        "limit": "10",
        "unit": "cores",
        "percentage": 25
      },
      "memory": {
        "used": "8192",
        "limit": "32768",
        "unit": "Mi",
        "percentage": 25
      },
      "storage": {
        "used": "51200",
        "limit": "102400",
        "unit": "Mi",
        "percentage": 50
      },
      "pods": {
        "used": 15,
        "limit": 100,
        "percentage": 15
      }
    },
    "breakdown": {
      "by_namespace": [
        {
          "namespace": "frontend",
          "cpu": "1.2 cores",
          "memory": "4Gi",
          "storage": "20Gi",
          "pods": 8
        }
      ],
      "by_application": [
        {
          "application_id": "app-123",
          "name": "web-app",
          "cpu": "0.8 cores",
          "memory": "2Gi",
          "storage": "10Gi",
          "pods": 3
        }
      ]
    },
    "history": {
      "cpu": [
        {
          "timestamp": "2024-01-20T10:00:00Z",
          "value": 2.1
        }
      ],
      "memory": [
        {
          "timestamp": "2024-01-20T10:00:00Z", 
          "value": 7680
        }
      ]
    }
  }
}
```

## Workspace Members

### Add Workspace Member

Add a user to the workspace with specific permissions.

```http
POST /api/v1/organizations/:orgId/workspaces/:wsId/members
```

**Request Body:**
```json
{
  "user_id": "user-456",
  "role": "developer",
  "namespaces": ["frontend", "backend"]
}
```

**Validation:**
- `user_id` - Required, must be an organization member
- `role` - Required, one of: `admin`, `developer`, `viewer`
- `namespaces` - Optional, array of namespace names for scoped access

**Response:**
```json
{
  "data": {
    "id": "ws-member-123",
    "workspace_id": "ws-123",
    "user_id": "user-456",
    "role": "developer",
    "namespaces": ["frontend", "backend"],
    "added_at": "2024-01-20T15:00:00Z",
    "added_by": "user-123"
  }
}
```

### List Workspace Members

Get all members with access to the workspace.

```http
GET /api/v1/organizations/:orgId/workspaces/:wsId/members
```

**Response:**
```json
{
  "data": [
    {
      "id": "ws-member-123",
      "user_id": "user-456",
      "role": "developer",
      "namespaces": ["frontend", "backend"],
      "added_at": "2024-01-01T00:00:00Z",
      "user": {
        "id": "user-456",
        "email": "dev@example.com",
        "name": "Jane Developer",
        "picture": "https://..."
      }
    }
  ]
}
```

### Remove Workspace Member

Remove a user's access to the workspace.

```http
DELETE /api/v1/organizations/:orgId/workspaces/:wsId/members/:userId
```

**Response:**
```json
{
  "data": {
    "message": "Member removed from workspace"
  }
}
```

## Workspace Status

### Workspace Status Types

- `provisioning` - Workspace is being created
- `active` - Workspace is running and available
- `suspended` - Workspace is temporarily disabled
- `terminating` - Workspace is being deleted
- `error` - Workspace encountered an error

### Workspace Plans

#### Shared Plan
- Multi-tenant cluster with resource isolation
- Shared control plane
- Cost-effective for development and staging
- Resource limits enforced via quotas

#### Dedicated Plan  
- Single-tenant cluster
- Dedicated control plane and worker nodes
- Enhanced security and performance
- Custom resource limits
- Advanced features like backup policies

## Error Responses

### 400 Bad Request - Invalid Configuration
```json
{
  "error": {
    "code": "INVALID_WORKSPACE_CONFIG",
    "message": "Invalid workspace configuration",
    "details": {
      "kubernetes_version": "Version 1.25 is no longer supported"
    }
  }
}
```

### 402 Payment Required - Quota Exceeded
```json
{
  "error": {
    "code": "WORKSPACE_QUOTA_EXCEEDED",
    "message": "Workspace quota exceeded for current plan",
    "details": {
      "current_workspaces": 5,
      "max_workspaces": 5,
      "plan": "standard"
    }
  }
}
```

### 409 Conflict - Name Already Exists
```json
{
  "error": {
    "code": "WORKSPACE_NAME_EXISTS",
    "message": "Workspace name already exists in organization",
    "details": {
      "name": "development-workspace"
    }
  }
}
```

### 422 Unprocessable Entity - Provisioning Failed
```json
{
  "error": {
    "code": "WORKSPACE_PROVISIONING_FAILED",
    "message": "Failed to provision workspace",
    "details": {
      "reason": "Insufficient cluster capacity",
      "retry_after": "2024-01-20T16:00:00Z"
    }
  }
}
```

## Webhooks

Workspace events that trigger webhooks:

- `workspace.created`
- `workspace.updated`
- `workspace.deleted`
- `workspace.provisioning_started`
- `workspace.provisioning_completed`
- `workspace.provisioning_failed`
- `workspace.suspended`
- `workspace.resumed`
- `workspace.member.added`
- `workspace.member.removed`
- `workspace.resource_quota.exceeded`

Example webhook payload:
```json
{
  "event": "workspace.created",
  "timestamp": "2024-01-20T10:00:00Z",
  "data": {
    "workspace": {
      "id": "ws-123",
      "name": "Development Workspace",
      "organization_id": "org-123",
      "status": "provisioning"
    }
  }
}
```

## Rate Limits

Workspace endpoints have the following rate limits:

- Create workspace: 10 per hour per organization
- Update workspace: 50 per hour per workspace  
- Delete workspace: 5 per hour per organization
- Other endpoints: Standard API rate limits apply

## Best Practices

1. **Naming Convention**: Use descriptive names that indicate purpose (e.g., "production", "staging", "feature-branch")

2. **Resource Planning**: Monitor resource usage and set appropriate quotas based on application needs

3. **Access Control**: Use workspace members to control access and implement least-privilege principles

4. **Monitoring**: Regularly check workspace health and resource utilization

5. **Cost Optimization**: Use shared plans for development, dedicated plans for production workloads