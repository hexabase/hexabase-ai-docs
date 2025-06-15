# Backup Strategies

A robust backup strategy is essential for data protection and business continuity. Hexabase.AI provides a flexible and powerful framework for creating and managing backups for your applications, data, and configurations.

## Overview

Backup strategies in Hexabase.AI are designed to be:

- **Comprehensive**: Back up everything from persistent volumes to entire namespace configurations.
- **Automated**: Schedule backups to run automatically at your desired frequency.
- **Reliable**: Store backups in secure, durable, and geo-redundant storage.
- **Easy to Manage**: Configure, monitor, and restore backups through a unified UI and CLI.

## Key Concepts

- **Backup Target**: The specific resource to be backed up (e.g., a Persistent Volume Claim, a namespace, a set of resources with a specific label).
- **Backup Plan**: A policy that defines what to back up, where to store it, and the schedule and retention policy.
- **Storage Location**: The destination for your backup data (e.g., S3-compatible object storage, NFS share).
- **Snapshot**: A point-in-time copy of a volume, typically using underlying storage provider capabilities.

## Types of Backups

### 1. Volume Snapshots

- **What it is**: A point-in-time snapshot of a Persistent Volume (PV). This is the most common method for backing up stateful application data.
- **Best for**: Databases (PostgreSQL, MySQL), message queues, and any application that writes to a persistent disk.
- **How it works**: Uses the storage provider's snapshot capabilities (e.g., EBS snapshots in AWS, GCE PD snapshots in Google Cloud) for efficiency.

```yaml
# Example Volume Snapshot
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: postgres-db-snapshot
spec:
  volumeSnapshotClassName: csi-aws-vsc
  source:
    persistentVolumeClaimName: postgres-data
```

### 2. Namespace Backups

- **What it is**: A complete backup of all Kubernetes resources within a specific namespace. This includes Deployments, Services, ConfigMaps, Secrets, etc.
- **Best for**: Capturing the entire state of an application or environment for disaster recovery or migration.
- **How it works**: It iterates through all resources in the namespace and saves their YAML definitions. It can optionally include volume snapshots for any PVCs in the namespace.

```yaml
# HKS CLI command for namespace backup
hks backup create my-namespace-backup --include-namespaces production
```

### 3. Resource-Filtered Backups

- **What it is**: A backup of specific Kubernetes resources selected by labels.
- **Best for**: Backing up components of a larger application that are spread across your cluster, or backing up only critical components.

```bash
# Back up all resources with the label "app=mission-critical"
hks backup create critical-app-backup --selector app=mission-critical
```

## Backup Storage Locations

Hexabase.AI supports various storage backends for your backups.

### S3-Compatible Object Storage

- **Description**: Use any S3-compatible service like AWS S3, MinIO, or Google Cloud Storage.
- **Configuration**:
  ```yaml
  apiVersion: hks.io/v1
  kind: BackupStorageLocation
  metadata:
    name: s3-main-storage
  spec:
    provider: aws
    objectStorage:
      bucket: my-hexabase-backups
      region: us-east-1
  ```

### NFS Storage

- **Description**: Use an existing Network File System (NFS) share.
- **Configuration**:
  ```yaml
  apiVersion: hks.io/v1
  kind: BackupStorageLocation
  metadata:
    name: nfs-onprem-storage
  spec:
    provider: generic
    nfs:
      server: 192.168.1.100
      path: /exports/backups
  ```

## Defining a Backup Plan

A Backup Plan ties everything together: what, where, when, and for how long.

```yaml
apiVersion: hks.io/v1
kind: BackupPlan
metadata:
  name: production-db-daily
spec:
  target:
    # Target what to back up
    namespace: production
    selector:
      app: postgres-db

  storageLocation: s3-main-storage

  schedule:
    # When to back up
    cron: "0 2 * * *" # Daily at 2 AM UTC

  retention:
    # How long to keep backups
    daily: 7
    weekly: 4
    monthly: 6
```

## Pre- and Post-Backup Hooks

For application-consistent backups, you can execute commands inside your application's containers before and after a snapshot.

- **Pre-backup hook**: Quiesce the database or flush caches to disk.
- **Post-backup hook**: Unquiesce the database or resume operations.

```yaml
# Annotate your pod for backup hooks
apiVersion: v1
kind: Pod
metadata:
  name: postgres-pod
  annotations:
    # Pre-backup hook: freeze the database
    pre.hook.backup.hks.io/container: postgres
    pre.hook.backup.hks.io/command: '["/bin/psql", "-c", "CHECKPOINT; SELECT pg_start_backup(\'hks-backup\');"]'

    # Post-backup hook: unfreeze the database
    post.hook.backup.hks.io/container: postgres
    post.hook.backup.hks.io/command: '["/bin/psql", "-c", "SELECT pg_stop_backup();"]'
```

## Best Practices for Backup Strategies

1.  **3-2-1 Rule**:

    - Keep **3** copies of your data (1 production, 2 backups).
    - Store backups on **2** different media.
    - Keep **1** backup copy off-site. Use a different region or cloud provider for one of your `BackupStorageLocation`s.

2.  **Regularly Test Your Restores**: A backup strategy is useless if you can't restore from it. Regularly perform test restores to a non-production environment.

3.  **Use Application Hooks**: For transactional applications like databases, always use pre- and post-backup hooks to ensure application consistency.

4.  **Tag Your Backups**: Use labels and annotations to organize your backups, making them easier to find during a restore operation.

5.  **Separate Data and Configuration Backups**: Consider having separate backup plans for your stateful data (volumes) and your stateless application configurations (namespaces/resources). This can provide more flexibility during restores.

6.  **Secure Your Backups**: Encrypt backup data both in-transit and at-rest. Use IAM roles or dedicated credentials with minimal permissions for your `BackupStorageLocation`.
