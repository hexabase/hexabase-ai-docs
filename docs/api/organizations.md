# Organizations API

Organizations are the top-level entities in Hexabase.AI that group workspaces and manage billing. Each user can belong to multiple organizations with different roles.

## Base URL

All organization endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/organizations
```

## Organization Object

```json
{
  "id": "org-123",
  "name": "My Organization",
  "slug": "my-org",
  "description": "Organization description",
  "owner_id": "user-123",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-20T00:00:00Z",
  "member_count": 5,
  "workspace_count": 3,
  "billing": {
    "plan": "pro",
    "status": "active"
  }
}
```

## Endpoints

### List Organizations

Get all organizations the authenticated user belongs to.

```http
GET /api/v1/organizations
```

**Query Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20, max: 100)
- `search` (string) - Search by organization name
- `role` (string) - Filter by user's role (`owner`, `admin`, `member`)

**Response:**
```json
{
  "data": [
    {
      "id": "org-123",
      "name": "My Organization",
      "slug": "my-org",
      "owner_id": "user-123",
      "created_at": "2024-01-01T00:00:00Z",
      "member_count": 5,
      "workspace_count": 3,
      "user_role": "admin"
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

### Create Organization

Create a new organization. The authenticated user becomes the owner.

```http
POST /api/v1/organizations
```

**Request Body:**
```json
{
  "name": "My Organization",
  "description": "Organization for my team's projects"
}
```

**Validation:**
- `name` - Required, 3-50 characters, alphanumeric with spaces
- `description` - Optional, max 500 characters

**Response:**
```json
{
  "data": {
    "id": "org-123",
    "name": "My Organization",
    "slug": "my-organization",
    "description": "Organization for my team's projects",
    "owner_id": "user-123",
    "created_at": "2024-01-20T10:00:00Z",
    "member_count": 1,
    "workspace_count": 0
  }
}
```

### Get Organization

Get detailed information about a specific organization.

```http
GET /api/v1/organizations/:orgId
```

**Response:**
```json
{
  "data": {
    "id": "org-123",
    "name": "My Organization",
    "slug": "my-organization",
    "description": "Organization for my team's projects",
    "owner_id": "user-123",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-20T00:00:00Z",
    "member_count": 5,
    "workspace_count": 3,
    "billing": {
      "plan": "pro",
      "status": "active",
      "current_period_end": "2024-02-01T00:00:00Z"
    },
    "limits": {
      "workspaces": 10,
      "members": 50,
      "api_calls_per_hour": 10000
    },
    "usage": {
      "workspaces": 3,
      "members": 5,
      "api_calls_this_hour": 342
    }
  }
}
```

### Update Organization

Update organization details. Requires `admin` or `owner` role.

```http
PATCH /api/v1/organizations/:orgId
```

**Request Body:**
```json
{
  "name": "Updated Organization Name",
  "description": "Updated description"
}
```

**Validation:**
- Same as create endpoint
- All fields are optional

**Response:**
```json
{
  "data": {
    "id": "org-123",
    "name": "Updated Organization Name",
    "slug": "updated-organization-name",
    "description": "Updated description",
    "updated_at": "2024-01-20T15:00:00Z"
  }
}
```

### Delete Organization

Delete an organization. Requires `owner` role. This action is irreversible and will delete all associated workspaces and data.

```http
DELETE /api/v1/organizations/:orgId
```

**Response:**
```json
{
  "data": {
    "message": "Organization deleted successfully"
  }
}
```

## Organization Members

### List Members

Get all members of an organization.

```http
GET /api/v1/organizations/:orgId/members
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `role` (string) - Filter by role
- `search` (string) - Search by name or email

**Response:**
```json
{
  "data": [
    {
      "id": "member-123",
      "user_id": "user-123",
      "organization_id": "org-123",
      "role": "admin",
      "joined_at": "2024-01-01T00:00:00Z",
      "invited_by": "user-456",
      "user": {
        "id": "user-123",
        "email": "john@example.com",
        "name": "John Doe",
        "picture": "https://...",
        "last_active": "2024-01-20T14:00:00Z"
      }
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

### Remove Member

Remove a member from the organization. Requires `admin` or `owner` role.

```http
DELETE /api/v1/organizations/:orgId/members/:userId
```

**Response:**
```json
{
  "data": {
    "message": "Member removed successfully"
  }
}
```

### Update Member Role

Change a member's role in the organization. Requires `owner` role.

```http
PUT /api/v1/organizations/:orgId/members/:userId/role
```

**Request Body:**
```json
{
  "role": "admin"
}
```

**Valid Roles:**
- `owner` - Full control (only one per organization)
- `admin` - Can manage members and workspaces
- `member` - Can access workspaces

**Response:**
```json
{
  "data": {
    "id": "member-123",
    "user_id": "user-123",
    "role": "admin",
    "updated_at": "2024-01-20T15:00:00Z"
  }
}
```

## Organization Invitations

### Invite User

Invite a new user to join the organization. Requires `admin` or `owner` role.

```http
POST /api/v1/organizations/:orgId/invitations
```

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "role": "member",
  "message": "Join our team on Hexabase!"
}
```

**Validation:**
- `email` - Required, valid email format
- `role` - Required, valid role
- `message` - Optional, custom invitation message

**Response:**
```json
{
  "data": {
    "id": "invite-123",
    "organization_id": "org-123",
    "email": "newuser@example.com",
    "role": "member",
    "token": "invitation-token-abc123",
    "expires_at": "2024-01-27T00:00:00Z",
    "created_at": "2024-01-20T15:00:00Z",
    "created_by": "user-123",
    "status": "pending"
  }
}
```

### List Pending Invitations

Get all pending invitations for the organization.

```http
GET /api/v1/organizations/:orgId/invitations
```

**Query Parameters:**
- `status` (string) - Filter by status (`pending`, `accepted`, `expired`)
- `page` (integer) - Page number
- `per_page` (integer) - Items per page

**Response:**
```json
{
  "data": [
    {
      "id": "invite-123",
      "email": "newuser@example.com",
      "role": "member",
      "expires_at": "2024-01-27T00:00:00Z",
      "created_at": "2024-01-20T00:00:00Z",
      "created_by": {
        "id": "user-123",
        "name": "John Doe"
      },
      "status": "pending"
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

### Accept Invitation

Accept an organization invitation using the invitation token.

```http
POST /api/v1/organizations/invitations/:token/accept
```

**Note:** This endpoint does not require authentication if the user is not logged in. If not authenticated, it will redirect to the login flow first.

**Response:**
```json
{
  "data": {
    "organization": {
      "id": "org-123",
      "name": "My Organization"
    },
    "membership": {
      "id": "member-456",
      "role": "member",
      "joined_at": "2024-01-20T15:30:00Z"
    }
  }
}
```

### Cancel Invitation

Cancel a pending invitation. Requires `admin` or `owner` role.

```http
DELETE /api/v1/organizations/invitations/:invitationId
```

**Response:**
```json
{
  "data": {
    "message": "Invitation cancelled successfully"
  }
}
```

## Organization Statistics

### Get Organization Stats

Get usage statistics and summary information for the organization.

```http
GET /api/v1/organizations/:orgId/stats
```

**Response:**
```json
{
  "data": {
    "members": {
      "total": 25,
      "by_role": {
        "owner": 1,
        "admin": 4,
        "member": 20
      },
      "active_last_30_days": 22
    },
    "workspaces": {
      "total": 5,
      "by_status": {
        "active": 4,
        "suspended": 1
      },
      "by_plan": {
        "shared": 2,
        "dedicated": 3
      }
    },
    "resources": {
      "total_cpu_cores": 50,
      "total_memory_gb": 200,
      "total_storage_gb": 1000,
      "utilization": {
        "cpu_percentage": 65,
        "memory_percentage": 72,
        "storage_percentage": 45
      }
    },
    "activity": {
      "deployments_last_7_days": 45,
      "api_calls_last_24_hours": 12543,
      "active_applications": 67
    },
    "billing": {
      "current_monthly_cost": 1250.00,
      "projected_monthly_cost": 1350.00,
      "cost_by_workspace": [
        {
          "workspace_id": "ws-123",
          "name": "Production",
          "cost": 750.00
        }
      ]
    }
  }
}
```

## Error Responses

All endpoints may return the following errors:

### 400 Bad Request
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "name": "Organization name is required"
    }
  }
}
```

### 403 Forbidden
```json
{
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "You don't have permission to perform this action",
    "details": {
      "required_role": "admin",
      "your_role": "member"
    }
  }
}
```

### 404 Not Found
```json
{
  "error": {
    "code": "ORGANIZATION_NOT_FOUND",
    "message": "Organization not found",
    "details": {
      "organization_id": "org-123"
    }
  }
}
```

### 409 Conflict
```json
{
  "error": {
    "code": "DUPLICATE_INVITATION",
    "message": "User is already invited or is a member",
    "details": {
      "email": "user@example.com"
    }
  }
}
```

## Webhooks

Organization events that trigger webhooks:

- `organization.created`
- `organization.updated`
- `organization.deleted`
- `organization.member.added`
- `organization.member.removed`
- `organization.member.role_changed`
- `organization.invitation.sent`
- `organization.invitation.accepted`
- `organization.invitation.cancelled`

## Rate Limits

Organization endpoints have the following rate limits:

- Create organization: 5 per hour per user
- Update organization: 20 per hour per organization
- Invite users: 50 per hour per organization
- Other endpoints: Standard API rate limits apply