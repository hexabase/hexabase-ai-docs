# Applications API

Applications are the core deployable units in Hexabase.AI workspaces. They support various types including deployments, cronjobs, and serverless functions with comprehensive lifecycle management.

## Base URL

All application endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/workspaces/:wsId/applications
```

## Application Object

```json
{
  "id": "app-123",
  "name": "web-app",
  "workspace_id": "ws-123",
  "project_id": "proj-123",
  "type": "deployment",
  "status": "running",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "spec": {
    "image": "nginx:1.21",
    "replicas": 3,
    "ports": [
      {
        "name": "http",
        "port": 80,
        "target_port": 80,
        "protocol": "TCP"
      }
    ],
    "resources": {
      "requests": {
        "cpu": "100m",
        "memory": "128Mi"
      },
      "limits": {
        "cpu": "500m",
        "memory": "512Mi"
      }
    }
  },
  "runtime": {
    "replicas": {
      "ready": 3,
      "total": 3,
      "available": 3
    },
    "pods": [
      {
        "name": "web-app-7d8c9f5b6-abc12",
        "status": "Running",
        "ready": true,
        "node": "node-1"
      }
    ]
  }
}
```

## Application Management

### List Applications

Get all applications in a workspace.

```http
GET /api/v1/workspaces/:wsId/applications
```

**Query Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20, max: 100)
- `project_id` (string) - Filter by project
- `type` (string) - Filter by application type (`deployment`, `cronjob`, `function`)
- `status` (string) - Filter by status (`running`, `stopped`, `failed`, `pending`)
- `search` (string) - Search by application name
- `sort` (string) - Sort field (`name`, `created_at`, `updated_at`, `status`)
- `order` (string) - Sort order (`asc`, `desc`)

**Response:**
```json
{
  "data": [
    {
      "id": "app-123",
      "name": "web-app",
      "workspace_id": "ws-123",
      "project_id": "proj-123",
      "type": "deployment",
      "status": "running",
      "created_at": "2024-01-01T00:00:00Z",
      "spec": {
        "image": "nginx:1.21",
        "replicas": 3
      },
      "runtime": {
        "replicas": {
          "ready": 3,
          "total": 3
        }
      },
      "project": {
        "id": "proj-123",
        "name": "Frontend Project",
        "namespace": "frontend"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 12,
    "pages": 1
  }
}
```

### Create Application

Deploy a new application to the workspace.

```http
POST /api/v1/workspaces/:wsId/applications
```

**Request Body:**
```json
{
  "name": "web-app",
  "project_id": "proj-123",
  "type": "deployment",
  "spec": {
    "image": "nginx:1.21",
    "replicas": 3,
    "ports": [
      {
        "name": "http",
        "port": 80,
        "target_port": 80,
        "protocol": "TCP"
      }
    ],
    "resources": {
      "requests": {
        "cpu": "100m",
        "memory": "128Mi"
      },
      "limits": {
        "cpu": "500m",
        "memory": "512Mi"
      }
    },
    "env": [
      {
        "name": "NODE_ENV",
        "value": "production"
      },
      {
        "name": "DATABASE_URL",
        "value_from": {
          "secret_key_ref": {
            "name": "db-secret",
            "key": "url"
          }
        }
      }
    ],
    "volumes": [
      {
        "name": "data",
        "persistent_volume_claim": {
          "claim_name": "app-data"
        },
        "mount_path": "/data"
      }
    ]
  },
  "labels": {
    "environment": "production",
    "team": "frontend"
  }
}
```

**Validation:**
- `name` - Required, 3-50 characters, DNS label format
- `project_id` - Required, valid project in workspace
- `type` - Required, one of: `deployment`, `cronjob`, `function`
- `spec` - Required, varies by application type

**Response:**
```json
{
  "data": {
    "id": "app-123",
    "name": "web-app",
    "workspace_id": "ws-123",
    "project_id": "proj-123",
    "type": "deployment",
    "status": "pending",
    "created_at": "2024-01-20T10:00:00Z",
    "spec": {
      "image": "nginx:1.21",
      "replicas": 3,
      "ports": [
        {
          "name": "http",
          "port": 80,
          "target_port": 80,
          "protocol": "TCP"
        }
      ]
    },
    "deployment_id": "deploy-456"
  }
}
```

### Get Application

Get detailed information about a specific application.

```http
GET /api/v1/workspaces/:wsId/applications/:appId
```

**Response:**
```json
{
  "data": {
    "id": "app-123",
    "name": "web-app",
    "workspace_id": "ws-123", 
    "project_id": "proj-123",
    "type": "deployment",
    "status": "running",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "spec": {
      "image": "nginx:1.21",
      "replicas": 3,
      "ports": [
        {
          "name": "http",
          "port": 80,
          "target_port": 80,
          "protocol": "TCP"
        }
      ],
      "resources": {
        "requests": {
          "cpu": "100m",
          "memory": "128Mi"
        },
        "limits": {
          "cpu": "500m", 
          "memory": "512Mi"
        }
      },
      "env": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ]
    },
    "runtime": {
      "replicas": {
        "ready": 3,
        "total": 3,
        "available": 3,
        "unavailable": 0
      },
      "pods": [
        {
          "name": "web-app-7d8c9f5b6-abc12",
          "status": "Running",
          "ready": true,
          "restarts": 0,
          "node": "node-1",
          "created_at": "2024-01-20T10:05:00Z"
        }
      ],
      "services": [
        {
          "name": "web-app-service",
          "type": "ClusterIP",
          "cluster_ip": "10.43.0.123",
          "ports": [
            {
              "port": 80,
              "target_port": 80,
              "protocol": "TCP"
            }
          ]
        }
      ]
    },
    "endpoints": [
      {
        "type": "internal",
        "url": "http://web-app-service.frontend.svc.cluster.local"
      },
      {
        "type": "external",
        "url": "https://web-app-ws123.app.hexabase.ai"
      }
    ],
    "labels": {
      "environment": "production",
      "team": "frontend"
    }
  }
}
```

### Update Application

Update application configuration and trigger redeployment.

```http
PUT /api/v1/workspaces/:wsId/applications/:appId
```

**Request Body:**
```json
{
  "spec": {
    "image": "nginx:1.22",
    "replicas": 5,
    "resources": {
      "requests": {
        "cpu": "200m",
        "memory": "256Mi"
      },
      "limits": {
        "cpu": "1",
        "memory": "1Gi"
      }
    }
  },
  "labels": {
    "environment": "production",
    "team": "frontend",
    "version": "v1.2.0"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "app-123",
    "name": "web-app",
    "status": "updating",
    "updated_at": "2024-01-20T15:00:00Z",
    "deployment_id": "deploy-789"
  }
}
```

### Delete Application

Delete an application and all its resources.

```http
DELETE /api/v1/workspaces/:wsId/applications/:appId
```

**Query Parameters:**
- `force` (boolean) - Force deletion immediately
- `grace_period` (integer) - Grace period in seconds (default: 30)

**Response:**
```json
{
  "data": {
    "message": "Application deletion initiated",
    "task_id": "task-123"
  }
}
```

## Application Operations

### Start Application

Start a stopped application.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/start
```

**Response:**
```json
{
  "data": {
    "id": "app-123",
    "status": "starting",
    "operation_id": "op-123"
  }
}
```

### Stop Application

Stop a running application (scale to 0 replicas).

```http
POST /api/v1/workspaces/:wsId/applications/:appId/stop
```

**Response:**
```json
{
  "data": {
    "id": "app-123", 
    "status": "stopping",
    "operation_id": "op-456"
  }
}
```

### Restart Application

Restart an application by rolling out new pods.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/restart
```

**Response:**
```json
{
  "data": {
    "id": "app-123",
    "status": "restarting",
    "operation_id": "op-789"
  }
}
```

### Scale Application

Scale application replicas up or down.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/scale
```

**Request Body:**
```json
{
  "replicas": 5
}
```

**Response:**
```json
{
  "data": {
    "id": "app-123",
    "previous_replicas": 3,
    "target_replicas": 5,
    "status": "scaling",
    "operation_id": "op-321"
  }
}
```

## Pod Management

### List Pods

Get all pods for an application.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/pods
```

**Query Parameters:**
- `status` (string) - Filter by pod status
- `node` (string) - Filter by node name

**Response:**
```json
{
  "data": [
    {
      "name": "web-app-7d8c9f5b6-abc12",
      "status": "Running",
      "ready": true,
      "restarts": 0,
      "node": "node-1",
      "created_at": "2024-01-20T10:05:00Z",
      "ip": "10.42.0.123",
      "resources": {
        "cpu": "0.1",
        "memory": "128Mi"
      },
      "containers": [
        {
          "name": "nginx",
          "image": "nginx:1.21",
          "ready": true,
          "restart_count": 0
        }
      ]
    }
  ]
}
```

### Restart Pod

Restart a specific pod.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/pods/:podName/restart
```

**Response:**
```json
{
  "data": {
    "message": "Pod restart initiated",
    "pod_name": "web-app-7d8c9f5b6-abc12",
    "operation_id": "op-654"
  }
}
```

## Logs

### Get Application Logs

Get logs from application pods.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/logs
```

**Query Parameters:**
- `container` (string) - Specific container name
- `pod` (string) - Specific pod name
- `since` (string) - Time duration (e.g., "1h", "30m")
- `lines` (integer) - Number of lines to retrieve (default: 100)
- `timestamps` (boolean) - Include timestamps

**Response:**
```json
{
  "data": {
    "logs": [
      {
        "timestamp": "2024-01-20T15:30:00Z",
        "pod": "web-app-7d8c9f5b6-abc12",
        "container": "nginx",
        "message": "GET / HTTP/1.1 200"
      }
    ],
    "total_lines": 150
  }
}
```

### Stream Application Logs

Stream live logs from application pods.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/logs/stream
```

**Query Parameters:**
- Same as get logs endpoint
- `follow` (boolean) - Follow log output (default: true)

**Response:** Server-Sent Events (SSE) stream
```
data: {"timestamp":"2024-01-20T15:30:00Z","pod":"web-app-7d8c9f5b6-abc12","message":"New request received"}

data: {"timestamp":"2024-01-20T15:30:01Z","pod":"web-app-7d8c9f5b6-def34","message":"Processing request"}
```

## Monitoring

### Get Application Metrics

Get performance metrics for the application.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/metrics
```

**Query Parameters:**
- `period` (string) - Time period (`5m`, `1h`, `6h`, `24h`, `7d`)
- `metric` (string) - Specific metric to retrieve

**Response:**
```json
{
  "data": {
    "cpu": {
      "current": "0.15 cores",
      "average": "0.12 cores",
      "peak": "0.25 cores",
      "series": [
        {
          "timestamp": "2024-01-20T15:00:00Z",
          "value": 0.12
        }
      ]
    },
    "memory": {
      "current": "256Mi",
      "average": "220Mi", 
      "peak": "310Mi",
      "series": [
        {
          "timestamp": "2024-01-20T15:00:00Z",
          "value": 220
        }
      ]
    },
    "network": {
      "requests_per_second": 45.2,
      "bytes_in_per_second": 102400,
      "bytes_out_per_second": 512000
    }
  }
}
```

### Get Application Events

Get Kubernetes events related to the application.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/events
```

**Query Parameters:**
- `type` (string) - Event type (`Normal`, `Warning`)
- `since` (string) - Time duration

**Response:**
```json
{
  "data": [
    {
      "type": "Normal",
      "reason": "Created",
      "message": "Created pod: web-app-7d8c9f5b6-abc12",
      "source": "deployment-controller",
      "first_timestamp": "2024-01-20T10:05:00Z",
      "last_timestamp": "2024-01-20T10:05:00Z",
      "count": 1
    }
  ]
}
```

## Network Configuration

### Update Network Configuration

Configure application networking including ingress and load balancing.

```http
PUT /api/v1/workspaces/:wsId/applications/:appId/network
```

**Request Body:**
```json
{
  "ingress": {
    "enabled": true,
    "host": "web-app.example.com",
    "path": "/",
    "tls": {
      "enabled": true,
      "secret_name": "web-app-tls"
    },
    "annotations": {
      "nginx.ingress.kubernetes.io/rewrite-target": "/"
    }
  },
  "service": {
    "type": "ClusterIP",
    "session_affinity": "ClientIP",
    "ports": [
      {
        "name": "http",
        "port": 80,
        "target_port": 8080
      }
    ]
  }
}
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "ingress": {
      "enabled": true,
      "host": "web-app.example.com",
      "url": "https://web-app.example.com"
    },
    "service": {
      "type": "ClusterIP",
      "cluster_ip": "10.43.0.124"
    },
    "updated_at": "2024-01-20T15:30:00Z"
  }
}
```

### Get Application Endpoints

Get all endpoints where the application is accessible.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/endpoints
```

**Response:**
```json
{
  "data": [
    {
      "type": "internal",
      "name": "ClusterIP Service", 
      "url": "http://web-app-service.frontend.svc.cluster.local",
      "ports": [80]
    },
    {
      "type": "external",
      "name": "Ingress",
      "url": "https://web-app.example.com",
      "ports": [443]
    },
    {
      "type": "load_balancer",
      "name": "Load Balancer",
      "url": "http://203.0.113.123:80",
      "ports": [80]
    }
  ]
}
```

## Node Operations

### Update Node Affinity

Configure which nodes the application can be scheduled on.

```http
PUT /api/v1/workspaces/:wsId/applications/:appId/node-affinity
```

**Request Body:**
```json
{
  "node_selector": {
    "node-type": "high-memory",
    "zone": "us-west-2a"
  },
  "affinity": {
    "required_during_scheduling": {
      "node_selector_terms": [
        {
          "match_expressions": [
            {
              "key": "node-type",
              "operator": "In",
              "values": ["high-memory", "compute-optimized"]
            }
          ]
        }
      ]
    },
    "preferred_during_scheduling": [
      {
        "weight": 100,
        "preference": {
          "match_expressions": [
            {
              "key": "zone",
              "operator": "In", 
              "values": ["us-west-2a"]
            }
          ]
        }
      }
    ]
  },
  "tolerations": [
    {
      "key": "dedicated",
      "operator": "Equal",
      "value": "gpu",
      "effect": "NoSchedule"
    }
  ]
}
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "node_affinity_updated": true,
    "restart_required": true,
    "updated_at": "2024-01-20T15:45:00Z"
  }
}
```

### Migrate Application to Node

Migrate application pods to specific nodes.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/migrate
```

**Request Body:**
```json
{
  "target_nodes": ["node-1", "node-2"],
  "strategy": "rolling",
  "max_unavailable": "25%"
}
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "migration_id": "migration-123",
    "status": "in_progress",
    "target_nodes": ["node-1", "node-2"]
  }
}
```

## CronJob Operations

For applications of type `cronjob`:

### Update CronJob Schedule

Update the schedule for a cronjob application.

```http
PUT /api/v1/workspaces/:wsId/applications/:appId/schedule
```

**Request Body:**
```json
{
  "schedule": "0 2 * * *",
  "timezone": "America/New_York",
  "suspend": false,
  "concurrency_policy": "Forbid",
  "starting_deadline_seconds": 60,
  "successful_jobs_history_limit": 3,
  "failed_jobs_history_limit": 1
}
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "schedule": "0 2 * * *",
    "timezone": "America/New_York",
    "next_run": "2024-01-21T02:00:00Z",
    "updated_at": "2024-01-20T15:00:00Z"
  }
}
```

### Trigger CronJob

Manually trigger a cronjob execution.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/trigger
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "job_id": "job-123",
    "triggered_at": "2024-01-20T15:30:00Z"
  }
}
```

### Get CronJob Executions

Get execution history for a cronjob.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/executions
```

**Query Parameters:**
- `status` (string) - Filter by status (`succeeded`, `failed`, `running`)
- `limit` (integer) - Number of executions to return

**Response:**
```json
{
  "data": [
    {
      "job_id": "job-123",
      "status": "succeeded",
      "started_at": "2024-01-20T02:00:00Z",
      "completed_at": "2024-01-20T02:05:30Z",
      "duration": "5m30s",
      "pod_name": "cronjob-app-123-27890123-abc12"
    }
  ]
}
```

### Get CronJob Status

Get current status and next scheduled run.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/cronjob-status
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "schedule": "0 2 * * *",
    "suspended": false,
    "last_run": "2024-01-20T02:00:00Z",
    "next_run": "2024-01-21T02:00:00Z",
    "active_jobs": 0,
    "last_successful_run": "2024-01-20T02:00:00Z",
    "last_failed_run": null
  }
}
```

## Function Operations

For applications of type `function`:

### Deploy Function Version

Deploy a new version of a serverless function.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/versions
```

**Request Body:**
```json
{
  "source_code": "base64-encoded-zip-file",
  "runtime": "nodejs18",
  "handler": "index.handler",
  "timeout": 30,
  "memory": 256,
  "environment": {
    "NODE_ENV": "production",
    "API_URL": "https://api.example.com"
  }
}
```

**Response:**
```json
{
  "data": {
    "version_id": "v-123",
    "application_id": "app-123",
    "version": "v1.2.0",
    "status": "deploying",
    "created_at": "2024-01-20T15:00:00Z"
  }
}
```

### Get Function Versions

List all versions of a function.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/versions
```

**Response:**
```json
{
  "data": [
    {
      "version_id": "v-123",
      "version": "v1.2.0",
      "status": "active",
      "is_active": true,
      "created_at": "2024-01-20T15:00:00Z",
      "size": "1.2MB"
    }
  ]
}
```

### Set Active Function Version

Set which version of the function should handle requests.

```http
PUT /api/v1/workspaces/:wsId/applications/:appId/versions/:versionId/active
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "previous_active_version": "v-122",
    "new_active_version": "v-123",
    "updated_at": "2024-01-20T15:30:00Z"
  }
}
```

### Invoke Function

Invoke a serverless function synchronously.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/invoke
```

**Request Body:**
```json
{
  "payload": {
    "name": "John",
    "message": "Hello World"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```

**Response:**
```json
{
  "data": {
    "invocation_id": "inv-123",
    "status_code": 200,
    "response": {
      "message": "Hello John!"
    },
    "duration": 245,
    "memory_used": 45,
    "logs": [
      "Function started",
      "Processing request",
      "Function completed"
    ]
  }
}
```

### Get Function Invocations

Get invocation history and metrics.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/invocations
```

**Query Parameters:**
- `status` (string) - Filter by status
- `since` (string) - Time duration
- `limit` (integer) - Number of invocations

**Response:**
```json
{
  "data": [
    {
      "invocation_id": "inv-123",
      "status": "success",
      "status_code": 200,
      "duration": 245,
      "memory_used": 45,
      "timestamp": "2024-01-20T15:30:00Z"
    }
  ],
  "metrics": {
    "total_invocations": 1543,
    "success_rate": 99.2,
    "average_duration": 267,
    "error_rate": 0.8
  }
}
```

### Get Function Events

Get function-specific events and logs.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/function-events
```

**Response:**
```json
{
  "data": [
    {
      "event_id": "evt-123",
      "type": "function.invoked",
      "timestamp": "2024-01-20T15:30:00Z",
      "details": {
        "invocation_id": "inv-123",
        "duration": 245,
        "status_code": 200
      }
    }
  ]
}
```

## Error Responses

### 400 Bad Request - Invalid Specification
```json
{
  "error": {
    "code": "INVALID_APPLICATION_SPEC",
    "message": "Application specification is invalid",
    "details": {
      "image": "Invalid image format",
      "resources.limits.cpu": "CPU limit cannot be less than request"
    }
  }
}
```

### 409 Conflict - Name Already Exists
```json
{
  "error": {
    "code": "APPLICATION_NAME_EXISTS",
    "message": "Application name already exists in project",
    "details": {
      "name": "web-app",
      "project_id": "proj-123"
    }
  }
}
```

### 422 Unprocessable Entity - Resource Constraints
```json
{
  "error": {
    "code": "INSUFFICIENT_RESOURCES",
    "message": "Insufficient resources to deploy application",
    "details": {
      "requested_cpu": "4 cores",
      "available_cpu": "2 cores",
      "requested_memory": "8Gi",
      "available_memory": "4Gi"
    }
  }
}
```

## Webhooks

Application events that trigger webhooks:

- `application.created`
- `application.updated` 
- `application.deleted`
- `application.started`
- `application.stopped`
- `application.scaled`
- `application.deployment.succeeded`
- `application.deployment.failed`
- `application.pod.created`
- `application.pod.failed`
- `application.cronjob.executed`
- `application.function.invoked`

## Best Practices

1. **Resource Limits**: Always set appropriate CPU and memory limits
2. **Health Checks**: Configure readiness and liveness probes
3. **Secrets Management**: Use Kubernetes secrets for sensitive data
4. **Scaling**: Monitor metrics and configure autoscaling policies
5. **Monitoring**: Set up comprehensive logging and monitoring