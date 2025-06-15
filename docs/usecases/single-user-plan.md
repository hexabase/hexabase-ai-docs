# Single User Plan Scenario

This use case outlines the journey of a single developer using the **Single User Plan** on Hexabase.AI. It's designed for individuals, freelancers, and developers working on personal projects who need a powerful Kubernetes platform without the complexity of managing a full-scale environment.

## Goal

The goal of the Single User Plan is to provide an individual developer with a powerful, cost-effective, and reliable platform to build, test, and deploy applications. It's ideal for personal projects, freelance work, or prototyping a new startup idea without the complexity of managing infrastructure.

### 1. First Login and Workspace Setup

- Upon signing up, a developer logs in for the first time.
- A personal workspace, such as `dev-workspace`, is automatically created.
- This workspace is a fully isolated environment, providing the developer with a private Kubernetes namespace.

### 2. Deploying the Application

- A developer's application might consist of a Node.js backend and a React frontend.
- Using the HKS CLI, the developer deploys application containers to the **shared node pool**. This is a cost-effective option perfect for development and staging.
- If a database is needed, a PostgreSQL instance can be provisioned from the HKS marketplace, which uses a persistent storage volume. The plan includes a limited amount of high-speed storage.

### 3. Setting up CI/CD

- The developer connects a personal GitHub repository to the project.
- A simple CI/CD pipeline is configured using a template:
  - On every `git push`, the pipeline automatically builds the container images.
  - It runs unit tests.
  - It deploys the new version to a staging environment within the workspace.

### 4. Leveraging Serverless and Scheduled Jobs

- To handle a task like sending a daily summary email, the developer creates a **CronJob** that triggers a serverless **Function** once a day.
- The Function contains the business logic, making it a highly efficient way to run scheduled tasks.

### 5. AIOps Assistance

- If the application experiences a performance issue, the integrated **AIOps assistant** can detect the anomaly (e.g., a memory leak).
- It can proactively notify the developer via Slack with a detailed report and a suggestion for remediation, saving hours of troubleshooting.
- The AIOps features on this plan are focused on core monitoring and anomaly detection.

### 6. Scaling Up: Dedicated Node

- As the application gets ready for production, it may require more performance and resource guarantees.
- The developer can upgrade the plan to include a **dedicated node**.
- From the UI, a new dedicated node is provisioned and added to the workspace, allowing the production deployment to be moved for higher performance and isolation.

## Summary of Features Used

| Feature           | Single User Plan Usage                                                     |
| :---------------- | :------------------------------------------------------------------------- |
| **Workspace**     | 1 personal, isolated workspace.                                            |
| **Nodes**         | Default access to shared node pool. Option to upgrade for dedicated nodes. |
| **CI/CD**         | Simple, template-based pipelines for automated build and deploy.           |
| **Functions**     | Limited number of serverless functions for event-driven tasks.             |
| **CronJobs**      | Ability to schedule recurring jobs.                                        |
| **Storage**       | Limited persistent storage for stateful applications like databases.       |
| **AIOps**         | Core AIOps features: anomaly detection, basic monitoring, and alerts.      |
| **Multi-tenancy** | User-level isolation within a single-tenant workspace.                     |
