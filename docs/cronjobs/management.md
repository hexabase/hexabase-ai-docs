# CronJob Management

This feature allows users to easily create and manage scheduled, recurring tasks within their projects using a standard, robust Kubernetes-native approach.

## User Experience and Workflow

### 1. New "Application" Type
In the UI, when creating a new application, users can select a new type: **"CronJob"**.

### 2. Configuration UI

#### Task Definition (Template-based)
- Instead of manually entering image details, users can select an existing "Stateless" Application from the same Project via a dropdown
- This action populates the CronJob template with the selected application's container image, environment variables, and resource requests
- Provides an intuitive "run a task from this app" experience

#### Command Override
Users can override the container's default command/arguments specifically for this job.

#### Schedule Configuration
- A user-friendly UI is provided for setting the schedule (e.g., presets for "hourly," "daily," "weekly") which translates to a standard cron expression
- An advanced input field is also available for users to enter a raw `cron` expression directly

### 3. Management Features
Users can:
- View a list of their CronJobs
- See the last execution time and result
- View logs from past runs
- Trigger a manual run

## Backend Implementation

The implementation follows a Kubernetes-native approach:

1. The HKS API server receives the user's configuration and translates it into a standard Kubernetes `batch/v1.CronJob` resource manifest

2. This manifest is applied to the tenant's vCluster

3. The `spec.jobTemplate` contains the full pod specification derived from the selected application template and user overrides

4. The entire lifecycle (scheduling, job creation, pod execution, cleanup) is handled by the native Kubernetes CronJob controller within the vCluster, ensuring stability and reliability

## Integration with Functions

CronJobs can be used to trigger serverless functions on a schedule:
- Configure a CronJob to run a container with `curl` or similar HTTP client
- Set the command to invoke the function's HTTP endpoint
- This provides scheduled execution for serverless functions without additional infrastructure