# Restore Procedures

Having backups is only half the battle; knowing how to restore them is critical. Hexabase.AI simplifies the restore process, allowing you to recover data, applications, or entire namespaces quickly and reliably.

## Creating a Restore Job

Restores are initiated by creating a `Restore` custom resource. This can be done via the HKS UI or by applying a YAML manifest with the CLI.

### Find the Backup to Restore

First, you need to identify the backup you want to restore from.

```bash
# List all available backups
hb get backups

# List backups from a specific plan
hb get backups --selector hks.io/backup-plan=production-daily-backup

# Get details of a specific backup
hb describe backup <backup-name>
```

### Initiating a Restore via CLI

The `hb restore create` command is the primary way to start a restore.

```bash
hb restore create <restore-name> --from-backup <backup-name> [options]
```

## Restore Scenarios

### 1. Restore a Full Namespace

This is the most common scenario for recovering from a major application failure or for migrating an environment.

```bash
# Restore the 'production' namespace from a backup
hb restore create restore-prod-ns \
  --from-backup production-daily-backup-20250615020000
```

By default, this restores all resources and associated volume data into the original `production` namespace.

**Important**: The restore process will overwrite existing resources in the target namespace.

### 2. Restore to a Different Namespace

This is the recommended approach for testing restores or recovering specific data without impacting the live production environment.

```bash
hb restore create test-restore-prod \
  --from-backup production-daily-backup-20250615020000 \
  --namespace-mapping production:production-restored
```

This command restores the contents of the `production` namespace from the backup into a new namespace called `production-restored`.

### 3. Restore a Single Persistent Volume Claim (PVC)

If only a single volume's data was lost or corrupted, you can restore just that PVC.

```bash
hb restore create restore-db-volume \
  --from-backup <backup-name> \
  --include-resources persistentvolumeclaims \
  --selector app=postgres-db
```

This will create a new PVC and a new PV with the data from the backup. You will then need to manually update your application to use this new PVC.

### 4. Restore Specific Resource Types

You can choose to restore only specific types of resources from a backup.

```bash
# Restore only Deployments and ConfigMaps from a backup
hb restore create restore-deploy-cfgs \
  --from-backup <backup-name> \
  --include-resources deployments,configmaps
```

## Advanced Restore Options

### Modifying Resources on Restore

You can apply transformations to resources as they are being restored. This is useful for changing storage classes, node selectors, or other parameters.

```yaml
# restore-with-patch.yaml
apiVersion: hks.io/v1
kind: Restore
metadata:
  name: restore-and-modify
spec:
  backupName: <backup-name>
  # Apply a strategic merge patch to all restored deployments
  patches:
    - target:
        group: apps
        version: v1
        kind: Deployment
      patch: |
        spec:
          template:
            spec:
              nodeSelector:
                "disktype": "ssd"
```

### Restoring with Hooks

Similar to backup hooks, you can define hooks that run before and after a restore operation.

- **Pre-restore hook**: Scale down an existing deployment before it's overwritten.
- **Post-restore hook**: Run a database migration script after the data has been restored.

```yaml
# restore-with-hooks.yaml
apiVersion: hks.io/v1
kind: Restore
metadata:
  name: restore-with-hooks
spec:
  backupName: <backup-name>
  hooks:
    preHooks:
      - exec:
          container: myapp
          command: ["/scripts/pre-restore.sh"]
          onError: Fail
    postHooks:
      - exec:
          container: myapp
          command: ["/scripts/post-restore.sh"]
          timeout: 10m
```

## Monitoring a Restore

You can monitor the progress of a restore job from the CLI or UI.

```bash
# Get the status of a restore
hb get restore restore-prod-ns

# Describe the restore for detailed information and events
hb describe restore restore-prod-ns

# View the logs of the restore job
hb restore logs restore-prod-ns
```

The restore status will cycle through phases like `New`, `InProgress`, `Completed`, or `Failed`.

## Troubleshooting Failed Restores

1.  **Check the Logs**: The first step is always `hb restore logs <restore-name>`. The logs will usually contain the specific error message.
2.  **Examine Events**: `hb describe restore <restore-name>` will show Kubernetes events related to the restore process, which can highlight issues like insufficient permissions or storage provisioning failures.
3.  **Permissions**: Ensure the HKS service account has the necessary permissions to create resources in the target namespace.
4.  **Storage Provisioning**: If a PV restore fails, check the status of the underlying storage provisioner and ensure there is enough capacity.
5.  **Resource Conflicts**: If you are not restoring to a clean namespace, there might be conflicts with existing resources. The logs will indicate if a resource `already exists`.

## Best Practices for Restores

1.  **Restore to a New Namespace**: Always perform test restores (and even production restores, if possible) into a new, isolated namespace. This prevents any impact on your live environment and allows you to validate the restored application before directing traffic to it.
2.  **Validate After Restore**: Don't assume a `Completed` status means the application is working. Always run a suite of tests against the restored environment to ensure application functionality and data integrity.
3.  **Have a Plan**: Document your restore procedures in a runbook. Know which backups you will use for different scenarios (e.g., full DR vs. single volume recovery).
4.  **Practice**: Regularly perform restore drills so your team is comfortable and efficient with the process when a real disaster strikes.
