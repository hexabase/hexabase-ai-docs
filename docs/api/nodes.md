# Node Management API

Node management enables provisioning and managing dedicated virtual machines for enhanced performance, security, and resource isolation. Dedicated nodes provide single-tenant infrastructure for production workloads.

## Base URL

All node endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/workspaces/:wsId/nodes
```

## Node Object

```json
{
  "id": "node-123",
  "name": "prod-node-1",
  "workspace_id": "ws-123",
  "plan_id": "plan-dedicated-4c8g",
  "status": "running",
  "provider": "proxmox",
  "region": "us-west-2",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "specs": {
    "cpu_cores": 4,
    "memory_gb": 8,
    "storage_gb": 100,
    "network_speed": "1Gbps"
  },
  "usage": {
    "cpu_percentage": 45.2,
    "memory_percentage": 67.8,
    "storage_percentage": 23.1,
    "network_in_mbps": 15.3,
    "network_out_mbps": 8.7
  },
  "kubernetes": {
    "node_name": "node-123-k8s",
    "ready": true,
    "schedulable": true,
    "taints": [],
    "labels": {
      "node-type": "dedicated",
      "workspace": "ws-123"
    }
  },
  "cost": {
    "hourly_rate": 0.12,
    "monthly_estimate": 86.40
  }
}
```

## Node Management

### List Nodes

Get all nodes in a workspace.

```http
GET /api/v1/workspaces/:wsId/nodes
```

**Query Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20, max: 100)
- `status` (string) - Filter by status (`running`, `stopped`, `provisioning`, `error`)
- `plan_id` (string) - Filter by node plan
- `region` (string) - Filter by region
- `search` (string) - Search by node name

**Response:**
```json
{
  "data": [
    {
      "id": "node-123",
      "name": "prod-node-1",
      "workspace_id": "ws-123",
      "plan_id": "plan-dedicated-4c8g",
      "status": "running",
      "provider": "proxmox",
      "region": "us-west-2",
      "created_at": "2024-01-01T00:00:00Z",
      "specs": {
        "cpu_cores": 4,
        "memory_gb": 8,
        "storage_gb": 100
      },
      "usage": {
        "cpu_percentage": 45.2,
        "memory_percentage": 67.8
      },
      "cost": {
        "hourly_rate": 0.12,
        "monthly_estimate": 86.40
      }
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

### Provision Dedicated Node

Create a new dedicated node for the workspace.

```http
POST /api/v1/workspaces/:wsId/nodes
```

**Request Body:**
```json
{
  "name": "prod-node-1",
  "plan_id": "plan-dedicated-4c8g",
  "region": "us-west-2",
  "labels": {
    "environment": "production",
    "team": "backend"
  },
  "taints": [
    {
      "key": "dedicated",
      "value": "backend",
      "effect": "NoSchedule"
    }
  ],
  "auto_scaling": {
    "enabled": false
  }
}
```

**Validation:**
- `name` - Required, 3-50 characters, DNS label format
- `plan_id` - Required, valid node plan ID
- `region` - Optional, defaults to workspace region

**Response:**
```json
{
  "data": {
    "id": "node-123",
    "name": "prod-node-1",
    "workspace_id": "ws-123",
    "plan_id": "plan-dedicated-4c8g",
    "status": "provisioning",
    "provider": "proxmox",
    "region": "us-west-2",
    "created_at": "2024-01-20T10:00:00Z",
    "provisioning_task_id": "task-456",
    "estimated_ready_time": "2024-01-20T10:15:00Z"
  }
}
```

### Get Node

Get detailed information about a specific node.

```http
GET /api/v1/workspaces/:wsId/nodes/:nodeId
```

**Response:**
```json
{
  "data": {
    "id": "node-123",
    "name": "prod-node-1",
    "workspace_id": "ws-123", 
    "plan_id": "plan-dedicated-4c8g",
    "status": "running",
    "provider": "proxmox",
    "region": "us-west-2",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "specs": {
      "cpu_cores": 4,
      "memory_gb": 8,
      "storage_gb": 100,
      "network_speed": "1Gbps",
      "architecture": "x86_64"
    },
    "usage": {
      "cpu_percentage": 45.2,
      "memory_percentage": 67.8,
      "storage_percentage": 23.1,
      "network_in_mbps": 15.3,
      "network_out_mbps": 8.7,
      "uptime_hours": 168
    },
    "kubernetes": {
      "node_name": "node-123-k8s",
      "ready": true,
      "schedulable": true,
      "taints": [
        {
          "key": "dedicated",
          "value": "backend",
          "effect": "NoSchedule"
        }
      ],
      "labels": {
        "node-type": "dedicated",
        "workspace": "ws-123",
        "environment": "production"
      },
      "allocatable": {
        "cpu": "3.8",
        "memory": "7.5Gi",
        "pods": "110"
      },
      "capacity": {
        "cpu": "4",
        "memory": "8Gi",
        "pods": "110"
      }
    },
    "network": {
      "private_ip": "10.0.1.100",
      "public_ip": "203.0.113.100",
      "hostname": "node-123.internal"
    },
    "cost": {
      "hourly_rate": 0.12,
      "monthly_estimate": 86.40,
      "current_month_cost": 32.15
    },
    "applications": [
      {
        "id": "app-123",
        "name": "backend-api",
        "pods": 3
      }
    ]
  }
}
```

### Delete Node

Delete a dedicated node and migrate workloads.

```http
DELETE /api/v1/workspaces/:wsId/nodes/:nodeId
```

**Query Parameters:**
- `force` (boolean) - Force deletion without workload migration
- `drain_timeout` (integer) - Timeout for draining workloads in seconds

**Response:**
```json
{
  "data": {
    "message": "Node deletion initiated",
    "task_id": "task-789",
    "drain_status": "draining_workloads"
  }
}
```

## Node Operations

### Start Node

Start a stopped node.

```http
POST /api/v1/workspaces/:wsId/nodes/:nodeId/start
```

**Response:**
```json
{
  "data": {
    "id": "node-123",
    "status": "starting",
    "operation_id": "op-123",
    "estimated_ready_time": "2024-01-20T15:05:00Z"
  }
}
```

### Stop Node

Stop a running node (preserves data).

```http
POST /api/v1/workspaces/:wsId/nodes/:nodeId/stop
```

**Query Parameters:**
- `drain_workloads` (boolean) - Drain workloads before stopping (default: true)
- `force` (boolean) - Force stop without draining

**Response:**
```json
{
  "data": {
    "id": "node-123",
    "status": "stopping",
    "operation_id": "op-456",
    "drain_status": "draining"
  }
}
```

### Reboot Node

Reboot a node with graceful workload handling.

```http
POST /api/v1/workspaces/:wsId/nodes/:nodeId/reboot
```

**Response:**
```json
{
  "data": {
    "id": "node-123",
    "status": "rebooting",
    "operation_id": "op-789",
    "estimated_ready_time": "2024-01-20T15:10:00Z"
  }
}
```

## Node Monitoring

### Get Node Status

Get current operational status of a node.

```http
GET /api/v1/workspaces/:wsId/nodes/:nodeId/status
```

**Response:**
```json
{
  "data": {
    "id": "node-123",
    "status": "running",
    "health": "healthy",
    "last_heartbeat": "2024-01-20T15:30:00Z",
    "uptime": "7d 12h 45m",
    "kubernetes": {
      "ready": true,
      "schedulable": true,
      "conditions": [
        {
          "type": "Ready",
          "status": "True",
          "last_transition": "2024-01-13T03:15:00Z"
        }
      ]
    },
    "system": {
      "kernel_version": "5.15.0-56-generic",
      "os_image": "Ubuntu 22.04.1 LTS",
      "container_runtime": "containerd://1.6.6",
      "kubelet_version": "v1.28.3"
    }
  }
}
```

### Get Node Metrics

Get detailed performance metrics for a node.

```http
GET /api/v1/workspaces/:wsId/nodes/:nodeId/metrics
```

**Query Parameters:**
- `period` (string) - Time period (`5m`, `1h`, `6h`, `24h`, `7d`)
- `metric` (string) - Specific metric to retrieve

**Response:**
```json
{
  "data": {
    "cpu": {
      "current_percentage": 45.2,
      "average_percentage": 42.1,
      "peak_percentage": 78.5,
      "cores_used": 1.8,
      "cores_total": 4,
      "series": [
        {
          "timestamp": "2024-01-20T15:00:00Z",
          "value": 42.1
        }
      ]
    },
    "memory": {
      "current_percentage": 67.8,
      "average_percentage": 64.2,
      "peak_percentage": 85.3,
      "used_gb": 5.4,
      "total_gb": 8,
      "series": [
        {
          "timestamp": "2024-01-20T15:00:00Z",
          "value": 64.2
        }
      ]
    },
    "storage": {
      "current_percentage": 23.1,
      "used_gb": 23.1,
      "total_gb": 100,
      "iops": {
        "read": 150,
        "write": 75
      }
    },
    "network": {
      "in_mbps": 15.3,
      "out_mbps": 8.7,
      "packets_in_per_sec": 1250,
      "packets_out_per_sec": 890
    }
  }
}
```

### Get Node Events

Get system and Kubernetes events for a node.

```http
GET /api/v1/workspaces/:wsId/nodes/:nodeId/events
```

**Query Parameters:**
- `type` (string) - Event type (`Normal`, `Warning`)
- `source` (string) - Event source
- `since` (string) - Time duration

**Response:**
```json
{
  "data": [
    {
      "type": "Normal",
      "reason": "NodeReady",
      "message": "Node node-123-k8s status is now: NodeReady",
      "source": "kubelet",
      "first_timestamp": "2024-01-20T10:15:00Z",
      "last_timestamp": "2024-01-20T10:15:00Z",
      "count": 1
    },
    {
      "type": "Warning", 
      "reason": "SystemOOM",
      "message": "System OOM encountered, temporarily evicting pods",
      "source": "kernel-monitor",
      "first_timestamp": "2024-01-19T14:30:00Z",
      "last_timestamp": "2024-01-19T14:30:00Z",
      "count": 1
    }
  ]
}
```

## Resource Management

### Get Workspace Resource Usage

Get aggregated resource usage across all nodes in the workspace.

```http
GET /api/v1/workspaces/:wsId/nodes/usage
```

**Response:**
```json
{
  "data": {
    "summary": {
      "total_nodes": 3,
      "running_nodes": 3,
      "total_cpu_cores": 12,
      "total_memory_gb": 24,
      "total_storage_gb": 300
    },
    "usage": {
      "cpu": {
        "used_cores": 5.4,
        "percentage": 45.0
      },
      "memory": {
        "used_gb": 16.2,
        "percentage": 67.5
      },
      "storage": {
        "used_gb": 69.3,
        "percentage": 23.1
      }
    },
    "by_node": [
      {
        "node_id": "node-123",
        "name": "prod-node-1",
        "cpu_percentage": 45.2,
        "memory_percentage": 67.8,
        "storage_percentage": 23.1
      }
    ]
  }
}
```

### Get Node Costs

Get cost breakdown and billing information for nodes.

```http
GET /api/v1/workspaces/:wsId/nodes/costs
```

**Query Parameters:**
- `period` (string) - Time period (`current_month`, `last_month`, `last_3_months`)
- `breakdown` (string) - Cost breakdown level (`node`, `plan`, `region`)

**Response:**
```json
{
  "data": {
    "current_month": {
      "total_cost": 259.20,
      "projected_cost": 345.60,
      "by_node": [
        {
          "node_id": "node-123",
          "name": "prod-node-1",
          "cost": 86.40,
          "hourly_rate": 0.12,
          "hours_running": 720
        }
      ],
      "by_plan": [
        {
          "plan_id": "plan-dedicated-4c8g",
          "plan_name": "Dedicated 4 CPU, 8GB RAM",
          "cost": 172.80,
          "node_count": 2
        }
      ]
    },
    "trends": {
      "cost_trend": "increasing",
      "percentage_change": 15.3,
      "comparison_period": "last_month"
    }
  }
}
```

### Check Resource Allocation

Check if resources can be allocated for new applications.

```http
POST /api/v1/workspaces/:wsId/nodes/check-allocation
```

**Request Body:**
```json
{
  "resources": {
    "cpu": "2",
    "memory": "4Gi",
    "storage": "10Gi"
  },
  "node_selector": {
    "node-type": "dedicated"
  },
  "tolerations": [
    {
      "key": "dedicated",
      "operator": "Equal",
      "value": "backend",
      "effect": "NoSchedule"
    }
  ]
}
```

**Response:**
```json
{
  "data": {
    "can_allocate": true,
    "available_nodes": [
      {
        "node_id": "node-123",
        "name": "prod-node-1",
        "available_cpu": "2.2",
        "available_memory": "2.5Gi",
        "allocation_score": 85
      }
    ],
    "resource_summary": {
      "total_available_cpu": "6.8",
      "total_available_memory": "8.3Gi",
      "total_available_storage": "230Gi"
    }
  }
}
```

## Plan Transitions

### Transition to Shared Plan

Move from dedicated nodes to shared infrastructure.

```http
POST /api/v1/workspaces/:wsId/nodes/transition/shared
```

**Request Body:**
```json
{
  "migration_strategy": "rolling",
  "maintenance_window": {
    "start": "2024-01-21T02:00:00Z",
    "end": "2024-01-21T06:00:00Z"
  },
  "backup_before_migration": true
}
```

**Response:**
```json
{
  "data": {
    "transition_id": "trans-123",
    "status": "scheduled",
    "estimated_duration": "2h 30m",
    "scheduled_start": "2024-01-21T02:00:00Z",
    "cost_impact": {
      "savings_per_month": 172.80,
      "effective_date": "2024-01-21T00:00:00Z"
    }
  }
}
```

### Transition to Dedicated Plan

Move from shared infrastructure to dedicated nodes.

```http
POST /api/v1/workspaces/:wsId/nodes/transition/dedicated
```

**Request Body:**
```json
{
  "node_plan": "plan-dedicated-8c16g",
  "node_count": 2,
  "region": "us-west-2",
  "migration_strategy": "blue_green",
  "labels": {
    "environment": "production"
  }
}
```

**Response:**
```json
{
  "data": {
    "transition_id": "trans-456",
    "status": "provisioning",
    "nodes_being_provisioned": [
      {
        "node_id": "node-456",
        "plan": "plan-dedicated-8c16g",
        "status": "provisioning"
      }
    ],
    "estimated_completion": "2024-01-20T16:00:00Z",
    "cost_impact": {
      "additional_cost_per_month": 345.60,
      "effective_date": "2024-01-20T15:30:00Z"
    }
  }
}
```

## Node Plans

### Get Available Plans

Get all available node plans and pricing.

```http
GET /api/v1/node-plans
```

**Response:**
```json
{
  "data": [
    {
      "id": "plan-dedicated-2c4g",
      "name": "Dedicated Small",
      "description": "2 CPU cores, 4GB RAM, 50GB storage",
      "specs": {
        "cpu_cores": 2,
        "memory_gb": 4,
        "storage_gb": 50,
        "network_speed": "1Gbps"
      },
      "pricing": {
        "hourly": 0.06,
        "monthly": 43.20
      },
      "regions": ["us-west-2", "us-east-1", "eu-west-1"]
    },
    {
      "id": "plan-dedicated-4c8g",
      "name": "Dedicated Medium",
      "description": "4 CPU cores, 8GB RAM, 100GB storage",
      "specs": {
        "cpu_cores": 4,
        "memory_gb": 8,
        "storage_gb": 100,
        "network_speed": "1Gbps"
      },
      "pricing": {
        "hourly": 0.12,
        "monthly": 86.40
      },
      "regions": ["us-west-2", "us-east-1", "eu-west-1"]
    }
  ]
}
```

### Get Plan Details

Get detailed information about a specific node plan.

```http
GET /api/v1/node-plans/:planId
```

**Response:**
```json
{
  "data": {
    "id": "plan-dedicated-4c8g",
    "name": "Dedicated Medium",
    "description": "4 CPU cores, 8GB RAM, 100GB storage",
    "specs": {
      "cpu_cores": 4,
      "cpu_type": "Intel Xeon",
      "memory_gb": 8,
      "memory_type": "DDR4",
      "storage_gb": 100,
      "storage_type": "NVMe SSD",
      "network_speed": "1Gbps",
      "architecture": "x86_64"
    },
    "pricing": {
      "hourly": 0.12,
      "monthly": 86.40,
      "annual": 933.12,
      "currency": "USD"
    },
    "availability": {
      "regions": ["us-west-2", "us-east-1", "eu-west-1"],
      "in_stock": true,
      "estimated_provisioning_time": "5-10 minutes"
    },
    "features": [
      "Dedicated CPU and memory",
      "High-performance NVMe storage",
      "1Gbps network bandwidth",
      "Custom node labels and taints",
      "Advanced monitoring"
    ],
    "suitable_for": [
      "Production workloads",
      "CPU-intensive applications",
      "Applications requiring consistent performance"
    ]
  }
}
```

## Error Responses

### 402 Payment Required - Insufficient Credits
```json
{
  "error": {
    "code": "INSUFFICIENT_CREDITS",
    "message": "Insufficient credits to provision dedicated node",
    "details": {
      "required_credits": 86.40,
      "available_credits": 25.30,
      "missing_credits": 61.10
    }
  }
}
```

### 409 Conflict - Resource Limit Exceeded
```json
{
  "error": {
    "code": "NODE_LIMIT_EXCEEDED",
    "message": "Maximum number of nodes exceeded for current plan",
    "details": {
      "current_nodes": 5,
      "max_nodes": 5,
      "plan": "pro"
    }
  }
}
```

### 422 Unprocessable Entity - Insufficient Capacity
```json
{
  "error": {
    "code": "INSUFFICIENT_CAPACITY",
    "message": "Insufficient capacity in requested region",
    "details": {
      "region": "us-west-2",
      "plan": "plan-dedicated-8c16g",
      "estimated_availability": "2024-01-21T10:00:00Z"
    }
  }
}
```

## Webhooks

Node events that trigger webhooks:

- `node.provisioning_started`
- `node.provisioning_completed`
- `node.provisioning_failed`
- `node.started`
- `node.stopped`
- `node.rebooted`
- `node.deleted`
- `node.health_check_failed`
- `node.resource_threshold_exceeded`

## Best Practices

1. **Right-sizing**: Choose appropriate node plans based on workload requirements
2. **Cost Optimization**: Monitor usage and consider shared plans for development
3. **High Availability**: Use multiple nodes across regions for production
4. **Monitoring**: Set up alerts for resource thresholds and node health
5. **Maintenance**: Schedule regular maintenance windows for updates