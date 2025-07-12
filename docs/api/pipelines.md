# CI/CD Pipelines API

CI/CD pipelines enable automated building, testing, and deployment of applications. Pipelines support various source providers, custom templates, and integration with Git repositories.

## Base URLs

Pipeline management endpoints:
```
https://api.hexabase.ai/api/v1/workspaces/:wsId/pipelines
https://api.hexabase.ai/api/v1/pipelines/:pipelineId
```

## Pipeline Object

```json
{
  "id": "pipe-123",
  "name": "frontend-deploy",
  "workspace_id": "ws-123",
  "status": "running",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "source": {
    "type": "git",
    "repository": "https://github.com/myorg/frontend-app",
    "branch": "main",
    "commit": "abc123def456"
  },
  "template": {
    "id": "template-nodejs",
    "name": "Node.js Application",
    "version": "v1.2.0"
  },
  "configuration": {
    "build_steps": [
      {
        "name": "install",
        "command": "npm install"
      },
      {
        "name": "test",
        "command": "npm test"
      },
      {
        "name": "build",
        "command": "npm run build"
      }
    ],
    "environment": {
      "NODE_ENV": "production",
      "API_URL": "https://api.example.com"
    },
    "triggers": {
      "on_push": true,
      "on_pull_request": false,
      "on_schedule": null
    }
  },
  "execution": {
    "current_run_id": "run-456",
    "last_run_status": "success",
    "last_run_at": "2024-01-20T14:30:00Z",
    "total_runs": 145,
    "success_rate": 94.5
  }
}
```

## Pipeline Management

### Create Pipeline

Create a new CI/CD pipeline.

```http
POST /api/v1/workspaces/:wsId/pipelines
```

**Request Body:**
```json
{
  "name": "frontend-deploy",
  "description": "Frontend application deployment pipeline",
  "source": {
    "type": "git",
    "repository": "https://github.com/myorg/frontend-app",
    "branch": "main",
    "credential_name": "github-token"
  },
  "template_id": "template-nodejs",
  "configuration": {
    "build_steps": [
      {
        "name": "install",
        "command": "npm install",
        "working_directory": "."
      },
      {
        "name": "test",
        "command": "npm test",
        "continue_on_error": false
      },
      {
        "name": "build",
        "command": "npm run build"
      }
    ],
    "environment": {
      "NODE_ENV": "production",
      "API_URL": "https://api.example.com"
    },
    "triggers": {
      "on_push": true,
      "on_pull_request": true,
      "on_schedule": "0 2 * * *"
    },
    "deployment": {
      "target_application": "app-123",
      "auto_deploy": true,
      "deployment_strategy": "rolling"
    }
  },
  "labels": {
    "team": "frontend",
    "environment": "production"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "pipe-123",
    "name": "frontend-deploy",
    "workspace_id": "ws-123",
    "status": "created",
    "created_at": "2024-01-20T10:00:00Z",
    "source": {
      "type": "git",
      "repository": "https://github.com/myorg/frontend-app",
      "branch": "main"
    },
    "template": {
      "id": "template-nodejs",
      "name": "Node.js Application"
    }
  }
}
```

### Create Pipeline from Template

Create a pipeline using a predefined template.

```http
POST /api/v1/workspaces/:wsId/pipelines/from-template
```

**Request Body:**
```json
{
  "name": "api-deploy",
  "template_id": "template-golang-api",
  "source": {
    "repository": "https://github.com/myorg/api-service",
    "branch": "main",
    "credential_name": "github-token"
  },
  "template_variables": {
    "GO_VERSION": "1.21",
    "TARGET_PORT": "8080",
    "DOCKER_REGISTRY": "registry.hexabase.ai"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "pipe-456",
    "name": "api-deploy",
    "workspace_id": "ws-123",
    "status": "created",
    "template": {
      "id": "template-golang-api",
      "name": "Go API Service",
      "variables_applied": {
        "GO_VERSION": "1.21",
        "TARGET_PORT": "8080"
      }
    }
  }
}
```

### List Pipelines

Get all pipelines in a workspace.

```http
GET /api/v1/workspaces/:wsId/pipelines
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page  
- `status` (string) - Filter by status (`active`, `paused`, `error`)
- `source_type` (string) - Filter by source type
- `search` (string) - Search by pipeline name

**Response:**
```json
{
  "data": [
    {
      "id": "pipe-123",
      "name": "frontend-deploy",
      "workspace_id": "ws-123",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z",
      "source": {
        "type": "git",
        "repository": "https://github.com/myorg/frontend-app",
        "branch": "main"
      },
      "execution": {
        "last_run_status": "success",
        "last_run_at": "2024-01-20T14:30:00Z",
        "total_runs": 145
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 8,
    "pages": 1
  }
}
```

### Get Pipeline

Get detailed information about a specific pipeline.

```http
GET /api/v1/pipelines/:pipelineId
```

**Response:**
```json
{
  "data": {
    "id": "pipe-123",
    "name": "frontend-deploy",
    "description": "Frontend application deployment pipeline",
    "workspace_id": "ws-123",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "source": {
      "type": "git",
      "repository": "https://github.com/myorg/frontend-app",
      "branch": "main",
      "commit": "abc123def456",
      "credential_name": "github-token"
    },
    "template": {
      "id": "template-nodejs",
      "name": "Node.js Application",
      "version": "v1.2.0"
    },
    "configuration": {
      "build_steps": [
        {
          "name": "install",
          "command": "npm install",
          "working_directory": ".",
          "timeout": 300
        }
      ],
      "environment": {
        "NODE_ENV": "production",
        "API_URL": "https://api.example.com"
      },
      "triggers": {
        "on_push": true,
        "on_pull_request": true,
        "on_schedule": "0 2 * * *"
      },
      "deployment": {
        "target_application": "app-123",
        "auto_deploy": true,
        "deployment_strategy": "rolling"
      }
    },
    "execution": {
      "current_run_id": "run-456",
      "last_run_status": "success",
      "last_run_at": "2024-01-20T14:30:00Z",
      "total_runs": 145,
      "success_rate": 94.5,
      "average_duration": "4m 32s"
    },
    "recent_runs": [
      {
        "id": "run-456",
        "status": "success",
        "started_at": "2024-01-20T14:30:00Z",
        "completed_at": "2024-01-20T14:34:32Z",
        "duration": "4m 32s",
        "commit": "abc123def456"
      }
    ]
  }
}
```

### Delete Pipeline

Delete a pipeline and its execution history.

```http
DELETE /api/v1/pipelines/:pipelineId
```

**Query Parameters:**
- `force` (boolean) - Force deletion even if currently running

**Response:**
```json
{
  "data": {
    "message": "Pipeline deleted successfully",
    "pipeline_id": "pipe-123"
  }
}
```

## Pipeline Execution

### Cancel Pipeline

Cancel a currently running pipeline.

```http
POST /api/v1/pipelines/:pipelineId/cancel
```

**Response:**
```json
{
  "data": {
    "pipeline_id": "pipe-123",
    "run_id": "run-456",
    "status": "cancelling",
    "cancelled_at": "2024-01-20T15:00:00Z"
  }
}
```

### Retry Pipeline

Retry a failed pipeline execution.

```http
POST /api/v1/pipelines/:pipelineId/retry
```

**Request Body:**
```json
{
  "run_id": "run-456", // Optional, defaults to last failed run
  "from_step": "test" // Optional, restart from specific step
}
```

**Response:**
```json
{
  "data": {
    "pipeline_id": "pipe-123",
    "new_run_id": "run-789",
    "status": "running",
    "retried_from": "run-456",
    "started_at": "2024-01-20T15:00:00Z"
  }
}
```

### Get Pipeline Logs

Get execution logs for a pipeline.

```http
GET /api/v1/pipelines/:pipelineId/logs
```

**Query Parameters:**
- `run_id` (string) - Specific run ID (defaults to latest)
- `step` (string) - Specific step name
- `since` (string) - Time duration
- `follow` (boolean) - Follow log output

**Response:**
```json
{
  "data": {
    "pipeline_id": "pipe-123",
    "run_id": "run-456",
    "logs": [
      {
        "timestamp": "2024-01-20T14:30:00Z",
        "step": "install",
        "level": "info",
        "message": "Running npm install..."
      },
      {
        "timestamp": "2024-01-20T14:31:30Z",
        "step": "install",
        "level": "info",
        "message": "Dependencies installed successfully"
      }
    ]
  }
}
```

### Stream Pipeline Logs

Stream live logs from a running pipeline.

```http
GET /api/v1/pipelines/:pipelineId/logs/stream
```

**Query Parameters:**
- `run_id` (string) - Specific run ID
- `step` (string) - Specific step name

**Response:** Server-Sent Events (SSE) stream
```
data: {"timestamp":"2024-01-20T15:00:00Z","step":"test","message":"Running test suite..."}

data: {"timestamp":"2024-01-20T15:00:15Z","step":"test","message":"✓ All tests passed"}
```

## Templates

### List Templates

Get all available pipeline templates.

```http
GET /api/v1/pipelines/templates
```

**Query Parameters:**
- `category` (string) - Filter by category
- `language` (string) - Filter by programming language

**Response:**
```json
{
  "data": [
    {
      "id": "template-nodejs",
      "name": "Node.js Application",
      "description": "Build and deploy Node.js applications",
      "category": "web_application",
      "language": "javascript",
      "version": "v1.2.0",
      "variables": [
        {
          "name": "NODE_VERSION",
          "description": "Node.js version",
          "default": "18",
          "required": true
        }
      ],
      "steps": [
        "install_dependencies",
        "run_tests",
        "build_application",
        "deploy"
      ]
    }
  ]
}
```

### Get Template

Get detailed information about a specific template.

```http
GET /api/v1/pipelines/templates/:templateId
```

**Response:**
```json
{
  "data": {
    "id": "template-nodejs",
    "name": "Node.js Application",
    "description": "Build and deploy Node.js applications with comprehensive testing",
    "category": "web_application",
    "language": "javascript",
    "version": "v1.2.0",
    "created_at": "2024-01-01T00:00:00Z",
    "variables": [
      {
        "name": "NODE_VERSION",
        "description": "Node.js version to use",
        "default": "18",
        "required": true,
        "type": "string"
      },
      {
        "name": "BUILD_COMMAND",
        "description": "Command to build the application",
        "default": "npm run build",
        "required": false,
        "type": "string"
      }
    ],
    "steps": [
      {
        "name": "install",
        "description": "Install dependencies",
        "command": "npm install",
        "timeout": 300
      },
      {
        "name": "test",
        "description": "Run test suite",
        "command": "npm test",
        "continue_on_error": false
      }
    ],
    "requirements": {
      "runtime": "nodejs",
      "minimum_memory": "512Mi",
      "build_tools": ["npm", "node"]
    }
  }
}
```

## Credentials

### Create Git Credential

Store Git repository credentials for pipeline access.

```http
POST /api/v1/workspaces/:wsId/credentials/git
```

**Request Body:**
```json
{
  "name": "github-token",
  "description": "GitHub access token for repositories",
  "type": "token",
  "credentials": {
    "token": "ghp_xxxxxxxxxxxxxxxxxxxx"
  },
  "scopes": [
    "https://github.com/myorg/*"
  ]
}
```

**Response:**
```json
{
  "data": {
    "id": "cred-123",
    "name": "github-token",
    "type": "git",
    "auth_type": "token",
    "created_at": "2024-01-20T10:00:00Z",
    "scopes": [
      "https://github.com/myorg/*"
    ]
  }
}
```

### Create Registry Credential

Store container registry credentials.

```http
POST /api/v1/workspaces/:wsId/credentials/registry
```

**Request Body:**
```json
{
  "name": "docker-hub",
  "description": "Docker Hub registry access",
  "registry_url": "https://index.docker.io/v1/",
  "credentials": {
    "username": "myusername",
    "password": "mypassword"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "cred-456",
    "name": "docker-hub",
    "type": "registry",
    "registry_url": "https://index.docker.io/v1/",
    "username": "myusername",
    "created_at": "2024-01-20T10:00:00Z"
  }
}
```

### List Credentials

Get all stored credentials for a workspace.

```http
GET /api/v1/workspaces/:wsId/credentials
```

**Query Parameters:**
- `type` (string) - Filter by credential type (`git`, `registry`)

**Response:**
```json
{
  "data": [
    {
      "id": "cred-123",
      "name": "github-token",
      "type": "git",
      "auth_type": "token",
      "created_at": "2024-01-20T10:00:00Z",
      "last_used": "2024-01-20T14:30:00Z"
    },
    {
      "id": "cred-456", 
      "name": "docker-hub",
      "type": "registry",
      "registry_url": "https://index.docker.io/v1/",
      "username": "myusername",
      "created_at": "2024-01-20T10:00:00Z"
    }
  ]
}
```

### Delete Credential

Delete stored credentials.

```http
DELETE /api/v1/workspaces/:wsId/credentials/:credentialName
```

**Response:**
```json
{
  "data": {
    "message": "Credential deleted successfully",
    "credential_name": "github-token"
  }
}
```

## Provider Configuration

### Get Provider Config

Get CI/CD provider configuration for the workspace.

```http
GET /api/v1/workspaces/:wsId/provider-config
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "provider": "tekton",
    "version": "0.47.0",
    "configuration": {
      "default_timeout": 3600,
      "max_concurrent_pipelines": 10,
      "resource_limits": {
        "cpu": "2",
        "memory": "4Gi"
      },
      "supported_source_types": ["git", "s3", "gcs"],
      "supported_registries": [
        "docker.io",
        "gcr.io", 
        "registry.hexabase.ai"
      ]
    },
    "features": {
      "parallel_execution": true,
      "conditional_steps": true,
      "matrix_builds": true,
      "artifact_caching": true
    }
  }
}
```

### Set Provider Config

Update CI/CD provider configuration.

```http
PUT /api/v1/workspaces/:wsId/provider-config
```

**Request Body:**
```json
{
  "configuration": {
    "default_timeout": 7200,
    "max_concurrent_pipelines": 15,
    "resource_limits": {
      "cpu": "4",
      "memory": "8Gi"
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "configuration": {
      "default_timeout": 7200,
      "max_concurrent_pipelines": 15,
      "resource_limits": {
        "cpu": "4",
        "memory": "8Gi"
      }
    },
    "updated_at": "2024-01-20T15:00:00Z"
  }
}
```

## Providers

### List Providers

Get all available CI/CD providers.

```http
GET /api/v1/providers
```

**Response:**
```json
{
  "data": [
    {
      "id": "tekton",
      "name": "Tekton Pipelines",
      "description": "Cloud-native CI/CD solution",
      "version": "0.47.0",
      "status": "available",
      "features": [
        "kubernetes_native",
        "parallel_execution",
        "artifact_caching",
        "custom_tasks"
      ],
      "supported_languages": [
        "javascript",
        "python",
        "go",
        "java",
        "docker"
      ]
    },
    {
      "id": "jenkins",
      "name": "Jenkins",
      "description": "Extensible automation server",
      "version": "2.401.3",
      "status": "available",
      "features": [
        "plugin_ecosystem",
        "distributed_builds",
        "pipeline_as_code"
      ]
    }
  ]
}
```

## Error Responses

### 400 Bad Request - Invalid Configuration
```json
{
  "error": {
    "code": "INVALID_PIPELINE_CONFIG",
    "message": "Pipeline configuration is invalid",
    "details": {
      "build_steps": "At least one build step is required",
      "source.repository": "Invalid repository URL format"
    }
  }
}
```

### 401 Unauthorized - Invalid Credentials
```json
{
  "error": {
    "code": "INVALID_GIT_CREDENTIALS",
    "message": "Failed to access Git repository with provided credentials",
    "details": {
      "repository": "https://github.com/myorg/private-repo",
      "credential_name": "github-token"
    }
  }
}
```

### 409 Conflict - Pipeline Running
```json
{
  "error": {
    "code": "PIPELINE_CURRENTLY_RUNNING",
    "message": "Cannot modify pipeline while execution is in progress",
    "details": {
      "pipeline_id": "pipe-123",
      "current_run_id": "run-456",
      "status": "running"
    }
  }
}
```

## Webhooks

Pipeline events that trigger webhooks:

- `pipeline.created`
- `pipeline.updated`
- `pipeline.deleted`
- `pipeline.execution.started`
- `pipeline.execution.completed`
- `pipeline.execution.failed`
- `pipeline.step.started`
- `pipeline.step.completed`
- `pipeline.step.failed`

Example webhook payload:
```json
{
  "event": "pipeline.execution.completed",
  "timestamp": "2024-01-20T14:34:32Z",
  "data": {
    "pipeline": {
      "id": "pipe-123",
      "name": "frontend-deploy"
    },
    "execution": {
      "run_id": "run-456",
      "status": "success",
      "duration": "4m 32s",
      "commit": "abc123def456"
    }
  }
}
```

## Best Practices

1. **Source Control**: Use version control for pipeline configurations
2. **Secrets Management**: Store sensitive data in credentials, not environment variables
3. **Testing**: Include comprehensive testing steps in pipelines
4. **Caching**: Use artifact caching to speed up builds
5. **Monitoring**: Set up notifications for pipeline failures
6. **Security**: Regularly rotate credentials and review access permissions