# UI Configuration for CronJobs

While CronJobs can be managed via YAML manifests and the `hks` CLI, the Hexabase.AI web UI provides a user-friendly interface for creating, managing, and monitoring your scheduled jobs.

## Creating a CronJob in the UI

1.  **Navigate to your Workspace**: Select the workspace where you want the CronJob to run.
2.  **Go to the CronJobs Section**: From the side navigation, click on "CronJobs".
3.  **Click "Create CronJob"**: This will open a step-by-step wizard.

### Step 1: Basic Information

- **Name**: A unique name for your CronJob (e.g., `daily-report-generator`).
- **Description**: An optional description of what the job does.

### Step 2: Job Container

This section defines the container that will execute your job's logic.

- **Container Image**: The Docker image to run (e.g., `my-registry/my-reporting-tool:latest`).
- **Command & Arguments**: Optionally override the container's default `CMD` or `ENTRYPOINT`. You can specify a command and its arguments.
  - _Example Command_: `python`
  - _Example Arguments_: `-c "import app; app.run_daily_report()"`
- **Image Pull Policy**: Set to `Always` to ensure you are running the latest image, or `IfNotPresent` for testing.

### Step 3: Schedule

Define when the job should run using a standard cron schedule string.

- **Schedule**: Enter a cron expression. The UI provides helpful presets and a text explainer.
  - _Example for "every day at 3:00 AM"_: `0 3 * * *`
  - _Example for "every 15 minutes"_: `*/15 * * * *`
- **Timezone**: Select the timezone in which the schedule should be interpreted.

### Step 4: Advanced Settings

- **Restart Policy**: What to do if the job's pod fails.
  - `OnFailure`: (Default) Restart the pod if it exits with an error.
  - `Never`: Do not restart the pod.
- **Concurrency Policy**: How to handle overlapping job runs.
  - `Allow`: (Default) Allow multiple instances of the job to run concurrently.
  - `Forbid`: Skip the new job run if the previous one is still running.
  - `Replace`: Cancel the currently running job and start the new one.
- **Active Deadline**: A timeout for the job. If it runs longer than this, the system will terminate it. (e.g., `30m`, `1h`).
- **History Limits**:
  - **Successful Jobs History Limit**: How many completed job pods to keep.
  - **Failed Jobs History Limit**: How many failed job pods to keep. This is useful for debugging.

### Step 5: Resources & Environment

- **Resource Requests & Limits**: Specify the CPU and Memory resources for the job's container, just like a regular deployment.
- **Environment Variables**: Add environment variables, either as key-value pairs or by importing them from `ConfigMaps` and `Secrets`. This is the secure way to pass database credentials or API keys to your job.

After reviewing all the settings, click **Create**. The CronJob will be created and will trigger its first run at the next scheduled time.

## Monitoring CronJobs in the UI

The CronJobs section of the UI provides a comprehensive overview of your scheduled tasks.

- **CronJob List**: Shows all configured CronJobs, their schedules, and the status of their last run (`Success`, `Failed`, `Running`).
- **Job History**: Click on a CronJob to see a detailed history of all its past runs (jobs).
- **Viewing Logs**: For any specific job run, you can view its complete logs with a single click. This is essential for debugging failed jobs.
- **Manual Trigger**: You can manually trigger a new run of a CronJob at any time, which is useful for testing.
