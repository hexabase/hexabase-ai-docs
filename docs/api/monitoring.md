# Monitoring API

The Monitoring API provides comprehensive observability for workspaces, applications, and infrastructure through metrics collection, alerting, and health monitoring capabilities.

## Base URL

All monitoring endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/workspaces/:wsId/monitoring
```

## Metrics Object

```json
{
  "metric": "cpu_usage",
  "workspace_id": "ws-123",
  "application_id": "app-123",
  "timestamp": "2024-01-20T15:00:00Z",
  "value": 45.2,
  "unit": "percentage",
  "labels": {
    "pod": "web-app-7d8c9f5b6-abc12",
    "container": "nginx",
    "node": "node-1"
  }
}
```

## Alert Object

```json
{
  "id": "alert-123",
  "workspace_id": "ws-123",
  "name": "High CPU Usage",
  "type": "threshold",
  "severity": "warning",
  "status": "firing",
  "description": "CPU usage has exceeded 80% for 5 minutes",
  "created_at": "2024-01-20T14:00:00Z",
  "fired_at": "2024-01-20T15:00:00Z",
  "resolved_at": null,
  "condition": {
    "metric": "cpu_usage",
    "operator": "greater_than",
    "threshold": 80,
    "duration": "5m",
    "aggregation": "avg"
  },
  "targets": {
    "resource_type": "application",
    "resource_ids": ["app-123"],
    "labels": {
      "environment": "production"
    }
  },
  "notifications": [
    {
      "type": "email",
      "destination": "ops@example.com",
      "sent_at": "2024-01-20T15:01:00Z"
    }
  ]
}
```

## Metrics

### Get Workspace Metrics

Get performance metrics for a workspace.

```http
GET /api/v1/workspaces/:wsId/monitoring/metrics
```

**Query Parameters:**
- `metric` (string) - Specific metric name
- `period` (string) - Time period (`5m`, `1h`, `6h`, `24h`, `7d`, `30d`)
- `step` (string) - Data resolution (`1m`, `5m`, `1h`)
- `start` (string) - Start time (ISO 8601)
- `end` (string) - End time (ISO 8601)
- `resource_type` (string) - Filter by resource type (`application`, `node`)
- `resource_id` (string) - Filter by specific resource ID
- `labels` (string) - Label filters (e.g., `environment=production`)

**Available Metrics:**
- `cpu_usage` - CPU utilization percentage
- `memory_usage` - Memory utilization percentage  
- `storage_usage` - Storage utilization percentage
- `network_in` - Network bytes received
- `network_out` - Network bytes transmitted
- `pod_count` - Number of running pods
- `request_rate` - HTTP requests per second
- `response_time` - Average response time
- `error_rate` - Error rate percentage

**Response:**
```json
{
  "data": {
    "metric": "cpu_usage",
    "period": "1h",
    "step": "5m",
    "workspace_id": "ws-123",
    "series": [
      {
        "labels": {
          "application": "web-app",
          "pod": "web-app-7d8c9f5b6-abc12"
        },
        "values": [
          {
            "timestamp": "2024-01-20T15:00:00Z",
            "value": 45.2
          },
          {
            "timestamp": "2024-01-20T15:05:00Z",
            "value": 48.7
          }
        ]
      }
    ],
    "summary": {
      "current": 48.7,
      "average": 46.9,
      "peak": 52.1,
      "minimum": 41.3
    }
  }
}
```

### Get Real-time Metrics

Get current real-time metrics for a workspace.

```http
GET /api/v1/workspaces/:wsId/monitoring/metrics/realtime
```

**Query Parameters:**
- `metrics` (string) - Comma-separated list of metrics
- `resource_type` (string) - Filter by resource type
- `resource_id` (string) - Filter by specific resource

**Response:**
```json
{
  "data": {
    "timestamp": "2024-01-20T15:30:00Z",
    "workspace_id": "ws-123",
    "metrics": {
      "cpu_usage": {
        "value": 48.7,
        "unit": "percentage",
        "status": "normal"
      },
      "memory_usage": {
        "value": 67.3,
        "unit": "percentage", 
        "status": "normal"
      },
      "storage_usage": {
        "value": 23.1,
        "unit": "percentage",
        "status": "normal"
      },
      "pod_count": {
        "value": 15,
        "unit": "count",
        "status": "normal"
      }
    },
    "applications": [
      {
        "id": "app-123",
        "name": "web-app",
        "status": "healthy",
        "cpu_usage": 35.2,
        "memory_usage": 45.8,
        "pod_count": 3
      }
    ]
  }
}
```

## Health Monitoring

### Get Cluster Health

Get overall health status of the workspace cluster.

```http
GET /api/v1/workspaces/:wsId/monitoring/health
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "overall_status": "healthy",
    "last_updated": "2024-01-20T15:30:00Z",
    "components": {
      "api_server": {
        "status": "healthy",
        "message": "API server is responsive",
        "last_check": "2024-01-20T15:30:00Z",
        "response_time_ms": 45
      },
      "etcd": {
        "status": "healthy",
        "message": "etcd cluster is healthy",
        "last_check": "2024-01-20T15:30:00Z",
        "cluster_size": 3,
        "leader": "etcd-0"
      },
      "scheduler": {
        "status": "healthy",
        "message": "Scheduler is working normally",
        "last_check": "2024-01-20T15:30:00Z",
        "pending_pods": 0
      },
      "controller_manager": {
        "status": "healthy",
        "message": "Controller manager is running",
        "last_check": "2024-01-20T15:30:00Z"
      },
      "dns": {
        "status": "healthy",
        "message": "DNS resolution working",
        "last_check": "2024-01-20T15:30:00Z",
        "query_time_ms": 12
      }
    },
    "nodes": {
      "total": 3,
      "ready": 3,
      "not_ready": 0,
      "details": [
        {
          "name": "node-1",
          "status": "ready",
          "cpu_pressure": false,
          "memory_pressure": false,
          "disk_pressure": false,
          "last_heartbeat": "2024-01-20T15:29:45Z"
        }
      ]
    },
    "resource_health": {
      "cpu_utilization": 45.2,
      "memory_utilization": 67.3,
      "storage_utilization": 23.1,
      "status": "normal"
    }
  }
}
```

### Get Application Health

Get health status for all applications in a workspace.

```http
GET /api/v1/workspaces/:wsId/monitoring/applications/health
```

**Query Parameters:**
- `application_id` (string) - Filter by specific application
- `status` (string) - Filter by health status

**Response:**
```json
{
  "data": [
    {
      "application_id": "app-123",
      "name": "web-app",
      "status": "healthy",
      "last_updated": "2024-01-20T15:30:00Z",
      "health_checks": {
        "readiness": {
          "status": "passing",
          "success_rate": 100,
          "last_check": "2024-01-20T15:29:50Z"
        },
        "liveness": {
          "status": "passing",
          "success_rate": 100,
          "last_check": "2024-01-20T15:29:50Z"
        }
      },
      "replicas": {
        "desired": 3,
        "ready": 3,
        "available": 3,
        "unavailable": 0
      },
      "pods": [
        {
          "name": "web-app-7d8c9f5b6-abc12",
          "status": "running",
          "ready": true,
          "restarts": 0,
          "age": "2d5h",
          "health_score": 100
        }
      ]
    }
  ]
}
```

## Alerting

### List Alerts

Get all alerts for a workspace.

```http
GET /api/v1/workspaces/:wsId/monitoring/alerts
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `status` (string) - Filter by status (`firing`, `resolved`, `acknowledged`)
- `severity` (string) - Filter by severity (`critical`, `warning`, `info`)
- `resource_type` (string) - Filter by resource type
- `since` (string) - Time duration

**Response:**
```json
{
  "data": [
    {
      "id": "alert-123",
      "workspace_id": "ws-123",
      "name": "High CPU Usage",
      "type": "threshold",
      "severity": "warning",
      "status": "firing",
      "description": "CPU usage has exceeded 80% for 5 minutes",
      "created_at": "2024-01-20T14:00:00Z",
      "fired_at": "2024-01-20T15:00:00Z",
      "condition": {
        "metric": "cpu_usage",
        "operator": "greater_than",
        "threshold": 80,
        "duration": "5m"
      },
      "targets": {
        "resource_type": "application",
        "resource_ids": ["app-123"]
      },
      "current_value": 85.2,
      "runbook_url": "https://docs.example.com/runbooks/high-cpu"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 5,
    "pages": 1
  },
  "summary": {
    "firing": 2,
    "acknowledged": 1,
    "resolved": 2,
    "by_severity": {
      "critical": 0,
      "warning": 3,
      "info": 2
    }
  }
}
```

### Create Alert

Create a new alert rule for monitoring.

```http
POST /api/v1/workspaces/:wsId/monitoring/alerts
```

**Request Body:**
```json
{
  "name": "High Memory Usage",
  "description": "Alert when memory usage exceeds 85%",
  "type": "threshold",
  "severity": "warning",
  "enabled": true,
  "condition": {
    "metric": "memory_usage",
    "operator": "greater_than",
    "threshold": 85,
    "duration": "10m",
    "aggregation": "avg"
  },
  "targets": {
    "resource_type": "application",
    "resource_ids": ["app-123"],
    "labels": {
      "environment": "production"
    }
  },
  "notifications": [
    {
      "type": "email",
      "destination": "ops@example.com",
      "enabled": true
    },
    {
      "type": "slack",
      "destination": "#alerts",
      "enabled": true
    },
    {
      "type": "webhook",
      "destination": "https://monitoring.example.com/webhook",
      "enabled": false
    }
  ],
  "runbook_url": "https://docs.example.com/runbooks/high-memory",
  "labels": {
    "team": "platform",
    "component": "infrastructure"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "alert-456",
    "name": "High Memory Usage",
    "workspace_id": "ws-123",
    "type": "threshold",
    "severity": "warning",
    "status": "active",
    "enabled": true,
    "created_at": "2024-01-20T15:00:00Z",
    "condition": {
      "metric": "memory_usage",
      "operator": "greater_than",
      "threshold": 85,
      "duration": "10m"
    }
  }
}
```

### Get Alert

Get detailed information about a specific alert.

```http
GET /api/v1/workspaces/:wsId/monitoring/alerts/:alertId
```

**Response:**
```json
{
  "data": {
    "id": "alert-123",
    "workspace_id": "ws-123",
    "name": "High CPU Usage", 
    "description": "CPU usage has exceeded 80% for 5 minutes",
    "type": "threshold",
    "severity": "warning",
    "status": "firing",
    "enabled": true,
    "created_at": "2024-01-20T14:00:00Z",
    "updated_at": "2024-01-20T15:00:00Z",
    "fired_at": "2024-01-20T15:00:00Z",
    "condition": {
      "metric": "cpu_usage",
      "operator": "greater_than",
      "threshold": 80,
      "duration": "5m",
      "aggregation": "avg"
    },
    "targets": {
      "resource_type": "application",
      "resource_ids": ["app-123"],
      "labels": {
        "environment": "production"
      }
    },
    "current_value": 85.2,
    "evaluation_history": [
      {
        "timestamp": "2024-01-20T15:00:00Z",
        "value": 85.2,
        "status": "firing"
      },
      {
        "timestamp": "2024-01-20T14:55:00Z",
        "value": 82.1,
        "status": "firing"
      }
    ],
    "notifications": [
      {
        "type": "email",
        "destination": "ops@example.com",
        "last_sent": "2024-01-20T15:01:00Z",
        "status": "delivered"
      }
    ],
    "runbook_url": "https://docs.example.com/runbooks/high-cpu"
  }
}
```

### Update Alert

Update an existing alert rule.

```http
PUT /api/v1/workspaces/:wsId/monitoring/alerts/:alertId
```

**Request Body:**
```json
{
  "name": "Updated High CPU Alert",
  "description": "Updated description",
  "severity": "critical",
  "condition": {
    "threshold": 90,
    "duration": "3m"
  },
  "enabled": true
}
```

**Response:**
```json
{
  "data": {
    "id": "alert-123",
    "name": "Updated High CPU Alert",
    "severity": "critical",
    "updated_at": "2024-01-20T15:30:00Z",
    "condition": {
      "metric": "cpu_usage",
      "operator": "greater_than",
      "threshold": 90,
      "duration": "3m"
    }
  }
}
```

### Delete Alert

Delete an alert rule.

```http
DELETE /api/v1/workspaces/:wsId/monitoring/alerts/:alertId
```

**Response:**
```json
{
  "data": {
    "message": "Alert deleted successfully",
    "alert_id": "alert-123"
  }
}
```

### Acknowledge Alert

Acknowledge a firing alert to suppress notifications.

```http
PUT /api/v1/workspaces/:wsId/monitoring/alerts/:alertId/acknowledge
```

**Request Body:**
```json
{
  "acknowledged_by": "user-123",
  "note": "Investigating the issue",
  "duration": "1h"
}
```

**Response:**
```json
{
  "data": {
    "alert_id": "alert-123",
    "status": "acknowledged",
    "acknowledged_at": "2024-01-20T15:30:00Z",
    "acknowledged_by": "user-123",
    "note": "Investigating the issue",
    "auto_resolve_at": "2024-01-20T16:30:00Z"
  }
}
```

### Resolve Alert

Manually resolve an alert.

```http
PUT /api/v1/workspaces/:wsId/monitoring/alerts/:alertId/resolve
```

**Request Body:**
```json
{
  "resolved_by": "user-123",
  "note": "Issue has been fixed",
  "resolution": "Scaled application to handle increased load"
}
```

**Response:**
```json
{
  "data": {
    "alert_id": "alert-123",
    "status": "resolved",
    "resolved_at": "2024-01-20T15:45:00Z",
    "resolved_by": "user-123",
    "resolution": "Scaled application to handle increased load",
    "duration": "45m"
  }
}
```

## Dashboards

### Get Workspace Dashboard

Get a comprehensive dashboard view of workspace metrics.

```http
GET /api/v1/workspaces/:wsId/monitoring/dashboard
```

**Query Parameters:**
- `period` (string) - Time period for metrics

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "period": "24h",
    "generated_at": "2024-01-20T15:30:00Z",
    "overview": {
      "health_status": "healthy",
      "active_alerts": 2,
      "applications": {
        "total": 12,
        "healthy": 11,
        "degraded": 1,
        "unhealthy": 0
      },
      "nodes": {
        "total": 3,
        "ready": 3,
        "not_ready": 0
      }
    },
    "metrics": {
      "cpu_usage": {
        "current": 48.7,
        "average": 45.2,
        "peak": 67.3,
        "trend": "stable"
      },
      "memory_usage": {
        "current": 67.3,
        "average": 64.1,
        "peak": 82.1,
        "trend": "increasing"
      },
      "storage_usage": {
        "current": 23.1,
        "average": 22.8,
        "peak": 24.5,
        "trend": "stable"
      }
    },
    "top_applications": [
      {
        "id": "app-123",
        "name": "web-app",
        "cpu_usage": 35.2,
        "memory_usage": 45.8,
        "request_rate": 145.7,
        "error_rate": 0.2
      }
    ],
    "recent_alerts": [
      {
        "id": "alert-123",
        "name": "High CPU Usage",
        "severity": "warning",
        "fired_at": "2024-01-20T15:00:00Z",
        "status": "firing"
      }
    ]
  }
}
```

## Log Aggregation

### Query Logs

Query aggregated logs across the workspace.

```http
POST /api/v1/workspaces/:wsId/monitoring/logs/query
```

**Request Body:**
```json
{
  "query": "level=error AND application=web-app",
  "start_time": "2024-01-20T14:00:00Z",
  "end_time": "2024-01-20T15:00:00Z",
  "limit": 100,
  "sort": "timestamp desc",
  "fields": ["timestamp", "level", "message", "application", "pod"]
}
```

**Response:**
```json
{
  "data": {
    "query": "level=error AND application=web-app",
    "total_hits": 23,
    "execution_time_ms": 45,
    "logs": [
      {
        "timestamp": "2024-01-20T14:45:30Z",
        "level": "error",
        "message": "Database connection timeout",
        "application": "web-app",
        "pod": "web-app-7d8c9f5b6-abc12",
        "container": "nginx",
        "node": "node-1"
      }
    ],
    "aggregations": {
      "by_level": {
        "error": 23,
        "warn": 45,
        "info": 1234
      },
      "by_application": {
        "web-app": 23,
        "api-service": 0
      }
    }
  }
}
```

## Error Responses

### 400 Bad Request - Invalid Query
```json
{
  "error": {
    "code": "INVALID_METRICS_QUERY",
    "message": "Invalid metrics query parameters",
    "details": {
      "metric": "Unknown metric 'invalid_metric'",
      "period": "Invalid time period format"
    }
  }
}
```

### 409 Conflict - Alert Already Exists
```json
{
  "error": {
    "code": "ALERT_ALREADY_EXISTS",
    "message": "Alert with this name already exists",
    "details": {
      "name": "High CPU Usage",
      "existing_alert_id": "alert-456"
    }
  }
}
```

### 422 Unprocessable Entity - Invalid Alert Condition
```json
{
  "error": {
    "code": "INVALID_ALERT_CONDITION",
    "message": "Alert condition is invalid",
    "details": {
      "threshold": "Threshold must be a positive number",
      "duration": "Duration must be at least 1 minute"
    }
  }
}
```

## Webhooks

Monitoring events that trigger webhooks:

- `alert.created`
- `alert.updated`
- `alert.fired`
- `alert.resolved`
- `alert.acknowledged`
- `health.degraded`
- `health.recovered`
- `metrics.threshold_exceeded`

Example webhook payload:
```json
{
  "event": "alert.fired",
  "timestamp": "2024-01-20T15:00:00Z",
  "data": {
    "alert": {
      "id": "alert-123",
      "name": "High CPU Usage",
      "severity": "warning",
      "status": "firing"
    },
    "workspace": {
      "id": "ws-123",
      "name": "Production Workspace"
    },
    "current_value": 85.2,
    "threshold": 80
  }
}
```

## Best Practices

1. **Alert Fatigue**: Set appropriate thresholds to avoid too many false positives
2. **Runbooks**: Include runbook URLs in alerts for quick incident response
3. **Notification Channels**: Use multiple notification channels for critical alerts
4. **Metric Retention**: Consider data retention policies for long-term storage
5. **Dashboard Organization**: Create focused dashboards for different teams and use cases