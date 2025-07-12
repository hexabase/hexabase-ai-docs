# Functions API

Serverless functions provide event-driven, auto-scaling compute capabilities without infrastructure management. Functions are executed in response to HTTP requests, scheduled events, or other triggers.

## Base URL

All function endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/workspaces/:wsId/functions
```

## Function Object

```json
{
  "id": "func-123",
  "name": "data-processor",
  "workspace_id": "ws-123",
  "status": "active",
  "runtime": "nodejs18",
  "handler": "index.handler",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "configuration": {
    "timeout": 30,
    "memory": 256,
    "max_concurrency": 100,
    "environment": {
      "NODE_ENV": "production",
      "API_URL": "https://api.example.com"
    }
  },
  "active_version": {
    "id": "ver-456",
    "version": "v1.2.0",
    "deployed_at": "2024-01-20T10:00:00Z",
    "size": "2.1MB"
  },
  "metrics": {
    "invocations_last_24h": 1543,
    "average_duration_ms": 245,
    "error_rate_percentage": 0.2
  }
}
```

## Function Management

### Create Function

Create a new serverless function.

```http
POST /api/v1/workspaces/:wsId/functions
```

**Request Body:**
```json
{
  "name": "data-processor",
  "description": "Processes incoming data events",
  "runtime": "nodejs18",
  "handler": "index.handler",
  "source_code": "UEsDBAoAAAAAAA...", // base64-encoded zip file
  "configuration": {
    "timeout": 30,
    "memory": 256,
    "max_concurrency": 100,
    "environment": {
      "NODE_ENV": "production",
      "DATABASE_URL": {
        "from_secret": "db-credentials",
        "key": "url"
      }
    }
  },
  "labels": {
    "team": "data",
    "environment": "production"
  }
}
```

**Validation:**
- `name` - Required, 3-50 characters, DNS label format
- `runtime` - Required, supported: `nodejs18`, `python39`, `go119`, `java17`
- `handler` - Required, entry point function
- `source_code` - Required, base64-encoded zip file

**Response:**
```json
{
  "data": {
    "id": "func-123",
    "name": "data-processor",
    "workspace_id": "ws-123",
    "status": "deploying",
    "runtime": "nodejs18",
    "handler": "index.handler",
    "created_at": "2024-01-20T10:00:00Z",
    "deployment_id": "deploy-789"
  }
}
```

### List Functions

Get all functions in a workspace.

```http
GET /api/v1/workspaces/:wsId/functions
```

**Query Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20, max: 100)
- `status` (string) - Filter by status (`active`, `inactive`, `deploying`, `error`)
- `runtime` (string) - Filter by runtime
- `search` (string) - Search by function name
- `sort` (string) - Sort field (`name`, `created_at`, `invocations`)
- `order` (string) - Sort order (`asc`, `desc`)

**Response:**
```json
{
  "data": [
    {
      "id": "func-123",
      "name": "data-processor",
      "workspace_id": "ws-123",
      "status": "active",
      "runtime": "nodejs18",
      "created_at": "2024-01-01T00:00:00Z",
      "active_version": {
        "version": "v1.2.0",
        "deployed_at": "2024-01-20T10:00:00Z"
      },
      "metrics": {
        "invocations_last_24h": 1543,
        "error_rate_percentage": 0.2
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

### Get Function

Get detailed information about a specific function.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId
```

**Response:**
```json
{
  "data": {
    "id": "func-123",
    "name": "data-processor",
    "description": "Processes incoming data events",
    "workspace_id": "ws-123",
    "status": "active",
    "runtime": "nodejs18",
    "handler": "index.handler",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "configuration": {
      "timeout": 30,
      "memory": 256,
      "max_concurrency": 100,
      "environment": {
        "NODE_ENV": "production",
        "API_URL": "https://api.example.com"
      }
    },
    "active_version": {
      "id": "ver-456",
      "version": "v1.2.0",
      "deployed_at": "2024-01-20T10:00:00Z",
      "size": "2.1MB",
      "checksum": "sha256:abc123..."
    },
    "endpoints": [
      {
        "type": "http",
        "url": "https://func-data-processor-ws123.func.hexabase.ai",
        "method": "POST"
      }
    ],
    "triggers": [
      {
        "id": "trigger-123",
        "type": "http",
        "enabled": true
      },
      {
        "id": "trigger-456",
        "type": "schedule",
        "schedule": "0 */6 * * *",
        "enabled": true
      }
    ],
    "metrics": {
      "invocations_last_24h": 1543,
      "average_duration_ms": 245,
      "error_rate_percentage": 0.2,
      "cold_starts_percentage": 5.1
    },
    "labels": {
      "team": "data",
      "environment": "production"
    }
  }
}
```

### Update Function

Update function configuration.

```http
PUT /api/v1/workspaces/:wsId/functions/:functionId
```

**Request Body:**
```json
{
  "description": "Updated function description",
  "configuration": {
    "timeout": 60,
    "memory": 512,
    "max_concurrency": 200,
    "environment": {
      "NODE_ENV": "production",
      "API_URL": "https://api-v2.example.com",
      "DEBUG": "false"
    }
  },
  "labels": {
    "team": "data",
    "environment": "production",
    "version": "v2"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "func-123",
    "name": "data-processor",
    "updated_at": "2024-01-20T15:00:00Z",
    "configuration": {
      "timeout": 60,
      "memory": 512,
      "max_concurrency": 200
    }
  }
}
```

### Delete Function

Delete a function and all its versions.

```http
DELETE /api/v1/workspaces/:wsId/functions/:functionId
```

**Query Parameters:**
- `force` (boolean) - Force deletion even if triggers are attached

**Response:**
```json
{
  "data": {
    "message": "Function deletion initiated",
    "function_id": "func-123"
  }
}
```

## Version Management

### Deploy Version

Deploy a new version of a function.

```http
POST /api/v1/workspaces/:wsId/functions/:functionId/versions
```

**Request Body:**
```json
{
  "source_code": "UEsDBAoAAAAAAA...", // base64-encoded zip file
  "version": "v1.3.0",
  "configuration": {
    "timeout": 45,
    "memory": 512,
    "environment": {
      "NODE_ENV": "production",
      "FEATURE_FLAG": "enabled"
    }
  },
  "deploy_immediately": false
}
```

**Response:**
```json
{
  "data": {
    "id": "ver-789",
    "function_id": "func-123",
    "version": "v1.3.0",
    "status": "building",
    "created_at": "2024-01-20T15:00:00Z",
    "build_id": "build-123"
  }
}
```

### List Versions

Get all versions of a function.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId/versions
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `status` (string) - Filter by status

**Response:**
```json
{
  "data": [
    {
      "id": "ver-789",
      "version": "v1.3.0",
      "status": "active",
      "is_active": false,
      "created_at": "2024-01-20T15:00:00Z",
      "deployed_at": "2024-01-20T15:05:00Z",
      "size": "2.3MB",
      "checksum": "sha256:def456...",
      "build_duration": "45s",
      "invocations": 0
    },
    {
      "id": "ver-456",
      "version": "v1.2.0",
      "status": "active",
      "is_active": true,
      "created_at": "2024-01-20T10:00:00Z",
      "deployed_at": "2024-01-20T10:02:00Z",
      "size": "2.1MB",
      "invocations": 1543
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

### Get Version

Get detailed information about a specific version.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId/versions/:versionId
```

**Response:**
```json
{
  "data": {
    "id": "ver-456",
    "function_id": "func-123",
    "version": "v1.2.0",
    "status": "active",
    "is_active": true,
    "created_at": "2024-01-20T10:00:00Z",
    "deployed_at": "2024-01-20T10:02:00Z",
    "size": "2.1MB",
    "checksum": "sha256:abc123...",
    "build_duration": "32s",
    "configuration": {
      "timeout": 30,
      "memory": 256,
      "environment": {
        "NODE_ENV": "production"
      }
    },
    "metrics": {
      "invocations": 1543,
      "average_duration_ms": 245,
      "error_rate_percentage": 0.2,
      "last_invocation": "2024-01-20T14:30:00Z"
    }
  }
}
```

### Set Active Version

Set which version should handle new invocations.

```http
PUT /api/v1/workspaces/:wsId/functions/:functionId/versions/:versionId/active
```

**Response:**
```json
{
  "data": {
    "function_id": "func-123",
    "previous_active_version": "ver-456",
    "new_active_version": "ver-789",
    "updated_at": "2024-01-20T15:30:00Z"
  }
}
```

### Rollback Version

Rollback to a previous version.

```http
POST /api/v1/workspaces/:wsId/functions/:functionId/rollback
```

**Request Body:**
```json
{
  "target_version_id": "ver-456",
  "reason": "Critical bug in current version"
}
```

**Response:**
```json
{
  "data": {
    "function_id": "func-123",
    "rolled_back_from": "ver-789",
    "rolled_back_to": "ver-456",
    "rollback_id": "rollback-123",
    "timestamp": "2024-01-20T16:00:00Z"
  }
}
```

## Trigger Management

### Create Trigger

Create a new trigger for a function.

```http
POST /api/v1/workspaces/:wsId/functions/:functionId/triggers
```

**Request Body:**
```json
{
  "type": "schedule",
  "name": "daily-cleanup",
  "enabled": true,
  "configuration": {
    "schedule": "0 2 * * *",
    "timezone": "America/New_York",
    "payload": {
      "action": "cleanup",
      "target": "temp_files"
    }
  }
}
```

**Trigger Types:**
- `http` - HTTP requests
- `schedule` - Cron-based scheduling
- `webhook` - External webhook events
- `queue` - Message queue events

**Response:**
```json
{
  "data": {
    "id": "trigger-789",
    "function_id": "func-123",
    "type": "schedule",
    "name": "daily-cleanup",
    "enabled": true,
    "created_at": "2024-01-20T15:00:00Z",
    "configuration": {
      "schedule": "0 2 * * *",
      "timezone": "America/New_York",
      "next_run": "2024-01-21T02:00:00Z"
    }
  }
}
```

### List Triggers

Get all triggers for a function.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId/triggers
```

**Response:**
```json
{
  "data": [
    {
      "id": "trigger-123",
      "type": "http",
      "name": "api-endpoint",
      "enabled": true,
      "created_at": "2024-01-01T00:00:00Z",
      "configuration": {
        "method": "POST",
        "path": "/api/process"
      },
      "metrics": {
        "invocations_last_24h": 1543
      }
    },
    {
      "id": "trigger-789",
      "type": "schedule",
      "name": "daily-cleanup",
      "enabled": true,
      "created_at": "2024-01-20T15:00:00Z",
      "configuration": {
        "schedule": "0 2 * * *",
        "next_run": "2024-01-21T02:00:00Z"
      }
    }
  ]
}
```

### Update Trigger

Update trigger configuration.

```http
PUT /api/v1/workspaces/:wsId/functions/:functionId/triggers/:triggerId
```

**Request Body:**
```json
{
  "enabled": false,
  "configuration": {
    "schedule": "0 4 * * *",
    "timezone": "America/New_York"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "trigger-789",
    "enabled": false,
    "updated_at": "2024-01-20T16:00:00Z",
    "configuration": {
      "schedule": "0 4 * * *",
      "next_run": "2024-01-21T04:00:00Z"
    }
  }
}
```

### Delete Trigger

Delete a trigger.

```http
DELETE /api/v1/workspaces/:wsId/functions/:functionId/triggers/:triggerId
```

**Response:**
```json
{
  "data": {
    "message": "Trigger deleted successfully",
    "trigger_id": "trigger-789"
  }
}
```

## Function Invocation

### Invoke Function

Invoke a function synchronously.

```http
POST /api/v1/workspaces/:wsId/functions/:functionId/invoke
```

**Request Body:**
```json
{
  "payload": {
    "user_id": "user-123",
    "action": "process_data",
    "data": {
      "items": ["item1", "item2", "item3"]
    }
  },
  "headers": {
    "Content-Type": "application/json",
    "X-Custom-Header": "value"
  },
  "version_id": "ver-456" // Optional, defaults to active version
}
```

**Response:**
```json
{
  "data": {
    "invocation_id": "inv-123",
    "function_id": "func-123",
    "version_id": "ver-456",
    "status": "success",
    "status_code": 200,
    "response": {
      "processed_items": 3,
      "result": "success",
      "timestamp": "2024-01-20T15:30:00Z"
    },
    "execution": {
      "duration_ms": 245,
      "memory_used_mb": 45,
      "cold_start": false,
      "timeout": false
    },
    "logs": [
      "Function started",
      "Processing 3 items",
      "All items processed successfully",
      "Function completed"
    ],
    "invoked_at": "2024-01-20T15:30:00Z",
    "completed_at": "2024-01-20T15:30:00Z"
  }
}
```

### Invoke Function Asynchronously

Invoke a function asynchronously for long-running tasks.

```http
POST /api/v1/workspaces/:wsId/functions/:functionId/invoke-async
```

**Request Body:**
```json
{
  "payload": {
    "batch_id": "batch-456",
    "operation": "bulk_process",
    "items": ["item1", "item2", "..."]
  },
  "callback_url": "https://myapp.com/webhook/function-complete"
}
```

**Response:**
```json
{
  "data": {
    "invocation_id": "inv-456",
    "function_id": "func-123",
    "status": "running",
    "invoked_at": "2024-01-20T15:30:00Z",
    "status_url": "/functions/func-123/invocations/inv-456/status"
  }
}
```

### Get Invocation Status

Get the status of an asynchronous invocation.

```http
GET /api/v1/workspaces/:wsId/functions/invocations/:invocationId
```

**Response:**
```json
{
  "data": {
    "invocation_id": "inv-456",
    "function_id": "func-123",
    "status": "completed",
    "status_code": 200,
    "response": {
      "processed_items": 1000,
      "result": "success"
    },
    "execution": {
      "duration_ms": 45000,
      "memory_used_mb": 128,
      "cold_start": false
    },
    "invoked_at": "2024-01-20T15:30:00Z",
    "completed_at": "2024-01-20T16:15:00Z"
  }
}
```

### List Invocations

Get invocation history for a function.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId/invocations
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `status` (string) - Filter by status (`success`, `error`, `timeout`)
- `since` (string) - Time duration (`1h`, `24h`, `7d`)
- `version_id` (string) - Filter by version

**Response:**
```json
{
  "data": [
    {
      "invocation_id": "inv-123",
      "status": "success",
      "status_code": 200,
      "duration_ms": 245,
      "memory_used_mb": 45,
      "cold_start": false,
      "invoked_at": "2024-01-20T15:30:00Z",
      "version": "v1.2.0",
      "trigger_type": "http"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 1543,
    "pages": 78
  },
  "metrics": {
    "total_invocations": 1543,
    "success_rate": 99.8,
    "average_duration_ms": 267,
    "error_rate": 0.2,
    "cold_start_rate": 5.1
  }
}
```

## Monitoring

### Get Function Logs

Get execution logs for a function.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId/logs
```

**Query Parameters:**
- `invocation_id` (string) - Specific invocation
- `since` (string) - Time duration
- `level` (string) - Log level (`info`, `warn`, `error`)
- `limit` (integer) - Number of log entries

**Response:**
```json
{
  "data": [
    {
      "timestamp": "2024-01-20T15:30:00Z",
      "level": "info",
      "message": "Function started",
      "invocation_id": "inv-123",
      "request_id": "req-456"
    },
    {
      "timestamp": "2024-01-20T15:30:00.245Z",
      "level": "info",
      "message": "Function completed successfully",
      "invocation_id": "inv-123",
      "request_id": "req-456"
    }
  ]
}
```

### Get Function Metrics

Get performance metrics for a function.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId/metrics
```

**Query Parameters:**
- `period` (string) - Time period (`1h`, `6h`, `24h`, `7d`, `30d`)
- `metric` (string) - Specific metric

**Response:**
```json
{
  "data": {
    "invocations": {
      "total": 1543,
      "success": 1540,
      "errors": 3,
      "timeouts": 0,
      "series": [
        {
          "timestamp": "2024-01-20T15:00:00Z",
          "value": 145
        }
      ]
    },
    "duration": {
      "average_ms": 245,
      "p50_ms": 220,
      "p95_ms": 450,
      "p99_ms": 680,
      "max_ms": 890
    },
    "memory": {
      "average_mb": 45,
      "peak_mb": 78
    },
    "cold_starts": {
      "count": 78,
      "percentage": 5.1,
      "average_duration_ms": 1200
    },
    "errors": {
      "by_type": {
        "timeout": 0,
        "runtime_error": 2,
        "out_of_memory": 1
      }
    }
  }
}
```

### Get Function Events

Get function-related events.

```http
GET /api/v1/workspaces/:wsId/functions/:functionId/events
```

**Response:**
```json
{
  "data": [
    {
      "event_id": "evt-123",
      "type": "function.deployed",
      "timestamp": "2024-01-20T10:00:00Z",
      "details": {
        "version": "v1.2.0",
        "deployment_duration": "32s"
      }
    },
    {
      "event_id": "evt-456",
      "type": "function.invocation.error",
      "timestamp": "2024-01-20T14:15:00Z",
      "details": {
        "invocation_id": "inv-789",
        "error": "Runtime error: undefined variable"
      }
    }
  ]
}
```

## Provider Information

### Get Provider Capabilities

Get information about the function runtime provider capabilities.

```http
GET /api/v1/workspaces/:wsId/functions/provider/capabilities
```

**Response:**
```json
{
  "data": {
    "provider": "hexabase-functions",
    "version": "1.2.0",
    "supported_runtimes": [
      {
        "name": "nodejs18",
        "display_name": "Node.js 18",
        "version": "18.17.0",
        "architecture": ["x86_64", "arm64"]
      },
      {
        "name": "python39",
        "display_name": "Python 3.9",
        "version": "3.9.17",
        "architecture": ["x86_64", "arm64"]
      }
    ],
    "limits": {
      "max_timeout_seconds": 900,
      "max_memory_mb": 3008,
      "max_package_size_mb": 250,
      "max_concurrent_executions": 1000
    },
    "features": [
      "auto_scaling",
      "cold_start_optimization",
      "vpc_connectivity",
      "custom_domains",
      "environment_variables",
      "secrets_management"
    ]
  }
}
```

### Get Provider Health

Get the health status of the function runtime provider.

```http
GET /api/v1/workspaces/:wsId/functions/provider/health
```

**Response:**
```json
{
  "data": {
    "status": "healthy",
    "version": "1.2.0",
    "regions": [
      {
        "name": "us-west-2",
        "status": "healthy",
        "capacity": "normal"
      }
    ],
    "metrics": {
      "average_cold_start_ms": 1200,
      "success_rate": 99.95,
      "capacity_utilization": 45.2
    },
    "last_updated": "2024-01-20T15:30:00Z"
  }
}
```

## Error Responses

### 400 Bad Request - Invalid Runtime
```json
{
  "error": {
    "code": "INVALID_RUNTIME",
    "message": "Unsupported runtime specified",
    "details": {
      "runtime": "nodejs16",
      "supported_runtimes": ["nodejs18", "python39", "go119", "java17"]
    }
  }
}
```

### 413 Payload Too Large - Package Size Exceeded
```json
{
  "error": {
    "code": "PACKAGE_SIZE_EXCEEDED",
    "message": "Function package size exceeds maximum limit",
    "details": {
      "package_size_mb": 300,
      "max_size_mb": 250
    }
  }
}
```

### 429 Too Many Requests - Concurrency Limit
```json
{
  "error": {
    "code": "CONCURRENCY_LIMIT_EXCEEDED",
    "message": "Maximum concurrent executions exceeded",
    "details": {
      "current_executions": 1000,
      "max_concurrent_executions": 1000
    }
  }
}
```

## Webhooks

Function events that trigger webhooks:

- `function.created`
- `function.updated`
- `function.deleted`
- `function.version.deployed`
- `function.version.activated`
- `function.invocation.completed`
- `function.invocation.failed`
- `function.trigger.created`
- `function.trigger.updated`
- `function.trigger.deleted`

## Best Practices

1. **Package Size**: Keep function packages small for faster cold starts
2. **Memory Allocation**: Right-size memory based on actual usage
3. **Error Handling**: Implement proper error handling and logging
4. **Monitoring**: Set up alerts for error rates and performance metrics
5. **Versioning**: Use semantic versioning for function deployments