# Multi-Tenancy in Hexabase.AI

## Overview

Hexabase.AI provides enterprise-grade multi-tenancy through a hierarchical structure built on K3s and vCluster technology. This architecture enables organizations to securely share infrastructure while maintaining strict isolation between different teams, projects, and environments.

## Hierarchical Structure

Hexabase.AI implements a three-tier multi-tenancy model:

```
Organization (Billing Entity)
└── Workspaces (vCluster Isolation)
    └── Projects (Namespace Isolation)
        └── Applications & Resources
```

### Organizations

- **Purpose**: Top-level billing and administrative boundary
- **Scope**: Platform-wide entity managed by Hexabase.AI
- **Users**: Organization administrators manage billing, user invitations, and workspace creation
- **Isolation**: Complete separation between different organizations

### Workspaces

- **Purpose**: Isolated Kubernetes environments for teams or environments (dev/staging/prod)
- **Technology**: Each workspace is a dedicated vCluster running on the host K3s cluster
- **Benefits**: 
  - Complete API server isolation
  - Independent Kubernetes control plane
  - Own RBAC system and resource quotas
  - Optional dedicated nodes for premium plans
- **Users**: Workspace members with kubectl access and OIDC authentication

### Projects

- **Purpose**: Application and resource isolation within a workspace
- **Technology**: Kubernetes namespaces within the vCluster
- **Benefits**:
  - Resource quotas per project
  - Network policies for isolation
  - Project-specific RBAC roles
  - Environment-specific configurations

## RBAC Integration

### Hexabase.AI RBAC + Kubernetes RBAC

Hexabase.AI implements a dual-layer RBAC system:

#### Platform Level (Hexabase.AI)
- **Organization Users**: Platform-level access for billing and administration
- **Workspace Members**: Technical users with access to specific workspaces
- **Workspace Groups**: Hierarchical permission assignment units

#### Workspace Level (Kubernetes/vCluster)
- **ClusterRoles**: Workspace-wide permissions (e.g., `hexabase:workspace-admin`, `hexabase:workspace-viewer`)
- **Roles**: Project-scoped permissions within namespaces
- **OIDC Integration**: Hexabase.AI acts as OIDC provider for vClusters

### Default RBAC Setup

When a workspace is created:

1. **Auto-create ClusterRoles**:
   - `hexabase:workspace-admin` - Full workspace control
   - `hexabase:workspace-viewer` - Read-only workspace access

2. **Create Default Groups**:
   - `WorkspaceMembers` → `WSAdmins` (administrators)
   - `WorkspaceMembers` → `WSUsers` (regular users)

3. **Assign Creator**: Workspace creator automatically added to `WSAdmins` group

### Permission Flow

```
User Login → OIDC Token → Group Claims → vCluster RBAC → Project Access
```

- Users authenticate via external IdP (Google/GitHub)
- Hexabase.AI adds group claims to OIDC tokens
- vCluster validates tokens and applies Kubernetes RBAC
- Users get appropriate access to projects/resources

## Isolation Mechanisms

### vCluster Isolation (Workspace Level)

Each workspace provides complete isolation through:

- **Dedicated API Server**: Independent Kubernetes API server per workspace
- **Separate etcd**: Isolated data storage for each workspace
- **Independent Controllers**: Workspace-specific controller managers
- **Network Isolation**: vCluster networking prevents cross-workspace communication
- **Resource Boundaries**: CPU, memory, and storage quotas per workspace

### Namespace Isolation (Project Level)

Within each workspace, projects are isolated via:

- **Kubernetes Namespaces**: Standard namespace-based resource isolation
- **Resource Quotas**: Per-project limits on compute and storage resources
- **Network Policies**: Project-to-project communication controls
- **RBAC Boundaries**: Project-specific roles and permissions

## Workspace Management

### Workspace Creation Flow

1. **Organization Admin** creates workspace through Hexabase.AI UI
2. **vCluster Provisioning**: New vCluster deployed on host K3s cluster
3. **OIDC Configuration**: Workspace configured to trust Hexabase.AI as OIDC provider
4. **Default Setup**: ClusterRoles and groups automatically created
5. **User Assignment**: Workspace creator added to admin group

### Workspace Plans

- **Shared Plan**: Multiple workspaces share the same K3s nodes
- **Dedicated Plan**: Workspace gets dedicated K3s nodes for guaranteed resources

### Project Management

Projects (namespaces) within workspaces can be managed via:
- **Hexabase.AI UI**: Point-and-click project creation and management
- **kubectl**: Direct Kubernetes CLI access with proper RBAC
- **API**: Programmatic project management via Hexabase.AI API

## User Workflows

### Organization Admin Workflow

1. **Create Organization**: Automatic on first signup with external IdP
2. **Manage Billing**: Configure Stripe billing and subscription plans
3. **Invite Users**: Send invitations to join organization
4. **Create Workspaces**: Provision isolated environments for teams
5. **Monitor Usage**: Track resource consumption and costs across workspaces

### Workspace Member Workflow

1. **Join Workspace**: Accept invitation from organization admin
2. **Get Kubeconfig**: Download workspace-specific kubeconfig file
3. **Create Projects**: Set up isolated environments for applications
4. **Deploy Applications**: Use kubectl, Hexabase.AI UI, or CI/CD pipelines
5. **Manage Access**: Add project-specific permissions for team members

## Security Model

### Authentication Flow

```
External IdP (Google/GitHub) → Hexabase.AI → vCluster OIDC → Kubernetes RBAC
```

### Key Security Features

- **External IdP Only**: No local passwords, all authentication via trusted providers
- **vCluster Isolation**: Complete API server isolation prevents cross-workspace access
- **OIDC Integration**: Workspace authentication handled by Hexabase.AI OIDC provider
- **Network Policies**: Default deny-all policies with explicit allow rules
- **Audit Logging**: Complete audit trail of all API operations
- **Policy Enforcement**: Kyverno policies for security and compliance

## Resource Management

### Workspace-Level Quotas

Each workspace can be configured with:
- CPU and memory limits
- Storage quotas
- Network bandwidth limits
- Number of allowed projects/namespaces

### Project-Level Quotas

Within each workspace, projects have:
- Resource requests and limits
- Object count limits (pods, services, etc.)
- Storage class restrictions
- Priority class assignments

## Monitoring & Observability

### Built-in Monitoring

- **Prometheus**: Metrics collection per workspace and project
- **Grafana**: Pre-built dashboards for workspace and project health
- **Loki**: Centralized logging with workspace/project filtering
- **AIOps**: AI-powered insights and recommendations per workspace

### Cost Tracking

- **Per-workspace billing**: Resource usage tracked and billed separately
- **Project-level costs**: Granular cost breakdown within workspaces
- **Resource optimization**: AI-powered recommendations for cost reduction

## Related Topics

- [Technology Stack](./technology-stack.md) - Core technologies powering multi-tenancy
- [RBAC Overview](../rbac/overview.md) - Detailed RBAC implementation
- [Architecture Overview](../architecture/index.md) - System architecture and design decisions
