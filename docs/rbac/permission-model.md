# Permission Model

The Hexabase.AI permission model is designed to be flexible and extensible, providing fine-grained control over every action within the platform. While most users will interact with the built-in roles, understanding the underlying permission model is useful for creating custom roles or for auditing purposes.

## The Structure of a Permission

A permission is a single rule that defines who can do what to which resources. Each permission consists of three components:

1.  **`apiGroups`**: The group of the API being accessed. For core Kubernetes resources, the group is `""` (an empty string). For others, it's a named group like `apps`, `batch`, or `hks.io`.
2.  **`resources`**: The type of object the permission applies to (e.g., `pods`, `deployments`, `backupplans`).
3.  **`verbs`**: The action that is allowed on the resource (e.g., `get`, `create`, `delete`).

**Example Permission Statement:**
"Allow `creating` (`verb`) `deployments` (`resource`) in the `apps` (`apiGroup`)."

## How Permissions Are Defined in a Role

In a custom `WorkspaceRole`, permissions are defined in a list.

```yaml
apiVersion: hks.io/v1
kind: WorkspaceRole
metadata:
  name: custom-viewer
spec:
  permissions:
    # Rule 1: Allow viewing of core workload resources
    - apiGroups: ["", "apps", "batch"]
      resources: ["pods", "deployments", "jobs", "services"]
      verbs: ["get", "list", "watch"]

    # Rule 2: Allow viewing of pod logs
    - apiGroups: [""]
      resources: ["pods/log"]
      verbs: ["get", "list", "watch"]

    # Rule 3: Allow viewing of HKS-specific resources
    - apiGroups: ["hks.io"]
      resources: ["backups", "functions"]
      verbs: ["get", "list", "watch"]
```

## Common Verbs

These are the most common actions (verbs) you can assign in a permission.

| Verb               | Description                                             |
| :----------------- | :------------------------------------------------------ |
| `get`              | Retrieve a single resource by name.                     |
| `list`             | Retrieve a list of resources.                           |
| `watch`            | "Watch" for changes to resources in real-time.          |
| `create`           | Create a new resource.                                  |
| `update`           | Modify an existing resource.                            |
| `patch`            | Apply a partial modification to an existing resource.   |
| `delete`           | Delete a resource.                                      |
| `deletecollection` | Delete multiple resources at once.                      |
| `*`                | A wildcard that represents all verbs. Use with caution. |

## Resource Naming and Sub-resources

Some resources have sub-resources that can be controlled independently. The most common example is `pods/log`.

- To grant permission to view a pod, you need `get` on the `pods` resource.
- To grant permission to view a pod's logs, you need `get` on the `pods/log` sub-resource.

This allows you to create roles for users who can see that a pod is running but cannot access the potentially sensitive information within its logs.

## Aggregated Roles

Hexabase.AI makes use of Kubernetes's role aggregation feature. This means that some roles are composed of other roles.

For example, the built-in `developer` role in HKS actually aggregates several smaller, more focused roles:

- A role for managing core workloads (`pods`, `deployments`).
- A role for managing networking (`services`, `ingresses`).
- A role for managing CI/CD resources within the workspace.

This makes the system easier to manage and extend. When a new feature is added to HKS, a new granular role for that feature can be created and aggregated into the base roles (`admin`, `developer`, `viewer`) without modifying the base roles directly.

## Viewing Raw Kubernetes Roles

If you have `workspace_admin` permissions, you can view the raw Kubernetes `Role` that HKS generates from its own `WorkspaceRole`.

```bash
# First, find the name of the generated role
# It will typically be prefixed with 'hks-'
kubectl get roles -n <your-workspace-namespace>

# Then, view the YAML definition of the role
kubectl get role <generated-role-name> -o yaml
```

This can be a useful debugging tool for understanding the exact permissions being applied at the Kubernetes level.
