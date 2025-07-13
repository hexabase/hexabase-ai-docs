# CronJobs

Master the deployment and management of scheduled tasks in Hexabase.AI using Kubernetes CronJobs.

## Overview

CronJobs in Hexabase.AI provide a reliable way to run scheduled tasks in your Kubernetes environments. Whether you need to run periodic backups, data processing jobs, or maintenance tasks, our platform simplifies CronJob creation and management while adding enterprise features like monitoring, alerting, and job history tracking.

## CronJob Documentation

<div class="grid cards" markdown>

- :material-clock-start:{ .lg .middle } **Getting Started**

  ***

  Learn the basics of creating and deploying CronJobs

  [:octicons-arrow-right-24: CronJob Basics](management.md)

- :material-calendar-clock:{ .lg .middle } **Scheduling Patterns**

  ***

  Master cron expressions and scheduling strategies

  [:octicons-arrow-right-24: Scheduling Guide](management.md)

- :material-cog-sync:{ .lg .middle } **Advanced Configuration**

  ***

  Configure job policies, resources, and dependencies

  [:octicons-arrow-right-24: Advanced Config](management.md)

- :material-monitor-dashboard:{ .lg .middle } **Monitoring & Debugging**

  ***

  Track job execution and troubleshoot failures

  [:octicons-arrow-right-24: Monitoring Guide](../observability/monitoring-setup.md)

</div>

## Key Features

### 1. Enhanced Scheduling

- **Visual Cron Builder**: Create cron expressions with our intuitive UI
- **Timezone Support**: Schedule jobs in any timezone
- **Schedule Validation**: Prevent invalid cron expressions
- **Next Run Preview**: See when your job will run next

### 2. Job Management

- **Job History**: Track all executions with logs and metrics
- **Manual Triggering**: Run jobs on-demand for testing
- **Pause/Resume**: Temporarily disable jobs without deletion
- **Batch Operations**: Manage multiple CronJobs at once

### 3. Enterprise Features

- **Failure Notifications**: Get alerted when jobs fail
- **Success Tracking**: Monitor job completion rates
- **Resource Limits**: Prevent runaway jobs
- **Dependency Management**: Chain jobs together

### 4. Integration Capabilities

- **Secret Management**: Securely inject credentials
- **ConfigMap Support**: Dynamic configuration
- **Volume Mounts**: Access persistent data
- **Service Connections**: Interact with other services

## Common Use Cases

### Data Processing

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-etl
spec:
  schedule: "0 2 * * *" # 2 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: etl-processor
              image: myapp/etl:latest
              command: ["python", "etl.py"]
```

### Backup Operations

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
spec:
  schedule: "0 */6 * * *" # Every 6 hours
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: postgres:14
              command: ["pg_dump"]
              env:
                - name: PGPASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: db-secret
                      key: password
```

### Maintenance Tasks

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-old-data
spec:
  schedule: "30 3 * * 0" # 3:30 AM every Sunday
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: cleanup
              image: myapp/maintenance:latest
              command: ["./cleanup.sh"]
```

## CronJob Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Created   │────▶│  Scheduled  │────▶│   Running   │
└─────────────┘     └─────────────┘     └─────────────┘
                           │                     │
                           ▼                     ▼
                    ┌─────────────┐     ┌─────────────┐
                    │   Paused    │     │  Completed  │
                    └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │   History   │
                                        └─────────────┘
```

## Best Practices

### 1. Idempotent Jobs

Design jobs that can be safely re-run without side effects

### 2. Appropriate Timeouts

Set realistic deadlines to prevent hanging jobs

### 3. Resource Limits

Define CPU and memory limits to protect cluster stability

### 4. Error Handling

Implement proper error handling and retry logic

### 5. Monitoring

Set up alerts for job failures and performance issues

## Quick Examples

### Simple Hourly Job

```bash
hb cronjob create hourly-report \
  --schedule "0 * * * *" \
  --image myapp/reporter:latest \
  --command "python report.py"
```

### Job with Environment Variables

```bash
hb cronjob create data-sync \
  --schedule "*/15 * * * *" \
  --image myapp/sync:latest \
  --env DATABASE_URL=postgresql://... \
  --env API_KEY_FROM_SECRET=api-secret:key
```

### View Job History

```bash
hb cronjob history daily-backup --last 10
```

## Troubleshooting Guide

### Common Issues

1. **Job Not Running**

   - Check cron schedule syntax
   - Verify timezone settings
   - Ensure job is not paused

2. **Job Failing**

   - Review job logs
   - Check resource limits
   - Verify image availability

3. **Performance Issues**
   - Monitor resource usage
   - Check for concurrent job limits
   - Review job duration trends

## Next Steps

- **New to CronJobs?** Start with [Getting Started](management.md)
- **Need scheduling help?** Check [Scheduling Patterns](management.md)
- **Advanced usage?** Explore [Configuration Options](management.md)
- **Having issues?** See [Monitoring & Debugging](../observability/monitoring-setup.md)

## Related Documentation

- [Kubernetes Jobs Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [Functions](../functions/index.md) for event-driven tasks
- [Observability](../observability/index.md) for monitoring
- [API Reference](https://api.hexabase.ai/docs) for programmatic access
