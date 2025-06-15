# Automated Backups

Automating your backup process is a cornerstone of a reliable data protection strategy. Hexabase.AI allows you to define sophisticated, schedule-based backup plans that run automatically without manual intervention.

## How Automation Works

Backup automation is driven by **Backup Plans**, which are Kubernetes custom resources that specify:

- **What** to back up (the backup target).
- **Where** to store the backups (the storage location).
- **When** to run the backup (the cron schedule).
- **How long** to keep the backups (the retention policy).

Once a `BackupPlan` is created, the HKS AIOps controller continuously monitors it and triggers backup jobs according to the defined schedule.

## Creating a Scheduled Backup Plan

This example creates a plan that backs up all resources in the `production` namespace every night at 2:00 AM.

### Step 1: Define the Backup Target

First, ensure you have resources to back up. In this case, we're targeting an entire namespace.

### Step 2: Define the Storage Location

You must have a `BackupStorageLocation` configured. See the [Backup Strategies](./strategies.md) guide for details. We'll assume a location named `s3-primary` exists.

### Step 3: Create the Backup Plan

```yaml
# automated-backup-plan.yaml
apiVersion: hks.io/v1
kind: BackupPlan
metadata:
  name: production-daily-backup
  namespace: hks-system
spec:
  # Define what to back up
  target:
    includeNamespaces:
      - production
    # Optional: You can also include cluster-scoped resources
    includeClusterResources: true

  # Define where to store the backup
  storageLocation: s3-primary

  # Define the schedule
  schedule:
    # Runs at 2:00 AM UTC every day
    cron: "0 2 * * *"

  # Define the retention policy
  retention:
    # Keep the last 7 daily backups
    daily: 7
    # Keep the last 4 weekly backups (taken on Sunday)
    weekly: 4
    # Keep the last 12 monthly backups (taken on the 1st of the month)
    monthly: 12
    # Prune (delete) backups older than the retention policy
    prune: true
```

Apply the plan to the cluster:

```bash
hks apply -f automated-backup-plan.yaml
```

## Managing Retention Policies (Grandfather-Father-Son)

The retention policy in the example above implements a common Grandfather-Father-Son (GFS) rotation scheme.

- **Daily (Son)**: The most frequent backups, providing a short-term recovery window.
- **Weekly (Father)**: Less frequent, for medium-term recovery. HKS automatically promotes the last successful daily backup of the week (e.g., on Sunday) to be the weekly backup.
- **Monthly (Grandfather)**: The least frequent, for long-term archival. The last successful weekly backup of the month is promoted to a monthly backup.

This strategy provides a good balance between recovery point objectives (RPO) and storage costs.

## Disabling and Enabling a Backup Plan

You can temporarily pause a backup plan without deleting it.

```yaml
# To disable (pause) a plan
hks backup-plan pause production-daily-backup

# The plan's status will show 'Paused'
# To re-enable it
hks backup-plan resume production-daily-backup
```

This is useful during maintenance windows or when you need to prevent backups from running for a specific period.

## Monitoring Automated Backups

You can monitor the status and history of your automated backups through the HKS UI or CLI.

### From the CLI

```bash
# List all backups created by the plan
hks get backups --selector hks.io/backup-plan=production-daily-backup

# Describe the backup plan to see its status and last run time
hks describe backup-plan production-daily-backup

# View logs for a specific backup job
hks backup logs <backup-name>
```

### From the UI

The Hexabase.AI dashboard provides a visual overview of:

- All configured backup plans.
- The history of backup runs for each plan (success, failure, duration).
- The status of available backups ready for restore.
- Storage consumption per plan.

## Automated Alerts

Hexabase.AI AIOps can automatically notify you about the status of your backups.

### Configure Alerts for Backup Failures

```yaml
apiVersion: hks.io/v1
kind: AlertPolicy
metadata:
  name: backup-failure-alert
spec:
  metric: hks_backup_job_status
  condition: "value == 'Failed'"
  duration: 1m # Alert if failed for 1 minute
  severity: critical
  notification:
    slack:
      channel: "#ops-alerts"
    email:
      to: "sre-team@example.com"
```

This policy will send a critical alert to Slack and email if any backup job fails, enabling your team to investigate immediately.

## Best Practices for Automated Backups

1.  **Stagger Your Schedules**: If you have multiple backup plans, stagger their start times to avoid creating a "thundering herd" problem where many jobs start simultaneously, potentially straining cluster and storage resources.
2.  **Use Meaningful Names**: Name your backup plans descriptively (e.g., `prod-db-hourly`, `dev-apps-daily`) so their purpose is clear.
3.  **Monitor Storage Consumption**: Keep an eye on the storage used by your backups. Adjust retention policies as needed to balance recovery needs with cost.
4.  **Exclude Temporary Data**: Use resource labels and selectors (`--exclude-resources`) in your backup targets to avoid backing up non-critical or transient data like cache pods.
5.  **Review Policies Regularly**: As your applications evolve, review your backup plans to ensure they still meet your RPO and RTO requirements.
