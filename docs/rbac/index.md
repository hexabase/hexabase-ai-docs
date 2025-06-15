# Kubernetes RBAC

Learn how Hexabase.AI implements and manages Role-Based Access Control (RBAC) for secure multi-tenant Kubernetes operations.

## Overview

Hexabase.AI provides a sophisticated RBAC system that extends Kubernetes native RBAC with additional features for multi-tenancy, simplified management, and enhanced security. Our RBAC implementation ensures that users have exactly the permissions they need—no more, no less.

## RBAC Components

<div class="grid cards" markdown>

- :material-account-key:{ .lg .middle } **Roles and Permissions**

  ***

  Understand predefined roles and custom permission models

  [:octicons-arrow-right-24: Explore Roles](hexabase-rbac.md)

- :material-account-group:{ .lg .middle } **User Management**

  ***

  Managing users, groups, and service accounts

  [:octicons-arrow-right-24: User Management Guide](kubernetes-rbac.md)

- :material-shield-check:{ .lg .middle } **Policy Configuration**

  ***

  Configure and customize access policies

  [:octicons-arrow-right-24: Policy Configuration](kubernetes-rbac.md)

- :material-book-open:{ .lg .middle } **Best Practices**

  ***

  Security best practices and common patterns

  [:octicons-arrow-right-24: RBAC Best Practices](best-practices.md)

</div>

## RBAC Model

Hexabase.AI implements a hierarchical RBAC model that provides fine-grained access control:

```
Organization
├── Organization Roles (Admin, Viewer)
└── Workspace
    ├── Workspace Roles (Owner, Developer, Viewer)
    └── Project
        └── Kubernetes RBAC (Native Roles)
```

### Key Features

#### 1. Multi-level Permissions

- **Organization Level**: Control who can create workspaces and manage billing
- **Workspace Level**: Manage project deployment and resource quotas
- **Project Level**: Fine-grained Kubernetes permissions

#### 2. Predefined Roles

- **Organization Admin**: Full control over organization
- **Workspace Owner**: Manage workspace and deploy projects
- **Developer**: Deploy and manage applications
- **Viewer**: Read-only access to resources

#### 3. Custom Roles

- Create custom roles with specific permissions
- Combine multiple permissions for complex scenarios
- Template-based role creation

#### 4. Dynamic Permission Inheritance

- Permissions cascade from organization to workspace
- Override inherited permissions at lower levels
- Automatic permission propagation

## Common RBAC Scenarios

### Scenario 1: Development Team Setup

```yaml
Team Structure:
  - Team Lead: Workspace Owner
  - Developers: Developer role with deployment permissions
  - QA Engineers: Viewer role with log access
  - CI/CD Service: Service account with deployment permissions
```

### Scenario 2: Multi-Environment Access

```yaml
Environment Setup:
  - Production: Limited to senior developers and SREs
  - Staging: Open to all developers
  - Development: Self-service for all team members
```

### Scenario 3: Client Access

```yaml
External Access:
  - Client stakeholders: Viewer role for specific workspaces
  - Contractors: Time-limited developer access
  - Auditors: Read-only access with audit log visibility
```

## Security Considerations

### Principle of Least Privilege

- Users get minimal permissions required
- Regular permission audits
- Automated permission cleanup

### Separation of Duties

- Different roles for deployment and approval
- Separate production access controls
- Audit trail for all permission changes

### Defense in Depth

- Multiple layers of access control
- Network policies complement RBAC
- Resource quotas prevent abuse

## Quick Start Examples

### Granting Developer Access

```bash
hks rbac grant-role developer user@example.com --workspace my-workspace
```

### Creating Custom Role

```bash
hks rbac create-role custom-deployer \
  --permissions deploy,view-logs,manage-secrets \
  --workspace my-workspace
```

### Viewing User Permissions

```bash
hks rbac list-permissions user@example.com
```

## Integration with Kubernetes

Hexabase.AI RBAC seamlessly integrates with native Kubernetes RBAC:

1. **Automatic Translation**: Platform roles map to Kubernetes roles
2. **Service Account Management**: Automated service account creation
3. **Namespace Isolation**: RBAC policies enforce namespace boundaries
4. **Audit Compliance**: All actions logged for compliance

## Next Steps

- **New to RBAC?** Start with [Roles and Permissions](hexabase-rbac.md)
- **Setting up users?** Follow the [User Management Guide](kubernetes-rbac.md)
- **Need custom policies?** Learn about [Policy Configuration](kubernetes-rbac.md)
- **Security focus?** Review [RBAC Best Practices](best-practices.md)

## Related Documentation

- [Security Architecture](../architecture/security-architecture.md)
- [Core Concepts](../concept/index.md)
- [API Authentication](../api/authentication.md)
- [Audit Logging](../security/compliance.md#audit-logs-for-compliance)
