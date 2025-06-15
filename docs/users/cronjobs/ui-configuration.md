# CronJob UI Configuration

The Hexabase.AI platform provides an intuitive web interface for managing CronJobs without requiring direct YAML manipulation. This guide covers all aspects of configuring CronJobs through the UI.

## Accessing the CronJob Interface

### Navigation

1. Log in to the Hexabase.AI console
2. Select your workspace
3. Navigate to **Workloads** → **CronJobs**

## Creating a New CronJob

### Basic Configuration

#### 1. Job Identity

- **Name**: Unique identifier for your CronJob
- **Namespace**: Target namespace for execution
- **Labels**: Key-value pairs for organization
- **Annotations**: Metadata for integrations

#### 2. Schedule Configuration

The UI provides multiple ways to define schedules:

**Visual Schedule Builder**

- Select frequency: Minutely, Hourly, Daily, Weekly, Monthly
- Choose specific times/days through dropdowns
- Preview the generated cron expression

**Cron Expression Editor**

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6)
│ │ │ │ │
* * * * *
```

**Common Schedules Quick Select**

- Every hour: `0 * * * *`
- Daily at midnight: `0 0 * * *`
- Weekly on Sunday: `0 0 * * 0`
- Monthly on the 1st: `0 0 1 * *`

### Job Template Configuration

#### Container Settings

1. **Image Selection**

   - Repository browser
   - Tag selection with version history
   - Private registry support

2. **Command and Arguments**

   ```
   Command: ["/bin/sh"]
   Args: ["-c", "echo 'Job executed at $(date)'"]
   ```

3. **Environment Variables**
   - Key-value editor
   - Secret/ConfigMap references
   - Import from existing deployments

#### Resource Management

**Plan-based Limits:**

| Plan       | CPU Request  | Memory Request | CPU Limit | Memory Limit |
| ---------- | ------------ | -------------- | --------- | ------------ |
| Single     | 100m         | 128Mi          | 500m      | 512Mi        |
| Team       | 250m         | 256Mi          | 1 CPU     | 1Gi          |
| Enterprise | Configurable | Configurable   | Custom    | Custom       |

**UI Resource Sliders:**

- Visual representation of resource allocation
- Real-time cost impact display
- Recommendations based on job history

### Advanced Configuration

#### Concurrency Policy

- **Allow** (default): Run jobs concurrently
- **Forbid**: Skip if previous still running
- **Replace**: Cancel previous and start new

#### Job History Limits

- Successful job history: 1-10 (default: 3)
- Failed job history: 1-10 (default: 1)

#### Deadline and Timeout

- Starting deadline seconds
- Active deadline seconds
- Backoff limit for retries

## Managing Existing CronJobs

### List View Features

- Status indicators (Active/Suspended)
- Last schedule time
- Next scheduled run
- Quick actions menu

### Filtering and Search

- By name, namespace, labels
- By schedule frequency
- By job status
- By resource usage

### Bulk Operations

- Suspend/Resume multiple jobs
- Delete with confirmation
- Export configurations

## Job Execution Monitoring

### Execution History View

```
┌─────────────────────────────────────────────┐
│ Job Name: backup-database                   │
│ Schedule: 0 2 * * *                         │
├─────────────────────────────────────────────┤
│ Execution │ Start Time  │ Duration │ Status │
├───────────┼─────────────┼──────────┼────────┤
│ #125      │ 2:00:03 AM  │ 5m 23s   │ ✓      │
│ #124      │ 2:00:01 AM  │ 5m 19s   │ ✓      │
│ #123      │ 2:00:05 AM  │ --       │ ✗      │
└─────────────────────────────────────────────┘
```

### Live Job Monitoring

- Real-time log streaming
- Resource usage graphs
- Pod status tracking
- Event timeline

## UI Workflows

### Quick Create Wizard

1. **Template Selection**

   - Database backup
   - Report generation
   - Data synchronization
   - Cleanup tasks

2. **Customization**

   - Modify template parameters
   - Adjust schedule
   - Set notifications

3. **Review and Deploy**
   - Configuration summary
   - Validation warnings
   - Cost estimation

### Import/Export Features

**Import Options:**

- Upload YAML files
- Import from Git repository
- Copy from existing CronJob

**Export Formats:**

- YAML configuration
- Helm chart values
- Terraform resources

## Notifications and Alerts

### Email Notifications

Configure alerts for:

- Job failures
- Execution delays
- Success confirmations
- Resource limit warnings

### Webhook Integration

```json
{
  "webhook_url": "https://hooks.slack.com/services/...",
  "events": ["failure", "success"],
  "include_logs": true
}
```

## Best Practices for UI Configuration

### 1. Use Descriptive Names

```
Good: daily-user-report-generator
Bad: cronjob-1
```

### 2. Label Consistently

```yaml
app: reporting
environment: production
schedule: daily
owner: data-team
```

### 3. Set Appropriate Timeouts

- Short jobs: 300 seconds
- Medium jobs: 1800 seconds
- Long-running jobs: 3600+ seconds

### 4. Configure History Limits

- Keep more failed job history for debugging
- Limit successful job history to save resources

### 5. Test Schedules

Use the "Run Now" button to test jobs before scheduling

## Troubleshooting UI Issues

### Common Problems

1. **Schedule Not Triggering**

   - Verify timezone settings
   - Check cron expression syntax
   - Ensure CronJob is not suspended

2. **Resource Allocation Errors**

   - Review namespace quotas
   - Check node availability
   - Verify plan limits

3. **Image Pull Failures**
   - Confirm registry credentials
   - Verify image exists
   - Check network policies

### UI Performance Tips

- Use pagination for large job lists
- Apply filters to reduce data load
- Export configurations for bulk editing

## Integration with Other Features

### CI/CD Pipeline Triggers

Create CronJobs that trigger pipeline runs:

```yaml
Container Command:
  - curl
  - -X
  - POST
  - https://api.hexabase.ai/pipelines/trigger
```

### Function Invocation

Schedule serverless function execution:

```yaml
Container Command:
  - hxb
  - function
  - invoke
  - --name=process-daily-data
```

### Backup Integration

Coordinate with Hexabase.AI backup system:

```yaml
Container Command:
  - hxb
  - backup
  - create
  - --type=incremental
```

## Related Documentation

- [CronJob Examples](examples.md)
- [Integration Patterns](integration-patterns.md)
- [Monitoring CronJobs](../observability/dashboards-alerts.md)
- [RBAC for CronJobs](../rbac/permission-model.md)
