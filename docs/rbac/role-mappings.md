# Role Mappings

Understanding how Hexabase.AI's built-in roles map to specific permissions is key to effective access management. This document details the permissions associated with the default roles at both the Organization and Workspace levels.

## Organization-Level Roles

These roles control access to the platform's administrative and management features.

| Role                     | Description                                                   | Key Permissions                                                                                                                                                                                                        |
| :----------------------- | :------------------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`organization_admin`** | The highest level of access. Manages the entire organization. | - Invite and manage users<br>- Create, update, and delete workspaces<br>- Configure Single Sign-On (SSO)<br>- Manage billing and subscriptions<br>- View organization-wide audit logs<br>- Assign any role to any user |
| **`organization_user`**  | The default role for a standard member of the organization.   | - View workspaces they have been invited to<br>- Cannot manage users, billing, or workspaces<br>- Can be assigned roles _within_ specific workspaces                                                                   |

---

## Workspace-Level Roles

These roles control access to the Kubernetes resources _inside_ a specific workspace. HKS provides three default roles, which cover most common use cases.

### `workspace_admin`

- **Description**: Full control over a specific workspace. This role is typically assigned to team leads or DevOps engineers responsible for an environment.
- **Key HKS Permissions**:
  - Manage user access to the workspace (assign `developer` or `viewer` roles).
  - Configure workspace settings, such as resource quotas and network policies.
  - View all resources and settings within the workspace.
- **Mapped Kubernetes Permissions**:
  - `*` (All verbs) on `*` (All resources) within the workspace's namespace. This is equivalent to the built-in `admin` ClusterRole in Kubernetes, but scoped to the namespace.

### `developer`

- **Description**: Standard permissions for an application developer. Allows for the full lifecycle management of applications without granting access to sensitive security or user management settings.
- **Key HKS Permissions**:
  - Create, update, and delete application workloads.
  - View logs and exec into pods.
  - Manage application configurations (ConfigMaps, Secrets).
- **Mapped Kubernetes Permissions (Abbreviated)**:
  - `get`, `list`, `watch`, `create`, `update`, `patch`, `delete` on:
    - `pods`, `deployments`, `statefulsets`, `daemonsets`
    - `services`, `ingresses`
    - `jobs`, `cronjobs`
    - `configmaps`, `secrets`
    - `persistentvolumeclaims`
  - `get`, `list`, `watch` on `pods/log`.

### `viewer`

- **Description**: Read-only access to a workspace. Ideal for stakeholders, support staff, or junior developers who need to observe but not modify applications.
- **Key HKS Permissions**:
  - View all resources and their configurations.
  - View logs.
- **Mapped Kubernetes Permissions**:
  - `get`, `list`, `watch` on all resources within the workspace's namespace. This is equivalent to the built-in `view` ClusterRole in Kubernetes.

## Creating Custom Roles (Enterprise Plan)

For organizations that need more granular control, the Enterprise Plan allows for the creation of custom workspace roles.

**Example: Creating a `db_operator` Role**

Imagine you want a role that can only manage StatefulSets (for databases) and their associated Secrets and PVCs.

```yaml
# custom-role-db-operator.yaml
apiVersion: hks.io/v1
kind: WorkspaceRole
metadata:
  name: db-operator
spec:
  # The permissions this role grants
  permissions:
    # Allow full control over StatefulSets
    - resources: ["statefulsets"]
      verbs: ["*"]
    # Allow full control over secrets and PVCs
    - resources: ["secrets", "persistentvolumeclaims"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    # Allow viewing of pods for debugging
    - resources: ["pods", "pods/log"]
      verbs: ["get", "list", "watch"]
```

After applying this manifest, you can assign the `db_operator` role to users in any workspace, just like the built-in roles. HKS will automatically generate the corresponding Kubernetes `Role` and `RoleBinding` in the background.
