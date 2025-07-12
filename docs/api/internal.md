# Internal API

The Internal API provides system-level operations for AI agents, internal services, and advanced automation. These endpoints require special authentication using service account tokens and are designed for programmatic access by trusted systems.

## Base URL

All internal endpoints are prefixed with:
```
https://api.hexabase.ai/internal/v1
```

## Authentication

Internal APIs require service account authentication:

```http
Authorization: Bearer <service_account_token>
X-Service-Account: <service_account_id>
```

## System Health

### Get System Health

Get comprehensive system health information across all components.

```http
GET /internal/v1/health
```

**Response:**
```json
{
  "data": {
    "status": "healthy",
    "timestamp": "2024-01-20T15:30:00Z",
    "version": "1.4.2",
    "components": {
      "api_server": {
        "status": "healthy",
        "response_time_ms": 12,
        "uptime": "15d 4h 23m"
      },
      "database": {
        "status": "healthy",
        "connections": {
          "active": 45,
          "idle": 15,
          "max": 100
        },
        "query_performance": {
          "avg_response_ms": 8.5,
          "slow_queries": 0
        }
      },
      "kubernetes_api": {
        "status": "healthy",
        "version": "1.28.3",
        "nodes": {
          "total": 12,
          "ready": 12,
          "not_ready": 0
        }
      },
      "message_queue": {
        "status": "healthy",
        "queue_depth": 23,
        "consumer_lag": "0s"
      }
    },
    "workspaces": {
      "total": 156,
      "active": 148,
      "issues": 2
    },
    "resource_usage": {
      "cpu_percentage": 45.2,
      "memory_percentage": 67.8,
      "storage_percentage": 23.1
    }
  }
}
```

## Workspace Operations

### Get Workspace Overview

Get comprehensive overview of a workspace including all resources and status.

```http
GET /internal/v1/workspaces/:workspaceId/overview
```

**Response:**
```json
{
  "data": {
    "workspace": {
      "id": "ws-123",
      "name": "Production Environment",
      "plan": "dedicated",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z"
    },
    "summary": {
      "applications": {
        "total": 15,
        "running": 14,
        "stopped": 0,
        "failed": 1
      },
      "projects": {
        "total": 3,
        "active": 3
      },
      "functions": {
        "total": 8,
        "active": 6,
        "cold": 2
      },
      "pipelines": {
        "total": 5,
        "active": 2,
        "last_run": "2024-01-20T14:30:00Z"
      }
    },
    "resource_usage": {
      "cpu": {
        "used": "8.5",
        "total": "16",
        "percentage": 53.1
      },
      "memory": {
        "used": "24Gi",
        "total": "32Gi",
        "percentage": 75.0
      },
      "storage": {
        "used": "450Gi",
        "total": "1Ti",
        "percentage": 43.9
      },
      "pods": {
        "running": 45,
        "pending": 2,
        "failed": 1
      }
    },
    "health_metrics": {
      "overall_score": 85,
      "availability": 99.8,
      "performance_score": 82,
      "issues": [
        {
          "severity": "warning",
          "type": "high_memory_usage",
          "component": "app-database",
          "message": "Memory usage above 90% for 10 minutes"
        }
      ]
    },
    "recent_activity": [
      {
        "timestamp": "2024-01-20T15:25:00Z",
        "type": "deployment",
        "resource": "web-app",
        "action": "scaled",
        "details": "Scaled from 3 to 5 replicas"
      },
      {
        "timestamp": "2024-01-20T15:20:00Z",
        "type": "alert",
        "resource": "database-app",
        "action": "triggered",
        "details": "High memory usage alert"
      }
    ]
  }
}
```

### Get AI Insights

Generate AI-powered insights about workspace performance and optimization opportunities.

```http
POST /internal/v1/workspaces/:workspaceId/insights
```

**Request Body:**
```json
{
  "analysis_type": "performance",
  "time_range": "24h",
  "focus_areas": [
    "resource_optimization",
    "cost_analysis",
    "security_posture",
    "performance_bottlenecks"
  ],
  "include_recommendations": true,
  "context": {
    "recent_changes": true,
    "user_feedback": [
      {
        "issue": "slow_response_times",
        "component": "api-service"
      }
    ]
  }
}
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "analysis_timestamp": "2024-01-20T15:30:00Z",
    "overall_assessment": {
      "health_score": 85,
      "efficiency_score": 78,
      "cost_score": 92,
      "security_score": 88
    },
    "insights": [
      {
        "category": "performance",
        "priority": "high",
        "title": "CPU Bottleneck in API Service",
        "description": "The api-service application is experiencing CPU constraints during peak hours, leading to increased response times.",
        "affected_resources": [
          {
            "type": "application",
            "id": "app-api-service",
            "name": "api-service"
          }
        ],
        "metrics": {
          "cpu_usage_peak": 98.5,
          "response_time_increase": 150,
          "error_rate_spike": 2.3
        },
        "recommendations": [
          {
            "action": "scale_horizontally",
            "priority": "immediate",
            "description": "Increase replica count from 3 to 5 during peak hours",
            "estimated_impact": "40% response time improvement",
            "estimated_cost": "$45/month"
          },
          {
            "action": "optimize_resources",
            "priority": "medium",
            "description": "Increase CPU limit from 500m to 1000m",
            "estimated_impact": "25% performance improvement"
          }
        ]
      },
      {
        "category": "cost_optimization",
        "priority": "medium",
        "title": "Underutilized Resources Detected",
        "description": "Several applications have consistently low resource utilization, indicating opportunities for cost savings.",
        "affected_resources": [
          {
            "type": "application",
            "id": "app-worker",
            "name": "background-worker"
          }
        ],
        "recommendations": [
          {
            "action": "downsize_resources",
            "description": "Reduce memory request from 2Gi to 1Gi",
            "estimated_savings": "$30/month"
          }
        ]
      }
    ],
    "trends": {
      "resource_usage": {
        "trend": "increasing",
        "rate": 5.2,
        "projection": "Will need additional capacity in 2 months"
      },
      "cost": {
        "trend": "stable",
        "monthly_change": 1.2
      }
    },
    "action_plan": {
      "immediate": [
        "Scale api-service to 5 replicas",
        "Monitor CPU usage trends"
      ],
      "short_term": [
        "Implement auto-scaling for api-service",
        "Review resource allocation for background-worker"
      ],
      "long_term": [
        "Plan capacity expansion",
        "Implement predictive scaling"
      ]
    }
  }
}
```

### Execute Workspace Operation

Execute system-level operations on a workspace.

```http
POST /internal/v1/workspaces/:workspaceId/operations
```

**Request Body:**
```json
{
  "operation": "auto_heal",
  "parameters": {
    "target_component": "database-app",
    "action": "restart_unhealthy_pods",
    "confirmation": true
  },
  "context": {
    "triggered_by": "health_monitor",
    "incident_id": "inc-456",
    "severity": "medium"
  }
}
```

**Supported Operations:**
- `auto_heal` - Automatically heal unhealthy components
- `optimize_resources` - Apply resource optimizations
- `security_scan` - Perform security assessment
- `cleanup_resources` - Clean up unused resources
- `backup_all` - Trigger backup for all applications

**Response:**
```json
{
  "data": {
    "operation_id": "op-789",
    "operation": "auto_heal",
    "status": "running",
    "started_at": "2024-01-20T15:30:00Z",
    "estimated_completion": "2024-01-20T15:35:00Z",
    "steps": [
      {
        "step": "identify_unhealthy_pods",
        "status": "completed",
        "duration": "5s",
        "result": "Found 2 unhealthy pods"
      },
      {
        "step": "restart_pods",
        "status": "in_progress",
        "estimated_duration": "30s"
      },
      {
        "step": "verify_health",
        "status": "pending",
        "estimated_duration": "60s"
      }
    ]
  }
}
```

### Get Nodes

Get detailed information about all nodes in a workspace cluster.

```http
GET /internal/v1/workspaces/:workspaceId/nodes
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "total_nodes": 4,
    "nodes": [
      {
        "name": "worker-node-1",
        "status": "ready",
        "role": "worker",
        "version": "1.28.3",
        "capacity": {
          "cpu": "4",
          "memory": "16Gi",
          "storage": "100Gi",
          "pods": "110"
        },
        "allocatable": {
          "cpu": "3.8",
          "memory": "14.5Gi",
          "storage": "95Gi",
          "pods": "110"
        },
        "usage": {
          "cpu_percentage": 65.2,
          "memory_percentage": 78.5,
          "storage_percentage": 45.3,
          "pod_count": 23
        },
        "conditions": [
          {
            "type": "Ready",
            "status": "True",
            "last_transition": "2024-01-15T10:00:00Z"
          },
          {
            "type": "MemoryPressure",
            "status": "False",
            "last_transition": "2024-01-20T14:00:00Z"
          }
        ],
        "taints": [],
        "labels": {
          "node-type": "worker",
          "zone": "us-west-2a"
        }
      }
    ],
    "cluster_metrics": {
      "total_capacity": {
        "cpu": "16",
        "memory": "64Gi",
        "storage": "400Gi"
      },
      "total_usage": {
        "cpu_percentage": 58.7,
        "memory_percentage": 72.3,
        "storage_percentage": 38.9
      },
      "health_status": "healthy"
    }
  }
}
```

### Scale Deployment

Scale a specific deployment within a workspace.

```http
POST /internal/v1/workspaces/:workspaceId/deployments/:deploymentName/scale
```

**Request Body:**
```json
{
  "replicas": 5,
  "reason": "Increased traffic detected",
  "auto_scale_config": {
    "min_replicas": 2,
    "max_replicas": 10,
    "target_cpu_percentage": 70,
    "scale_down_delay": "5m"
  }
}
```

**Response:**
```json
{
  "data": {
    "deployment_name": "api-service",
    "workspace_id": "ws-123",
    "previous_replicas": 3,
    "new_replicas": 5,
    "status": "scaling",
    "started_at": "2024-01-20T15:30:00Z",
    "estimated_completion": "2024-01-20T15:32:00Z"
  }
}
```

## Application Operations

### Get Application Details

Get comprehensive details about an application for analysis.

```http
GET /internal/v1/applications/:appId/details
```

**Response:**
```json
{
  "data": {
    "application": {
      "id": "app-123",
      "name": "web-app",
      "workspace_id": "ws-123",
      "status": "running",
      "created_at": "2024-01-01T00:00:00Z"
    },
    "deployment": {
      "replicas": {
        "desired": 3,
        "ready": 3,
        "available": 3,
        "updated": 3
      },
      "strategy": "RollingUpdate",
      "image": "nginx:1.21.6",
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
    "pods": [
      {
        "name": "web-app-7d8c9f5b6-abc12",
        "status": "running",
        "ready": true,
        "node": "worker-node-1",
        "cpu_usage": 45.2,
        "memory_usage": 187,
        "restarts": 0,
        "age": "2d5h"
      }
    ],
    "services": [
      {
        "name": "web-app-service",
        "type": "ClusterIP",
        "cluster_ip": "10.96.45.123",
        "ports": [
          {
            "port": 80,
            "target_port": 8080,
            "protocol": "TCP"
          }
        ]
      }
    ],
    "health": {
      "overall_status": "healthy",
      "readiness_checks": {
        "passing": 3,
        "failing": 0
      },
      "liveness_checks": {
        "passing": 3,
        "failing": 0
      }
    },
    "metrics": {
      "cpu_usage_percentage": 45.2,
      "memory_usage_percentage": 36.5,
      "request_rate": 125.7,
      "error_rate": 0.2,
      "response_time_p95": 245
    }
  }
}
```

### Auto Scale Application

Trigger automatic scaling based on current conditions.

```http
POST /internal/v1/applications/:appId/autoscale
```

**Request Body:**
```json
{
  "trigger": "cpu_threshold",
  "current_metrics": {
    "cpu_percentage": 85.3,
    "memory_percentage": 67.2,
    "request_rate": 245.8
  },
  "scaling_policy": {
    "scale_up_threshold": 80,
    "scale_down_threshold": 30,
    "cooldown_period": "5m"
  }
}
```

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "scaling_action": "scale_up",
    "previous_replicas": 3,
    "new_replicas": 5,
    "reason": "CPU usage exceeded 80% threshold",
    "triggered_at": "2024-01-20T15:30:00Z",
    "estimated_completion": "2024-01-20T15:32:00Z"
  }
}
```

### Trigger Backup

Trigger an automated backup for an application.

```http
POST /internal/v1/applications/:appId/backup
```

**Request Body:**
```json
{
  "backup_type": "automated",
  "reason": "pre_deployment_backup",
  "retention_policy": "standard",
  "include_volumes": true,
  "notification_channels": ["slack:#ops"]
}
```

**Response:**
```json
{
  "data": {
    "backup_id": "backup-789",
    "application_id": "app-123",
    "status": "started",
    "started_at": "2024-01-20T15:30:00Z",
    "estimated_completion": "2024-01-20T15:45:00Z",
    "backup_size_estimate": "2.5Gi"
  }
}
```

### Analyze Performance

Perform detailed performance analysis of an application.

```http
GET /internal/v1/applications/:appId/performance
```

**Query Parameters:**
- `time_range` (string) - Analysis time range (e.g., "1h", "24h")
- `metrics` (string) - Comma-separated list of metrics to analyze

**Response:**
```json
{
  "data": {
    "application_id": "app-123",
    "analysis_period": "1h",
    "generated_at": "2024-01-20T15:30:00Z",
    "performance_summary": {
      "overall_score": 78,
      "availability": 99.9,
      "response_time_p50": 125,
      "response_time_p95": 245,
      "error_rate": 0.2,
      "throughput": 145.7
    },
    "resource_efficiency": {
      "cpu_efficiency": 85.2,
      "memory_efficiency": 72.3,
      "network_efficiency": 91.5
    },
    "bottlenecks": [
      {
        "type": "cpu_contention",
        "severity": "medium",
        "description": "CPU usage spikes during peak hours",
        "impact": "20% increase in response time",
        "recommendation": "Consider horizontal scaling"
      }
    ],
    "trends": {
      "response_time": {
        "trend": "increasing",
        "change_percentage": 15.2
      },
      "throughput": {
        "trend": "stable",
        "change_percentage": 2.1
      }
    },
    "anomalies": [
      {
        "timestamp": "2024-01-20T14:45:00Z",
        "metric": "error_rate",
        "value": 5.2,
        "baseline": 0.2,
        "severity": "high"
      }
    ]
  }
}
```

## Incident Management

### Manage Incident

Perform automated incident management operations.

```http
POST /internal/v1/incidents/:incidentId
```

**Request Body:**
```json
{
  "action": "auto_remediate",
  "incident_details": {
    "type": "application_failure",
    "severity": "high",
    "affected_applications": ["app-123"],
    "symptoms": [
      "high_error_rate",
      "pod_crashes"
    ]
  },
  "remediation_strategy": "restart_and_scale",
  "confirmation_required": false
}
```

**Supported Actions:**
- `auto_remediate` - Attempt automatic remediation
- `escalate` - Escalate to human operators
- `acknowledge` - Acknowledge incident
- `resolve` - Mark incident as resolved

**Response:**
```json
{
  "data": {
    "incident_id": "inc-456",
    "action": "auto_remediate",
    "status": "in_progress",
    "started_at": "2024-01-20T15:30:00Z",
    "remediation_steps": [
      {
        "step": "restart_failed_pods",
        "status": "completed",
        "duration": "30s"
      },
      {
        "step": "scale_healthy_replicas",
        "status": "in_progress",
        "estimated_duration": "2m"
      },
      {
        "step": "verify_health",
        "status": "pending",
        "estimated_duration": "1m"
      }
    ],
    "estimated_completion": "2024-01-20T15:33:00Z"
  }
}
```

## Log Operations

### Query Logs

Perform advanced log queries across all components.

```http
POST /internal/v1/logs/query
```

**Request Body:**
```json
{
  "query": {
    "text": "error AND (database OR connection)",
    "time_range": {
      "start": "2024-01-20T14:00:00Z",
      "end": "2024-01-20T15:00:00Z"
    },
    "filters": {
      "workspace_id": "ws-123",
      "log_level": ["error", "warning"],
      "components": ["api-service", "database"]
    }
  },
  "options": {
    "limit": 1000,
    "sort": "timestamp desc",
    "highlight": true,
    "aggregate": true
  }
}
```

**Response:**
```json
{
  "data": {
    "query_id": "query-789",
    "total_hits": 47,
    "execution_time_ms": 125,
    "logs": [
      {
        "timestamp": "2024-01-20T14:45:30Z",
        "level": "error",
        "message": "Database connection timeout after 30s",
        "component": "api-service",
        "pod": "api-service-7d8c9f5b6-abc12",
        "workspace_id": "ws-123",
        "trace_id": "trace-123456",
        "metadata": {
          "duration_ms": 30000,
          "retry_count": 3,
          "error_code": "connection_timeout"
        }
      }
    ],
    "aggregations": {
      "by_component": {
        "api-service": 32,
        "database": 15
      },
      "by_level": {
        "error": 35,
        "warning": 12
      },
      "timeline": [
        {
          "timestamp": "2024-01-20T14:00:00Z",
          "count": 5
        },
        {
          "timestamp": "2024-01-20T14:15:00Z",
          "count": 12
        }
      ]
    },
    "patterns": [
      {
        "pattern": "Database connection timeout",
        "frequency": 15,
        "first_seen": "2024-01-20T14:30:00Z",
        "last_seen": "2024-01-20T14:55:00Z"
      }
    ]
  }
}
```

## Error Responses

### 401 Unauthorized - Invalid Service Account
```json
{
  "error": {
    "code": "INVALID_SERVICE_ACCOUNT",
    "message": "Invalid or expired service account token",
    "details": {
      "service_account_id": "sa-invalid",
      "token_status": "expired"
    }
  }
}
```

### 403 Forbidden - Insufficient Permissions
```json
{
  "error": {
    "code": "INSUFFICIENT_INTERNAL_PERMISSIONS",
    "message": "Service account lacks required permissions for this operation",
    "details": {
      "required_permission": "workspace:admin",
      "service_account_permissions": ["workspace:read", "application:read"]
    }
  }
}
```

### 409 Conflict - Operation in Progress
```json
{
  "error": {
    "code": "OPERATION_IN_PROGRESS",
    "message": "Another operation is currently in progress for this resource",
    "details": {
      "resource_id": "ws-123",
      "current_operation": "auto_heal",
      "estimated_completion": "2024-01-20T15:35:00Z"
    }
  }
}
```

## Rate Limiting

Internal APIs have higher rate limits but are still subject to throttling:

- **System Health**: 100 requests per minute
- **Workspace Operations**: 50 requests per minute per workspace
- **Application Operations**: 30 requests per minute per application
- **Log Queries**: 20 requests per minute

Rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 75
X-RateLimit-Reset: 1642694400
```

## Webhooks

Internal API events that trigger webhooks:

- `internal.operation.started`
- `internal.operation.completed`
- `internal.operation.failed`
- `internal.incident.auto_remediated`
- `internal.autoscale.triggered`
- `internal.backup.completed`

## Security Considerations

1. **Service Account Management**: Rotate service account tokens regularly
2. **Permission Scoping**: Grant minimal required permissions to service accounts
3. **Audit Logging**: All internal API calls are logged for security auditing
4. **IP Restrictions**: Consider restricting access to trusted IP ranges
5. **TLS Encryption**: All internal API traffic must use TLS 1.2 or higher

## Best Practices

1. **Error Handling**: Implement robust error handling and retry logic
2. **Idempotency**: Design operations to be idempotent where possible
3. **Monitoring**: Monitor internal API usage and performance
4. **Documentation**: Keep service account permissions well-documented
5. **Testing**: Test internal operations in staging environments first