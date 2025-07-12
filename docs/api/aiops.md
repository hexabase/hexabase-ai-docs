# AI Operations API

The AI Operations API provides AI-powered assistance for platform management, automated operations, and intelligent chat interfaces. It integrates with the Python-based AIOps service for advanced capabilities.

## Base URLs

AI Operations endpoints:
```
https://api.hexabase.ai/api/v1/ai/chat
https://api.hexabase.ai/api/v1/workspaces/:wsId/aiops/chat
```

## Chat Session Object

```json
{
  "session_id": "sess_123456789",
  "workspace_id": "ws-123",
  "user_id": "user-123",
  "created_at": "2024-01-20T15:00:00Z",
  "updated_at": "2024-01-20T15:30:00Z",
  "status": "active",
  "context": {
    "workspace": {
      "id": "ws-123",
      "name": "Production Workspace",
      "applications": 12,
      "alerts": 2
    },
    "user_role": "admin",
    "capabilities": [
      "workspace_management",
      "application_deployment",
      "monitoring_analysis",
      "troubleshooting"
    ]
  },
  "message_count": 15,
  "last_activity": "2024-01-20T15:30:00Z"
}
```

## Chat Message Object

```json
{
  "id": "msg_987654321",
  "session_id": "sess_123456789",
  "role": "user",
  "content": "Show me the status of my applications",
  "timestamp": "2024-01-20T15:30:00Z",
  "metadata": {
    "intent": "status_query",
    "entities": {
      "resource_type": "applications",
      "scope": "workspace"
    },
    "confidence": 0.95
  }
}
```

## Chat Interface

### Send Chat Message

Send a message to the AI assistant for workspace-level operations.

```http
POST /api/v1/workspaces/:wsId/aiops/chat
```

**Request Body:**
```json
{
  "message": "Show me the current status of all applications in this workspace",
  "session_id": "sess_123456789",
  "context": {
    "include_metrics": true,
    "time_range": "1h"
  },
  "capabilities": [
    "read_applications",
    "read_metrics",
    "generate_insights"
  ]
}
```

**Response:**
```json
{
  "data": {
    "message_id": "msg_987654321",
    "session_id": "sess_123456789",
    "response": {
      "content": "I can see you have 12 applications running in your Production Workspace. Here's the current status:\n\n**Healthy Applications (10):**\n- web-app: 3/3 replicas running, CPU: 35%, Memory: 45%\n- api-service: 2/2 replicas running, CPU: 28%, Memory: 52%\n- worker-app: 1/1 replica running, CPU: 42%, Memory: 38%\n...\n\n**Applications with Issues (2):**\n- database-app: 2/3 replicas running ⚠️ (1 pod failing)\n- cache-service: 1/2 replicas running ⚠️ (1 pod pending)\n\nWould you like me to help diagnose the issues with the failing applications?",
      "type": "markdown",
      "metadata": {
        "intent_fulfilled": true,
        "action_taken": "status_query",
        "resources_analyzed": 12,
        "suggestions": [
          {
            "action": "diagnose_failures",
            "description": "Investigate pod failures in database-app and cache-service"
          },
          {
            "action": "view_logs",
            "description": "Check recent logs for failing applications"
          }
        ]
      }
    },
    "attachments": [
      {
        "type": "application_status_table",
        "data": {
          "applications": [
            {
              "name": "web-app",
              "status": "healthy",
              "replicas": "3/3",
              "cpu_usage": 35.2,
              "memory_usage": 45.1
            }
          ]
        }
      }
    ],
    "actions_available": [
      "restart_application",
      "scale_application",
      "view_logs",
      "create_alert"
    ],
    "timestamp": "2024-01-20T15:30:15Z"
  }
}
```

### Global Chat

Send a message to the AI assistant for global operations (not workspace-specific).

```http
POST /api/v1/ai/chat
```

**Request Body:**
```json
{
  "message": "How do I set up a new workspace for my team?",
  "session_id": "sess_global_123",
  "context": {
    "user_context": {
      "organizations": ["org-123"],
      "role": "admin"
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "message_id": "msg_global_456",
    "session_id": "sess_global_123",
    "response": {
      "content": "I'll help you set up a new workspace for your team. Here's the step-by-step process:\n\n## Creating a New Workspace\n\n1. **Choose Your Plan**\n   - Shared: Cost-effective for development/testing\n   - Dedicated: Enhanced performance and security for production\n\n2. **Configure Resources**\n   - Set CPU, memory, and storage quotas\n   - Define resource limits based on team needs\n\n3. **Set Up Access Control**\n   - Add team members with appropriate roles\n   - Configure project-level permissions\n\nWould you like me to guide you through creating a workspace now, or do you have specific requirements to discuss first?",
      "type": "markdown",
      "metadata": {
        "intent": "workspace_creation_guide",
        "next_steps": [
          "gather_requirements",
          "create_workspace",
          "configure_access"
        ]
      }
    },
    "quick_actions": [
      {
        "label": "Create Workspace Now",
        "action": "create_workspace",
        "parameters": {}
      },
      {
        "label": "View Plans & Pricing",
        "action": "show_plans",
        "parameters": {}
      }
    ]
  }
}
```

### Execute AI Action

Execute an action suggested by the AI assistant.

```http
POST /api/v1/workspaces/:wsId/aiops/actions
```

**Request Body:**
```json
{
  "action": "restart_application",
  "parameters": {
    "application_id": "app-123",
    "reason": "Resolve connection issues",
    "confirmation": true
  },
  "session_id": "sess_123456789",
  "message_id": "msg_987654321"
}
```

**Response:**
```json
{
  "data": {
    "action_id": "action_789",
    "status": "executing",
    "description": "Restarting application 'database-app'",
    "started_at": "2024-01-20T15:35:00Z",
    "estimated_duration": "30s",
    "steps": [
      {
        "step": "validate_application",
        "status": "completed",
        "duration": "2s"
      },
      {
        "step": "drain_connections",
        "status": "in_progress",
        "estimated_duration": "10s"
      },
      {
        "step": "restart_pods",
        "status": "pending",
        "estimated_duration": "15s"
      }
    ]
  }
}
```

### Get Action Status

Get the status of an AI-initiated action.

```http
GET /api/v1/workspaces/:wsId/aiops/actions/:actionId
```

**Response:**
```json
{
  "data": {
    "action_id": "action_789",
    "status": "completed",
    "description": "Restarting application 'database-app'",
    "started_at": "2024-01-20T15:35:00Z",
    "completed_at": "2024-01-20T15:35:28Z",
    "duration": "28s",
    "result": {
      "success": true,
      "message": "Application restarted successfully",
      "details": {
        "pods_restarted": 3,
        "new_pod_names": [
          "database-app-8c9d7e6f5-abc12",
          "database-app-8c9d7e6f5-def34",
          "database-app-8c9d7e6f5-ghi56"
        ]
      }
    },
    "steps": [
      {
        "step": "validate_application",
        "status": "completed",
        "duration": "2s"
      },
      {
        "step": "drain_connections",
        "status": "completed",
        "duration": "8s"
      },
      {
        "step": "restart_pods",
        "status": "completed",
        "duration": "18s"
      }
    ]
  }
}
```

## Session Management

### Create Chat Session

Create a new chat session for extended conversations.

```http
POST /api/v1/workspaces/:wsId/aiops/sessions
```

**Request Body:**
```json
{
  "name": "Troubleshooting Session",
  "description": "Investigating application performance issues",
  "context": {
    "focus_area": "performance",
    "applications": ["app-123", "app-456"],
    "time_range": "1h"
  },
  "capabilities": [
    "read_metrics",
    "read_logs",
    "read_applications",
    "suggest_optimizations"
  ]
}
```

**Response:**
```json
{
  "data": {
    "session_id": "sess_troubleshoot_123",
    "name": "Troubleshooting Session",
    "workspace_id": "ws-123",
    "user_id": "user-123",
    "created_at": "2024-01-20T15:00:00Z",
    "status": "active",
    "context": {
      "focus_area": "performance",
      "applications": ["app-123", "app-456"],
      "capabilities": [
        "read_metrics",
        "read_logs",
        "read_applications",
        "suggest_optimizations"
      ]
    }
  }
}
```

### List Chat Sessions

Get all chat sessions for a workspace.

```http
GET /api/v1/workspaces/:wsId/aiops/sessions
```

**Query Parameters:**
- `status` (string) - Filter by session status
- `limit` (integer) - Number of sessions to return

**Response:**
```json
{
  "data": [
    {
      "session_id": "sess_troubleshoot_123",
      "name": "Troubleshooting Session",
      "status": "active",
      "created_at": "2024-01-20T15:00:00Z",
      "last_activity": "2024-01-20T15:30:00Z",
      "message_count": 8,
      "context": {
        "focus_area": "performance"
      }
    }
  ]
}
```

### Get Chat History

Get conversation history for a session.

```http
GET /api/v1/workspaces/:wsId/aiops/sessions/:sessionId/history
```

**Query Parameters:**
- `limit` (integer) - Number of messages to return
- `before` (string) - Get messages before this message ID

**Response:**
```json
{
  "data": {
    "session_id": "sess_troubleshoot_123",
    "messages": [
      {
        "id": "msg_001",
        "role": "user",
        "content": "My application is running slowly",
        "timestamp": "2024-01-20T15:00:00Z"
      },
      {
        "id": "msg_002",
        "role": "assistant",
        "content": "I'll help you investigate the performance issues. Let me analyze your application metrics...",
        "timestamp": "2024-01-20T15:00:05Z",
        "metadata": {
          "actions_taken": ["metrics_analysis"],
          "resources_examined": ["app-123"]
        }
      }
    ],
    "pagination": {
      "has_more": true,
      "next_cursor": "msg_002"
    }
  }
}
```

### End Chat Session

End an active chat session.

```http
POST /api/v1/workspaces/:wsId/aiops/sessions/:sessionId/end
```

**Request Body:**
```json
{
  "summary": "Successfully identified and resolved performance bottleneck in database queries",
  "actions_completed": [
    "action_789"
  ]
}
```

**Response:**
```json
{
  "data": {
    "session_id": "sess_troubleshoot_123",
    "status": "ended",
    "ended_at": "2024-01-20T16:00:00Z",
    "duration": "1h",
    "summary": {
      "messages_exchanged": 15,
      "actions_executed": 3,
      "issues_resolved": 1,
      "recommendations_given": 5
    }
  }
}
```

## AI Capabilities

### Get AI Capabilities

Get available AI capabilities for a workspace.

```http
GET /api/v1/workspaces/:wsId/aiops/capabilities
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "available_capabilities": [
      {
        "category": "monitoring",
        "capabilities": [
          "analyze_metrics",
          "detect_anomalies",
          "predict_trends",
          "generate_alerts"
        ]
      },
      {
        "category": "troubleshooting",
        "capabilities": [
          "diagnose_issues",
          "analyze_logs",
          "suggest_fixes",
          "root_cause_analysis"
        ]
      },
      {
        "category": "optimization",
        "capabilities": [
          "resource_optimization",
          "cost_analysis",
          "performance_tuning",
          "scaling_recommendations"
        ]
      },
      {
        "category": "automation",
        "capabilities": [
          "auto_scaling",
          "self_healing",
          "predictive_maintenance",
          "workflow_automation"
        ]
      }
    ],
    "user_permissions": [
      "read_workspace",
      "read_applications",
      "execute_actions",
      "create_alerts"
    ],
    "limitations": [
      "Cannot modify billing settings",
      "Cannot delete production resources",
      "Actions require user confirmation"
    ]
  }
}
```

### Get AI Insights

Get AI-generated insights about workspace or application performance.

```http
POST /api/v1/workspaces/:wsId/aiops/insights
```

**Request Body:**
```json
{
  "scope": "workspace",
  "focus_areas": [
    "performance",
    "cost_optimization",
    "security",
    "reliability"
  ],
  "time_range": "7d",
  "include_recommendations": true
}
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "generated_at": "2024-01-20T15:30:00Z",
    "time_range": "7d",
    "insights": [
      {
        "category": "performance",
        "severity": "medium",
        "title": "CPU Usage Trending Upward",
        "description": "Average CPU usage has increased by 15% over the past week, with peak usage reaching 85% during business hours.",
        "affected_resources": [
          {
            "type": "application",
            "id": "app-123",
            "name": "web-app"
          }
        ],
        "metrics": {
          "trend": "increasing",
          "change_percentage": 15,
          "confidence": 0.92
        },
        "recommendations": [
          {
            "action": "scale_horizontally",
            "priority": "high",
            "description": "Consider increasing replica count from 3 to 4 during peak hours",
            "estimated_impact": "20% performance improvement"
          }
        ]
      },
      {
        "category": "cost_optimization",
        "severity": "low",
        "title": "Underutilized Resources Detected",
        "description": "Several applications have consistent low resource utilization, indicating potential for cost savings.",
        "affected_resources": [
          {
            "type": "application",
            "id": "app-456",
            "name": "background-worker"
          }
        ],
        "recommendations": [
          {
            "action": "optimize_resources",
            "priority": "medium",
            "description": "Reduce CPU request from 500m to 200m",
            "estimated_savings": "$45/month"
          }
        ]
      }
    ],
    "summary": {
      "total_insights": 2,
      "high_priority": 0,
      "medium_priority": 1,
      "low_priority": 1,
      "potential_monthly_savings": 45,
      "performance_improvement_opportunities": 1
    }
  }
}
```

## AI Assistant Features

### Natural Language Processing

The AI assistant supports various types of queries:

#### Status Queries
- "What's the status of my applications?"
- "Show me application health"
- "Are there any alerts?"

#### Performance Analysis
- "Why is my app running slowly?"
- "Analyze application performance"
- "What's causing high CPU usage?"

#### Troubleshooting
- "My application is failing, help me debug"
- "Check logs for errors"
- "Diagnose connectivity issues"

#### Resource Management
- "Scale my application to 5 replicas"
- "Restart the failing pods"
- "Optimize resource usage"

#### Cost Analysis
- "How much am I spending on compute?"
- "Show cost breakdown by application"
- "Recommend cost optimizations"

### Automated Actions

The AI can perform various automated actions with user permission:

#### Application Management
- Start/stop applications
- Scale applications up/down
- Restart failing pods
- Update configurations

#### Monitoring & Alerting
- Create custom alerts
- Acknowledge alerts
- Generate monitoring dashboards

#### Optimization
- Apply resource optimizations
- Update resource quotas
- Configure auto-scaling policies

#### Troubleshooting
- Collect diagnostic information
- Execute health checks
- Perform connectivity tests

## Error Responses

### 400 Bad Request - Invalid Message
```json
{
  "error": {
    "code": "INVALID_CHAT_MESSAGE",
    "message": "Chat message is invalid or empty",
    "details": {
      "message": "Message content cannot be empty"
    }
  }
}
```

### 403 Forbidden - Insufficient Permissions
```json
{
  "error": {
    "code": "INSUFFICIENT_AI_PERMISSIONS",
    "message": "User lacks permissions for requested AI action",
    "details": {
      "required_permission": "execute_actions",
      "user_permissions": ["read_workspace", "read_applications"]
    }
  }
}
```

### 429 Too Many Requests - Rate Limit Exceeded
```json
{
  "error": {
    "code": "AI_RATE_LIMIT_EXCEEDED",
    "message": "AI API rate limit exceeded",
    "details": {
      "limit": "100 requests per hour",
      "retry_after": "300 seconds"
    }
  }
}
```

### 503 Service Unavailable - AI Service Down
```json
{
  "error": {
    "code": "AI_SERVICE_UNAVAILABLE",
    "message": "AI operations service is temporarily unavailable",
    "details": {
      "estimated_recovery": "2024-01-20T16:00:00Z"
    }
  }
}
```

## Webhooks

AI Operations events that trigger webhooks:

- `aiops.session.created`
- `aiops.session.ended`
- `aiops.action.started`
- `aiops.action.completed`
- `aiops.action.failed`
- `aiops.insight.generated`
- `aiops.anomaly.detected`

Example webhook payload:
```json
{
  "event": "aiops.action.completed",
  "timestamp": "2024-01-20T15:35:28Z",
  "data": {
    "action": {
      "id": "action_789",
      "type": "restart_application",
      "status": "completed"
    },
    "workspace": {
      "id": "ws-123",
      "name": "Production Workspace"
    },
    "result": {
      "success": true,
      "resources_affected": 3
    }
  }
}
```

## Best Practices

1. **Context Sharing**: Provide relevant context in chat messages for better AI responses
2. **Action Confirmation**: Always confirm AI-suggested actions before execution
3. **Session Management**: Use focused sessions for complex troubleshooting workflows
4. **Permission Control**: Grant minimal necessary permissions to AI operations
5. **Monitoring**: Monitor AI action outcomes and provide feedback for continuous improvement