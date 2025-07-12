# Backup API

Backup services provide comprehensive data protection for applications with automated policies, multiple storage backends, and point-in-time recovery capabilities. Available for dedicated plan workspaces.

## Base URLs

Backup management endpoints:
```
https://api.hexabase.ai/api/v1/workspaces/:wsId/backup-storages
https://api.hexabase.ai/api/v1/workspaces/:wsId/applications/:appId/backup-policy
https://api.hexabase.ai/api/v1/workspaces/:wsId/applications/:appId/backups
```

## Backup Storage Object

```json
{
  "id": "storage-123",
  "name": "production-backups",
  "workspace_id": "ws-123",
  "type": "s3",
  "status": "active",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "configuration": {
    "bucket": "hexabase-backups",
    "region": "us-west-2",
    "path_prefix": "ws-123/",
    "encryption": {
      "enabled": true,
      "algorithm": "AES256"
    }
  },
  "credentials": {
    "access_key_id": "AKIA...",
    "secret_access_key": "[HIDDEN]"
  },
  "usage": {
    "total_size_gb": 45.7,
    "backup_count": 156,
    "monthly_cost": 12.34
  }
}
```

## Backup Policy Object

```json
{
  "id": "policy-123",
  "application_id": "app-123",
  "storage_id": "storage-123",
  "enabled": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "schedule": {
    "frequency": "daily",
    "time": "02:00",
    "timezone": "America/New_York",
    "days_of_week": [1, 2, 3, 4, 5]
  },
  "retention": {
    "daily": 7,
    "weekly": 4,
    "monthly": 12,
    "yearly": 3
  },
  "options": {
    "include_volumes": true,
    "include_secrets": false,
    "include_configmaps": true,
    "compression": true,
    "encryption": true
  }
}
```

## Backup Storage Management

### Create Backup Storage

Create a new backup storage backend.

```http
POST /api/v1/workspaces/:wsId/backup-storages
```

**Request Body:**
```json
{
  "name": "production-backups",
  "description": "Primary backup storage for production applications",
  "type": "s3",
  "configuration": {
    "bucket": "hexabase-backups",
    "region": "us-west-2",
    "path_prefix": "ws-123/",
    "encryption": {
      "enabled": true,
      "algorithm": "AES256",
      "kms_key_id": "arn:aws:kms:us-west-2:123456789:key/abc-123"
    }
  },
  "credentials": {
    "access_key_id": "AKIAXXXXXXXXXXXXXXXX",
    "secret_access_key": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  },
  "labels": {
    "environment": "production",
    "team": "platform"
  }
}
```

**Supported Storage Types:**
- `s3` - Amazon S3 compatible storage
- `gcs` - Google Cloud Storage
- `azure` - Azure Blob Storage
- `minio` - MinIO object storage

**Response:**
```json
{
  "data": {
    "id": "storage-123",
    "name": "production-backups",
    "workspace_id": "ws-123",
    "type": "s3",
    "status": "active",
    "created_at": "2024-01-20T10:00:00Z",
    "configuration": {
      "bucket": "hexabase-backups",
      "region": "us-west-2",
      "path_prefix": "ws-123/"
    }
  }
}
```

### List Backup Storages

Get all backup storage backends for a workspace.

```http
GET /api/v1/workspaces/:wsId/backup-storages
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `type` (string) - Filter by storage type
- `status` (string) - Filter by status

**Response:**
```json
{
  "data": [
    {
      "id": "storage-123",
      "name": "production-backups",
      "workspace_id": "ws-123",
      "type": "s3",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z",
      "usage": {
        "total_size_gb": 45.7,
        "backup_count": 156,
        "monthly_cost": 12.34
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 2,
    "pages": 1
  }
}
```

### Get Backup Storage

Get detailed information about a specific backup storage.

```http
GET /api/v1/workspaces/:wsId/backup-storages/:storageId
```

**Response:**
```json
{
  "data": {
    "id": "storage-123",
    "name": "production-backups",
    "description": "Primary backup storage for production applications",
    "workspace_id": "ws-123",
    "type": "s3",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "configuration": {
      "bucket": "hexabase-backups",
      "region": "us-west-2",
      "path_prefix": "ws-123/",
      "encryption": {
        "enabled": true,
        "algorithm": "AES256"
      }
    },
    "connection_status": {
      "status": "connected",
      "last_tested": "2024-01-20T14:30:00Z",
      "test_result": "success"
    },
    "usage": {
      "total_size_gb": 45.7,
      "backup_count": 156,
      "monthly_cost": 12.34,
      "breakdown": {
        "by_application": [
          {
            "application_id": "app-123",
            "application_name": "web-app",
            "size_gb": 25.4,
            "backup_count": 98
          }
        ]
      }
    }
  }
}
```

### Update Backup Storage

Update backup storage configuration.

```http
PUT /api/v1/workspaces/:wsId/backup-storages/:storageId
```

**Request Body:**
```json
{
  "name": "updated-production-backups",
  "description": "Updated description",
  "configuration": {
    "encryption": {
      "enabled": true,
      "algorithm": "AES256",
      "kms_key_id": "arn:aws:kms:us-west-2:123456789:key/def-456"
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "storage-123",
    "name": "updated-production-backups",
    "updated_at": "2024-01-20T15:00:00Z",
    "configuration": {
      "encryption": {
        "enabled": true,
        "algorithm": "AES256",
        "kms_key_id": "arn:aws:kms:us-west-2:123456789:key/def-456"
      }
    }
  }
}
```

### Delete Backup Storage

Delete a backup storage backend. This will not delete existing backups.

```http
DELETE /api/v1/workspaces/:wsId/backup-storages/:storageId
```

**Query Parameters:**
- `force` (boolean) - Force deletion even if policies are using it

**Response:**
```json
{
  "data": {
    "message": "Backup storage deleted successfully",
    "storage_id": "storage-123"
  }
}
```

### Get Storage Usage

Get detailed usage information for a backup storage.

```http
GET /api/v1/workspaces/:wsId/backup-storages/:storageId/usage
```

**Query Parameters:**
- `period` (string) - Time period (`current_month`, `last_month`, `last_3_months`)

**Response:**
```json
{
  "data": {
    "storage_id": "storage-123",
    "current_usage": {
      "total_size_gb": 45.7,
      "backup_count": 156,
      "applications": 8,
      "oldest_backup": "2024-01-01T02:00:00Z",
      "newest_backup": "2024-01-20T02:00:00Z"
    },
    "growth_trend": {
      "daily_average_gb": 1.2,
      "weekly_growth_percentage": 8.5,
      "projected_monthly_size_gb": 82.3
    },
    "cost_breakdown": {
      "storage_cost": 10.24,
      "transfer_cost": 1.85,
      "request_cost": 0.25,
      "total_monthly_cost": 12.34
    }
  }
}
```

## Backup Policies

### Create Backup Policy

Create a backup policy for an application.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/backup-policy
```

**Request Body:**
```json
{
  "storage_id": "storage-123",
  "enabled": true,
  "schedule": {
    "frequency": "daily",
    "time": "02:00",
    "timezone": "America/New_York",
    "days_of_week": [1, 2, 3, 4, 5]
  },
  "retention": {
    "daily": 7,
    "weekly": 4,
    "monthly": 12,
    "yearly": 3
  },
  "options": {
    "include_volumes": true,
    "include_secrets": false,
    "include_configmaps": true,
    "compression": true,
    "encryption": true,
    "backup_on_change": false
  },
  "notifications": {
    "on_success": false,
    "on_failure": true,
    "channels": ["email:ops@example.com", "slack:#alerts"]
  }
}
```

**Schedule Frequencies:**
- `daily` - Daily backups
- `weekly` - Weekly backups
- `monthly` - Monthly backups
- `custom` - Custom cron expression

**Response:**
```json
{
  "data": {
    "id": "policy-123",
    "application_id": "app-123",
    "storage_id": "storage-123",
    "enabled": true,
    "created_at": "2024-01-20T10:00:00Z",
    "schedule": {
      "frequency": "daily",
      "time": "02:00",
      "timezone": "America/New_York",
      "next_backup": "2024-01-21T02:00:00Z"
    }
  }
}
```

### Get Backup Policy

Get the backup policy for an application.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/backup-policy
```

**Response:**
```json
{
  "data": {
    "id": "policy-123",
    "application_id": "app-123",
    "storage_id": "storage-123",
    "enabled": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "schedule": {
      "frequency": "daily",
      "time": "02:00",
      "timezone": "America/New_York",
      "days_of_week": [1, 2, 3, 4, 5],
      "next_backup": "2024-01-21T02:00:00Z",
      "last_backup": "2024-01-20T02:00:00Z"
    },
    "retention": {
      "daily": 7,
      "weekly": 4,
      "monthly": 12,
      "yearly": 3
    },
    "options": {
      "include_volumes": true,
      "include_secrets": false,
      "include_configmaps": true,
      "compression": true,
      "encryption": true
    },
    "statistics": {
      "total_backups": 145,
      "successful_backups": 143,
      "failed_backups": 2,
      "average_size_gb": 2.8,
      "average_duration_minutes": 12
    }
  }
}
```

### Update Backup Policy

Update an existing backup policy.

```http
PUT /api/v1/workspaces/:wsId/applications/:appId/backup-policy
```

**Request Body:**
```json
{
  "enabled": true,
  "schedule": {
    "frequency": "daily",
    "time": "03:00",
    "timezone": "America/New_York"
  },
  "retention": {
    "daily": 14,
    "weekly": 8,
    "monthly": 24,
    "yearly": 5
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "policy-123",
    "updated_at": "2024-01-20T15:00:00Z",
    "schedule": {
      "frequency": "daily",
      "time": "03:00",
      "next_backup": "2024-01-21T03:00:00Z"
    },
    "retention": {
      "daily": 14,
      "weekly": 8,
      "monthly": 24,
      "yearly": 5
    }
  }
}
```

### Delete Backup Policy

Delete a backup policy. This will not delete existing backups.

```http
DELETE /api/v1/workspaces/:wsId/applications/:appId/backup-policy
```

**Response:**
```json
{
  "data": {
    "message": "Backup policy deleted successfully",
    "policy_id": "policy-123"
  }
}
```

## Backup Operations

### Trigger Manual Backup

Manually trigger a backup for an application.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/backups/trigger
```

**Request Body:**
```json
{
  "description": "Pre-deployment backup",
  "retention_override": {
    "keep_until": "2024-12-31T23:59:59Z"
  },
  "options": {
    "include_volumes": true,
    "include_secrets": true,
    "compression": true
  }
}
```

**Response:**
```json
{
  "data": {
    "backup_id": "backup-456",
    "application_id": "app-123",
    "status": "running",
    "started_at": "2024-01-20T15:00:00Z",
    "estimated_completion": "2024-01-20T15:15:00Z"
  }
}
```

### List Backup Executions

Get backup execution history for an application.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/backups
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `status` (string) - Filter by status (`completed`, `failed`, `running`)
- `since` (string) - Time duration

**Response:**
```json
{
  "data": [
    {
      "id": "backup-456",
      "application_id": "app-123",
      "storage_id": "storage-123",
      "status": "completed",
      "type": "manual",
      "started_at": "2024-01-20T02:00:00Z",
      "completed_at": "2024-01-20T02:12:30Z",
      "duration": "12m 30s",
      "size_gb": 2.8,
      "retention": {
        "expires_at": "2024-01-27T02:00:00Z",
        "category": "daily"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 145,
    "pages": 8
  }
}
```

### Get Latest Backup

Get information about the most recent backup.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/backups/latest
```

**Response:**
```json
{
  "data": {
    "id": "backup-456",
    "application_id": "app-123",
    "storage_id": "storage-123",
    "status": "completed",
    "type": "scheduled",
    "started_at": "2024-01-20T02:00:00Z",
    "completed_at": "2024-01-20T02:12:30Z",
    "duration": "12m 30s",
    "size_gb": 2.8,
    "compression_ratio": 0.65,
    "backup_path": "ws-123/app-123/2024-01-20-02-00-00",
    "manifest": {
      "volumes": 3,
      "configmaps": 5,
      "secrets": 0,
      "pvcs": 2
    }
  }
}
```

### Get Backup Execution

Get detailed information about a specific backup.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/backups/:backupId
```

**Response:**
```json
{
  "data": {
    "id": "backup-456",
    "application_id": "app-123",
    "storage_id": "storage-123",
    "status": "completed",
    "type": "scheduled",
    "description": "Scheduled daily backup",
    "started_at": "2024-01-20T02:00:00Z",
    "completed_at": "2024-01-20T02:12:30Z",
    "duration": "12m 30s",
    "size_gb": 2.8,
    "compression_ratio": 0.65,
    "backup_path": "ws-123/app-123/2024-01-20-02-00-00",
    "retention": {
      "expires_at": "2024-01-27T02:00:00Z",
      "category": "daily",
      "keep_forever": false
    },
    "manifest": {
      "volumes": [
        {
          "name": "data-volume",
          "size_gb": 2.1,
          "type": "persistent_volume"
        }
      ],
      "configmaps": 5,
      "secrets": 0,
      "pvcs": 2,
      "included_namespaces": ["app-123"]
    },
    "verification": {
      "verified": true,
      "verified_at": "2024-01-20T02:13:00Z",
      "checksum": "sha256:abc123def456..."
    }
  }
}
```

### Get Backup Manifest

Get the detailed manifest of what was included in a backup.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/backups/:backupId/manifest
```

**Response:**
```json
{
  "data": {
    "backup_id": "backup-456",
    "created_at": "2024-01-20T02:00:00Z",
    "version": "v1",
    "application": {
      "id": "app-123",
      "name": "web-app",
      "namespace": "frontend"
    },
    "resources": {
      "deployments": [
        {
          "name": "web-app",
          "replicas": 3,
          "image": "nginx:1.21"
        }
      ],
      "services": [
        {
          "name": "web-app-service",
          "type": "ClusterIP"
        }
      ],
      "persistent_volumes": [
        {
          "name": "data-pv",
          "size": "10Gi",
          "storage_class": "fast-ssd"
        }
      ],
      "configmaps": [
        {
          "name": "app-config",
          "keys": ["config.json", "env.conf"]
        }
      ]
    },
    "metadata": {
      "kubernetes_version": "1.28.3",
      "backup_tool_version": "1.2.0",
      "compression": "gzip",
      "encryption": "AES256"
    }
  }
}
```

### Download Backup

Download a backup file.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/backups/:backupId/download
```

**Query Parameters:**
- `format` (string) - Download format (`tar.gz`, `zip`)

**Response:** Binary file download with appropriate headers
```
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="backup-456.tar.gz"
Content-Length: 2956341248
```

### Restore Backup

Restore an application from a backup.

```http
POST /api/v1/workspaces/:wsId/applications/:appId/backups/:backupId/restore
```

**Request Body:**
```json
{
  "target_application": "app-456", // Optional, defaults to original app
  "namespace_mapping": {
    "frontend": "frontend-restored"
  },
  "restore_options": {
    "include_volumes": true,
    "include_configmaps": true,
    "include_secrets": false,
    "restore_strategy": "create_new"
  },
  "confirmation": "I understand this will overwrite existing data"
}
```

**Restore Strategies:**
- `create_new` - Create new resources with different names
- `overwrite` - Overwrite existing resources
- `merge` - Merge with existing resources where possible

**Response:**
```json
{
  "data": {
    "restore_id": "restore-789",
    "backup_id": "backup-456",
    "target_application": "app-456",
    "status": "running",
    "started_at": "2024-01-20T15:30:00Z",
    "estimated_completion": "2024-01-20T15:45:00Z"
  }
}
```

## Restore Operations

### List Backup Restores

Get restore operation history for an application.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/restores
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
      "id": "restore-789",
      "backup_id": "backup-456",
      "application_id": "app-123",
      "target_application": "app-456",
      "status": "completed",
      "started_at": "2024-01-20T15:30:00Z",
      "completed_at": "2024-01-20T15:42:15Z",
      "duration": "12m 15s",
      "restored_resources": {
        "deployments": 1,
        "services": 1,
        "persistent_volumes": 2,
        "configmaps": 5
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

### Get Backup Restore

Get detailed information about a specific restore operation.

```http
GET /api/v1/workspaces/:wsId/applications/:appId/restores/:restoreId
```

**Response:**
```json
{
  "data": {
    "id": "restore-789",
    "backup_id": "backup-456",
    "application_id": "app-123",
    "target_application": "app-456",
    "status": "completed",
    "started_at": "2024-01-20T15:30:00Z",
    "completed_at": "2024-01-20T15:42:15Z",
    "duration": "12m 15s",
    "restore_options": {
      "include_volumes": true,
      "include_configmaps": true,
      "include_secrets": false,
      "restore_strategy": "create_new"
    },
    "restored_resources": {
      "deployments": [
        {
          "name": "web-app-restored",
          "status": "created",
          "original_name": "web-app"
        }
      ],
      "services": [
        {
          "name": "web-app-service-restored",
          "status": "created"
        }
      ],
      "persistent_volumes": [
        {
          "name": "data-pv-restored",
          "size": "10Gi",
          "status": "bound"
        }
      ]
    },
    "verification": {
      "verified": true,
      "verified_at": "2024-01-20T15:43:00Z",
      "health_check_passed": true
    }
  }
}
```

## Workspace Storage Usage

### Get Workspace Storage Usage

Get aggregated backup storage usage across the workspace.

```http
GET /api/v1/workspaces/:wsId/backup-storage-usage
```

**Response:**
```json
{
  "data": {
    "workspace_id": "ws-123",
    "total_usage": {
      "size_gb": 127.3,
      "backup_count": 456,
      "applications": 12,
      "storage_backends": 2
    },
    "by_storage": [
      {
        "storage_id": "storage-123",
        "name": "production-backups",
        "size_gb": 89.7,
        "backup_count": 312,
        "cost": 18.45
      },
      {
        "storage_id": "storage-456",
        "name": "development-backups",
        "size_gb": 37.6,
        "backup_count": 144,
        "cost": 7.23
      }
    ],
    "by_application": [
      {
        "application_id": "app-123",
        "name": "web-app",
        "size_gb": 45.2,
        "backup_count": 98,
        "last_backup": "2024-01-20T02:00:00Z"
      }
    ],
    "cost_summary": {
      "total_monthly_cost": 25.68,
      "storage_cost": 22.15,
      "transfer_cost": 2.88,
      "request_cost": 0.65
    }
  }
}
```

## Error Responses

### 400 Bad Request - Invalid Storage Configuration
```json
{
  "error": {
    "code": "INVALID_STORAGE_CONFIG",
    "message": "Invalid storage configuration",
    "details": {
      "bucket": "Bucket name contains invalid characters",
      "credentials": "Invalid access key format"
    }
  }
}
```

### 403 Forbidden - Dedicated Plan Required
```json
{
  "error": {
    "code": "FEATURE_NOT_AVAILABLE",
    "message": "Backup functionality requires dedicated plan",
    "details": {
      "current_plan": "shared",
      "required_plan": "dedicated"
    }
  }
}
```

### 409 Conflict - Backup in Progress
```json
{
  "error": {
    "code": "BACKUP_IN_PROGRESS",
    "message": "Cannot modify backup policy while backup is running",
    "details": {
      "current_backup_id": "backup-456",
      "estimated_completion": "2024-01-20T15:15:00Z"
    }
  }
}
```

## Webhooks

Backup events that trigger webhooks:

- `backup.policy.created`
- `backup.policy.updated`
- `backup.policy.deleted`
- `backup.started`
- `backup.completed`
- `backup.failed`
- `backup.deleted`
- `restore.started`
- `restore.completed`
- `restore.failed`

## Best Practices

1. **Storage Security**: Use encryption and access controls for backup storage
2. **Retention Policies**: Set appropriate retention periods based on compliance needs
3. **Regular Testing**: Periodically test backup restoration procedures
4. **Monitoring**: Set up alerts for backup failures and storage usage
5. **Cost Management**: Monitor storage costs and optimize retention policies