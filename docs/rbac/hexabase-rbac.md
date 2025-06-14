# Hexabase RBAC

This section covers Role-Based Access Control (RBAC) implementation within the Hexabase.AI platform itself.

## Overview

Hexabase.AI implements a comprehensive RBAC system to manage access control across the multi-tenant platform. This system defines how users interact with the platform at different organizational levels.

## Role Hierarchy

### Organization Level Roles

- **Organization Admin**: Full control over the organization
- **Organization Viewer**: Read-only access to organization resources

### Workspace Level Roles

- **Workspace Admin**: Full control over workspace resources
- **Workspace Developer**: Can create and manage applications
- **Workspace Viewer**: Read-only access to workspace resources

### Project Level Roles

- **Project Owner**: Full control over project resources
- **Project Collaborator**: Can modify project resources
- **Project Viewer**: Read-only access to project resources

## Permission Model

The Hexabase RBAC system follows these principles:

1. **Hierarchical Inheritance**: Permissions cascade from organization to workspace to project
2. **Least Privilege**: Users get minimal permissions required for their role
3. **Separation of Concerns**: Clear boundaries between different organizational levels

## Integration with Kubernetes

This page focuses on Hexabase platform RBAC. For information on how Hexabase RBAC maps to Kubernetes RBAC, see [Kubernetes RBAC](./kubernetes-rbac.md).