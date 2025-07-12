# Projects API

Projects provide logical organization and resource isolation within workspaces. They map to Kubernetes namespaces and support hierarchical structures for complex application architectures.

## Base URL

All project endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/workspaces/:wsId/projects
```

## Project Object

```json
{
  "id": "proj-123",
  "name": "Frontend Project",
  "namespace": "frontend",
  "workspace_id": "ws-123",
  "parent_id": null,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "resource_quota": {
    "cpu": "2 cores",
    "memory": "4Gi",
    "storage": "10Gi",
    "pods": 20
  },
  "resource_usage": {
    "cpu": "1.2 cores",
    "memory": "2.8Gi",
    "storage": "5.5Gi",
    "pods": 8
  },
  "status": "active",
  "application_count": 3,
  "member_count": 5
}
```

## Project Management

### List Projects

Get all projects in a workspace.

```http
GET /api/v1/workspaces/:wsId/projects
```

**Query Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20, max: 100)
- `parent_id` (string) - Filter by parent project ID (use "null" for top-level projects)
- `status` (string) - Filter by status (`active`, `suspended`)
- `search` (string) - Search by project name
- `sort` (string) - Sort field (`name`, `created_at`, `updated_at`)
- `order` (string) - Sort order (`asc`, `desc`)

**Response:**
```json
{
  "data": [
    {
      "id": "proj-123",
      "name": "Frontend Project",
      "namespace": "frontend",
      "workspace_id": "ws-123",
      "parent_id": null,
      "created_at": "2024-01-01T00:00:00Z",
      "resource_quota": {
        "cpu": "2 cores",
        "memory": "4Gi",
        "storage": "10Gi"
      },
      "resource_usage": {
        "cpu": "1.2 cores",
        "memory": "2.8Gi",
        "storage": "5.5Gi"
      },
      "status": "active",
      "application_count": 3,
      "children_count": 2
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 5,
    "pages": 1
  }
}
```

### Create Project

Create a new project in the workspace.

```http
POST /api/v1/workspaces/:wsId/projects
```

**Request Body:**
```json
{
  "name": "Frontend Project",
  "parent_id": null,
  "description": "Main frontend application project",
  "resource_quota": {
    "cpu": "2",
    "memory": "4Gi",
    "storage": "10Gi",
    "pods": 20
  },
  "labels": {
    "environment": "production",
    "team": "frontend"
  }
}
```

**Validation:**
- `name` - Required, 3-50 characters, alphanumeric with hyphens
- `parent_id` - Optional, must be valid project ID in same workspace
- `description` - Optional, max 500 characters
- `resource_quota` - Optional, inherits from workspace if not specified

**Response:**
```json
{
  "data": {
    "id": "proj-123",
    "name": "Frontend Project",
    "namespace": "frontend-project",
    "workspace_id": "ws-123",
    "parent_id": null,
    "description": "Main frontend application project",
    "created_at": "2024-01-20T10:00:00Z",
    "resource_quota": {
      "cpu": "2 cores",
      "memory": "4Gi",
      "storage": "10Gi",
      "pods": 20
    },
    "status": "active",
    "labels": {
      "environment": "production",
      "team": "frontend"
    }
  }
}
```

### Get Project

Get detailed information about a specific project.

```http
GET /api/v1/workspaces/:wsId/projects/:projectId
```

**Response:**
```json
{
  "data": {
    "id": "proj-123",
    "name": "Frontend Project",
    "namespace": "frontend-project",
    "workspace_id": "ws-123",
    "parent_id": null,
    "description": "Main frontend application project",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "resource_quota": {
      "cpu": "2 cores",
      "memory": "4Gi",
      "storage": "10Gi",
      "pods": 20
    },
    "resource_usage": {
      "cpu": "1.2 cores",
      "memory": "2.8Gi",
      "storage": "5.5Gi",
      "pods": 8
    },
    "status": "active",
    "labels": {
      "environment": "production",
      "team": "frontend"
    },
    "applications": [
      {
        "id": "app-123",
        "name": "web-app",
        "type": "deployment",
        "status": "running"
      }
    ],
    "members": [
      {
        "user_id": "user-123",
        "role": "admin",
        "added_at": "2024-01-01T00:00:00Z"
      }
    ],
    "children": [
      {
        "id": "proj-456",
        "name": "Frontend Components",
        "namespace": "frontend-project-components"
      }
    ]
  }
}
```

### Update Project

Update project configuration and resource quotas.

```http
PUT /api/v1/workspaces/:wsId/projects/:projectId
```

**Request Body:**
```json
{
  "name": "Updated Frontend Project",
  "description": "Updated description",
  "resource_quota": {
    "cpu": "4",
    "memory": "8Gi",
    "storage": "20Gi",
    "pods": 40
  },
  "labels": {
    "environment": "production",
    "team": "frontend",
    "version": "v2"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "proj-123",
    "name": "Updated Frontend Project",
    "description": "Updated description",
    "updated_at": "2024-01-20T15:00:00Z",
    "resource_quota": {
      "cpu": "4 cores",
      "memory": "8Gi",
      "storage": "20Gi",
      "pods": 40
    },
    "labels": {
      "environment": "production",
      "team": "frontend",
      "version": "v2"
    }
  }
}
```

### Delete Project

Delete a project and all its resources. This action is irreversible.

```http
DELETE /api/v1/workspaces/:wsId/projects/:projectId
```

**Query Parameters:**
- `force` (boolean) - Force deletion even if applications are running
- `cascade` (boolean) - Delete child projects as well (default: false)

**Response:**
```json
{
  "data": {
    "message": "Project deletion initiated",
    "task_id": "task-789"
  }
}
```

## Project Hierarchy

### Create Sub-Project

Create a child project under an existing project.

```http
POST /api/v1/workspaces/:wsId/projects/:projectId/subprojects
```

**Request Body:**
```json
{
  "name": "Frontend Components",
  "description": "Reusable UI components",
  "resource_quota": {
    "cpu": "0.5",
    "memory": "1Gi",
    "storage": "2Gi",
    "pods": 5
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "proj-456",
    "name": "Frontend Components",
    "namespace": "frontend-project-components",
    "workspace_id": "ws-123",
    "parent_id": "proj-123",
    "description": "Reusable UI components",
    "created_at": "2024-01-20T10:00:00Z",
    "resource_quota": {
      "cpu": "0.5 cores",
      "memory": "1Gi",
      "storage": "2Gi",
      "pods": 5
    }
  }
}
```

### Get Project Hierarchy

Get the complete hierarchy tree for a project including all descendants.

```http
GET /api/v1/workspaces/:wsId/projects/:projectId/hierarchy
```

**Response:**
```json
{
  "data": {
    "id": "proj-123",
    "name": "Frontend Project",
    "namespace": "frontend-project",
    "children": [
      {
        "id": "proj-456",
        "name": "Frontend Components",
        "namespace": "frontend-project-components",
        "children": [
          {
            "id": "proj-789",
            "name": "UI Library",
            "namespace": "frontend-project-components-ui",
            "children": []
          }
        ]
      },
      {
        "id": "proj-321",
        "name": "Frontend Tests",
        "namespace": "frontend-project-tests",
        "children": []
      }
    ]
  }
}
```

## Resource Management

### Apply Resource Quota

Set or update resource quotas for a project.

```http
POST /api/v1/workspaces/:wsId/projects/:projectId/resource-quota
```

**Request Body:**
```json
{
  "cpu": "4",
  "memory": "8Gi",
  "storage": "20Gi",
  "pods": 40,
  "persistent_volume_claims": 10,
  "services": 5,
  "secrets": 20,
  "config_maps": 20
}
```

**Response:**
```json
{
  "data": {
    "project_id": "proj-123",
    "resource_quota": {
      "cpu": "4 cores",
      "memory": "8Gi",
      "storage": "20Gi",
      "pods": 40,
      "persistent_volume_claims": 10,
      "services": 5,
      "secrets": 20,
      "config_maps": 20
    },
    "applied_at": "2024-01-20T15:00:00Z"
  }
}
```

### Get Resource Usage

Get detailed resource usage for the project.

```http
GET /api/v1/workspaces/:wsId/projects/:projectId/resource-usage
```

**Query Parameters:**
- `period` (string) - Time period for metrics (`1h`, `6h`, `24h`, `7d`, `30d`)
- `include_children` (boolean) - Include usage from child projects

**Response:**
```json
{
  "data": {
    "current": {
      "cpu": {
        "used": "1.2",
        "limit": "4",
        "unit": "cores",
        "percentage": 30
      },
      "memory": {
        "used": "2867", 
        "limit": "8192",
        "unit": "Mi",
        "percentage": 35
      },
      "storage": {
        "used": "5632",
        "limit": "20480",
        "unit": "Mi", 
        "percentage": 27
      },
      "pods": {
        "used": 8,
        "limit": 40,
        "percentage": 20
      }
    },
    "breakdown": {
      "by_application": [
        {
          "application_id": "app-123",
          "name": "web-app",
          "cpu": "0.8 cores",
          "memory": "2Gi",
          "storage": "4Gi",
          "pods": 3
        }
      ]
    },
    "children": [
      {
        "project_id": "proj-456",
        "name": "Frontend Components",
        "cpu": "0.2 cores",
        "memory": "0.5Gi",
        "storage": "1Gi",
        "pods": 2
      }
    ]
  }
}
```

## Project Members

### Add Project Member

Grant a user access to a specific project.

```http
POST /api/v1/workspaces/:wsId/projects/:projectId/members
```

**Request Body:**
```json
{
  "user_id": "user-456",
  "role": "developer"
}
```

**Valid Roles:**
- `admin` - Full project management access
- `developer` - Deploy and manage applications
- `viewer` - Read-only access

**Response:**
```json
{
  "data": {
    "id": "proj-member-123",
    "project_id": "proj-123",
    "user_id": "user-456",
    "role": "developer",
    "added_at": "2024-01-20T15:00:00Z",
    "added_by": "user-123"
  }
}
```

### List Project Members

Get all members with access to the project.

```http
GET /api/v1/workspaces/:wsId/projects/:projectId/members
```

**Response:**
```json
{
  "data": [
    {
      "id": "proj-member-123",
      "user_id": "user-456",
      "role": "developer",
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

### Remove Project Member

Remove a user's access to the project.

```http
DELETE /api/v1/workspaces/:wsId/projects/:projectId/members/:userId
```

**Response:**
```json
{
  "data": {
    "message": "Member removed from project"
  }
}
```

## Activity Logs

### Get Activity Logs

Get activity logs for the project including deployments, scaling, and member changes.

```http
GET /api/v1/workspaces/:wsId/projects/:projectId/activity
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `action` (string) - Filter by action type
- `user_id` (string) - Filter by user
- `since` (string) - Filter by timestamp (ISO 8601)

**Response:**
```json
{
  "data": [
    {
      "id": "activity-123",
      "project_id": "proj-123",
      "action": "application.deployed",
      "resource_type": "application",
      "resource_id": "app-123",
      "resource_name": "web-app",
      "user_id": "user-456",
      "timestamp": "2024-01-20T14:30:00Z",
      "details": {
        "image": "nginx:1.21",
        "replicas": 3,
        "version": "v1.2.0"
      },
      "user": {
        "id": "user-456",
        "name": "Jane Developer",
        "email": "jane@example.com"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 45,
    "pages": 3
  }
}
```

## Error Responses

### 400 Bad Request - Invalid Resource Quota
```json
{
  "error": {
    "code": "INVALID_RESOURCE_QUOTA",
    "message": "Resource quota exceeds workspace limits",
    "details": {
      "requested_cpu": "10 cores",
      "workspace_cpu_limit": "8 cores"
    }
  }
}
```

### 409 Conflict - Namespace Already Exists
```json
{
  "error": {
    "code": "NAMESPACE_EXISTS",
    "message": "Project namespace already exists",
    "details": {
      "namespace": "frontend-project",
      "existing_project_id": "proj-456"
    }
  }
}
```

### 422 Unprocessable Entity - Circular Dependency
```json
{
  "error": {
    "code": "CIRCULAR_DEPENDENCY",
    "message": "Cannot set parent project - would create circular dependency",
    "details": {
      "project_id": "proj-123",
      "parent_id": "proj-456"
    }
  }
}
```

## Webhooks

Project events that trigger webhooks:

- `project.created`
- `project.updated`
- `project.deleted`
- `project.member.added`
- `project.member.removed`
- `project.resource_quota.updated`
- `project.resource_quota.exceeded`

## Best Practices

1. **Naming**: Use clear, descriptive names that reflect the project's purpose
2. **Hierarchy**: Organize related projects in hierarchies for better management
3. **Resource Quotas**: Set appropriate quotas based on application requirements
4. **Access Control**: Grant minimal necessary permissions to project members
5. **Monitoring**: Regularly review resource usage and activity logs