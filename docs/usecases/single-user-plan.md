# Single User Plan Scenarios

This use case outlines the journey of a single developer using Hexabase.AI. We offer two plans for individual developers: **Hobby Plan** for personal projects and learning, and **Pro Plan** for production workloads requiring dedicated resources.

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

## Summary of Features

### Hobby Plan Features

| Feature       | Hobby Plan Usage               |
| :------------ | :----------------------------- |
| **Workspace** | 1 personal, isolated workspace |
| **Nodes**     | Shared node pool only          |
| **CI/CD**     | Basic template-based pipelines |
| **Functions** | Up to 5 serverless functions   |
| **CronJobs**  | Up to 10 scheduled jobs        |
| **Storage**   | 10GB persistent storage        |
| **AIOps**     | Basic monitoring and alerts    |
| **Support**   | Community support              |

## Pro Plan Features

When you're ready to take your project to production, upgrade to the Pro Plan for enhanced capabilities:

| Feature       | Pro Plan Usage                                                             |
| :------------ | :------------------------------------------------------------------------- |
| **Workspace** | 1 personal workspace with production-grade isolation                       |
| **Nodes**     | 1 dedicated node included (upgradeable)                                    |
| **CI/CD**     | Advanced pipelines with parallel builds                                    |
| **Functions** | Unlimited serverless functions                                             |
| **CronJobs**  | Unlimited scheduled jobs                                                   |
| **Storage**   | 100GB high-performance SSD storage                                         |
| **AIOps**     | Full AIOps suite: anomaly detection, predictive scaling, cost optimization |
| **Backup**    | Automated daily backups with 7-day retention                               |
| **Support**   | Priority email support with 24-hour response time                          |

### Upgrading from Hobby to Pro

The upgrade process is seamless:

1. Click "Upgrade to Pro" in your dashboard
2. Your existing workloads continue running without interruption
3. A dedicated node is provisioned within minutes
4. Migrate critical workloads to the dedicated node for better performance
5. Enjoy enhanced features and support immediately
