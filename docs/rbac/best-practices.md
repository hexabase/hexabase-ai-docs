# RBAC Best Practices

Properly configuring Role-Based Access Control (RBAC) is one of the most important aspects of securing your Hexabase.AI environment. Following these best practices will help you maintain a secure and manageable system.

## 1. Adhere to the Principle of Least Privilege (PoLP)

This is the most fundamental principle of access control.

- **Grant only what is needed**: Users and service accounts should only have the permissions absolutely necessary to perform their jobs.
- **Avoid wildcard permissions**: Do not use `*` for resources or verbs in custom roles unless it is truly required. Be explicit.
- **Start with `viewer`**: When a new user joins a project, grant them the `viewer` role first. Elevate their permissions to `developer` only when they need to start making changes.
- **Use `workspace_admin` sparingly**: The `workspace_admin` role is highly privileged. Reserve it for team leads or platform administrators responsible for managing the workspace itself, not for daily development tasks.

## 2. Separate User and Service Account Management

- **No shared accounts**: Every human user should have their own named account. Do not use shared accounts (e.g., a single `developer` account for the whole team). This ensures accountability through audit logs.
- **Dedicated service accounts for applications**: Each application or CI/CD job should have its own dedicated `ServiceAccount`. This isolates permissions, so if one service account is compromised, the blast radius is limited. For example, the `ci-builder` service account should not have the same permissions as the `production-app` service account.

## 3. Leverage the Two-Tiered RBAC System

- **Use Organization roles for platform administration**: Manage users, workspaces, and billing at the organization level with `organization_admin`.
- **Use Workspace roles for application development**: Manage Kubernetes resources and application lifecycles at the workspace level with `workspace_admin`, `developer`, and `viewer`.
- **Do not give everyone `organization_admin`**: This role is equivalent to being a super-user for your entire HKS environment. Its use should be restricted to a very small number of trusted platform administrators.

## 4. Regularly Audit RBAC Policies and Bindings

- **Schedule periodic reviews**: At least quarterly, an `organization_admin` or `workspace_admin` should review all role bindings.
- **Look for stale access**: Remove users who are no longer on the project.
- **Identify overly permissive roles**: Check if any users have more permissions than they need. Could a `workspace_admin` be a `developer` instead?
- **Automate auditing**: Use the `hks` CLI to script parts of your audit.

  ```bash
  # List all users in a workspace and their roles
  hks list-users --workspace my-prod-space

  # Check the permissions of a specific custom role
  hks get workspacerole custom-role -o yaml
  ```

## 5. Use Custom Roles for Fine-Grained Control

- **Don't stretch default roles**: If the built-in `developer` role is too permissive for a specific task, don't just grant it anyway. Create a custom role instead.
- **Example**: Create a `ci-runner` role that can only create `Pods` and `Jobs` but cannot create `Deployments` or `Services`.
- **Example**: Create a `support-staff` role that can view all resources and `exec` into pods for debugging, but cannot view `Secrets`.

## 6. Secure the Underlying Kubernetes RBAC

- **Avoid manual `kubectl` changes**: Do not manually create `Roles` or `RoleBindings` using `kubectl`. Let Hexabase.AI manage the Kubernetes RBAC resources. Manually creating bindings can lead to confusion and a "split-brain" scenario where the HKS UI and the Kubernetes state are out of sync.
- **Restrict direct `kubectl` access**: For most users, all interactions should be through the HKS platform (UI, CLI, API). Limit direct `kubectl` access to platform administrators or for break-glass emergency scenarios. This ensures all actions go through the HKS audit log.
