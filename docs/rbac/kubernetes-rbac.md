# Kubernetes RBAC

This section explains how Hexabase.AI integrates with and manages Kubernetes Role-Based Access Control.

## Overview

Hexabase.AI provides a seamless mapping between platform roles and Kubernetes RBAC, allowing users to manage Kubernetes resources through the HKS interface without directly dealing with Kubernetes complexity.

## Role Mappings

### Hexabase to Kubernetes Role Translation

| Hexabase Role | Kubernetes ClusterRole | Permissions |
|---------------|------------------------|-------------|
| Workspace Admin | cluster-admin (namespaced) | Full control within assigned namespaces |
| Workspace Developer | edit | Create, update, delete apps and services |
| Workspace Viewer | view | Read-only access to resources |

## Namespace Isolation

Each Hexabase workspace maps to one or more Kubernetes namespaces:

- **Workspace Namespace**: Primary namespace for applications
- **System Namespace**: For platform-managed resources
- **Monitoring Namespace**: For observability tools

## Service Account Management

Hexabase automatically creates and manages Kubernetes service accounts:

1. **User Service Accounts**: For human users accessing the cluster
2. **Application Service Accounts**: For workloads and CI/CD pipelines
3. **System Service Accounts**: For platform components

## Best Practices

1. **Use Hexabase Roles**: Let the platform manage Kubernetes RBAC complexity
2. **Audit Regularly**: Review role assignments through the HKS dashboard
3. **Follow Least Privilege**: Assign minimal required permissions
4. **Leverage Workspaces**: Use workspace isolation for security boundaries

## Advanced Configuration

For custom RBAC requirements, Hexabase supports:

- Custom role definitions
- Fine-grained permission policies
- Integration with external identity providers
- Compliance-driven access controls