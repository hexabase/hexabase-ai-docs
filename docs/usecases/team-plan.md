# Team Plan Scenario

This use case describes a development team leveraging the **Team Plan** on Hexabase.AI. This plan is ideal for startups and small-to-medium-sized businesses that need to collaborate on multiple projects with shared infrastructure and governance.

## Goal

The goal of the Team Plan is to provide a collaborative, secure, and governed platform for startups and development teams. It is designed for teams who need to manage multiple projects across different environments (e.g., development, staging, production) with shared infrastructure and clear, role-based access control.

### 1. Organization and Team Setup

- An administrator signs up for the Team Plan and creates an organization (e.g., `MyStartupInc`).
- The administrator invites DevOps engineers as **Org Admins** and other team members as **Org Users**.
- This role-based access control (RBAC) ensures that only Org Admins can manage billing, create new workspaces, and set organization-wide policies.

### 2. Workspace Creation

- The Org Admins create multiple workspaces to separate environments, such as:
  - **`SaaS-Product-Dev`**: For daily development and testing.
  - **`SaaS-Product-Staging`**: A more stable environment for pre-production testing.
- Admins assign teams and users to these workspaces, granting them appropriate permissions (e.g., `workspace-admin`, `developer`).

### 3. Resource Management and Infrastructure

- To support the team's needs, Org Admins provision several **dedicated nodes** for the organization, which can be shared across workspaces.
- They also attach high-performance **block storage** for databases and a separate object storage bucket for **automated backups**.
- Resource quotas are set on the development workspace to prevent any single user from consuming excessive resources.

### 4. Collaborative Development and CI/CD

- The team's projects are hosted in a central Git repository like GitLab or GitHub.
- DevOps engineers set up advanced CI/CD pipelines:
  - Feature branches are automatically deployed to isolated preview environments.
  - Merges to a `main` branch trigger deployments to the `SaaS-Product-Dev` workspace.
  - Promotions to staging require a manual approval step from a workspace admin.

### 5. Advanced AIOps and Observability

- The staging and production workspaces have full-featured **AIOps** enabled.
- The AIOps assistant analyzes logs, traces, and metrics to provide insights into application performance and potential bottlenecks.
- It also offers cost-optimization recommendations, suggesting rightsizing for over-provisioned resources.
- While the team has access to powerful observability tools, this plan has some limitations on the retention period for **audit logs** compared to the Enterprise plan.

### 6. Disaster Recovery (DR) and Backups

- Org Admins configure a basic disaster recovery plan.
- Daily snapshots of critical database volumes are automatically taken and stored in a secure, geo-redundant location.
- The team can easily restore from these backups in case of data loss.

## Summary of Features Used

| Feature               | Team Plan Usage                                                                           |
| :-------------------- | :---------------------------------------------------------------------------------------- |
| **Organization**      | Centralized management of users, billing, and resources.                                  |
| **RBAC**              | Roles for Org Admins and Org Users, providing clear separation of duties.                 |
| **Workspaces**        | Multiple workspaces for different environments (dev, staging).                            |
| **Nodes**             | Ability to provision and share dedicated nodes across workspaces.                         |
| **Storage & Backups** | Support for advanced storage solutions and automated backup configurations.               |
| **Disaster Recovery** | Basic disaster recovery options available.                                                |
| **CI/CD**             | Fully functional pipelines with approvals and multi-environment deployments.              |
| **AIOps**             | Advanced AIOps capabilities for performance tuning and cost optimization.                 |
| **Audit & Security**  | Access to audit logs and security features, with some limitations on retention and scope. |
