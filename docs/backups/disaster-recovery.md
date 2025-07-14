# Disaster Recovery (DR)

Disaster Recovery (DR) is the process of preparing for and recovering from a disaster that affects your applications and data. Hexabase.AI provides a suite of tools and features to help you implement a robust DR strategy, ensuring business continuity even in the face of major outages.

## DR Overview in Hexabase.AI

A comprehensive DR strategy involves more than just data backups. In Hexabase.AI, it encompasses:

- **Data Replication**: Replicating data to a secondary, geographically distinct location.
- **Infrastructure Replication**: The ability to quickly spin up infrastructure in a recovery site.
- **Failover Mechanism**: A process to switch traffic from the primary site to the recovery site.
- **Failback Mechanism**: A process to return traffic to the primary site once it has been restored.

## Key DR Scenarios

### 1. Regional Outage

- **Scenario**: An entire cloud region (e.g., `us-east-1`) becomes unavailable.
- **HKS Solution**: Cross-region replication of backups and infrastructure-as-code.

### 2. Data Corruption

- **Scenario**: A bug or human error corrupts your production database.
- **HKS Solution**: Restore from a point-in-time backup taken before the corruption occurred.

### 3. Application Failure

- **Scenario**: A critical application deployment fails and cannot be rolled back.
- **HKS Solution**: Restore the application's configuration and data from a recent, known-good namespace backup.

## Setting up a DR Environment

Here's a high-level overview of setting up a basic DR plan in Hexabase.AI.

### Step 1: Configure a Remote Storage Location

Your primary and DR sites should not share storage. Configure a `BackupStorageLocation` in a different region or even a different cloud provider.

```yaml
# dr-storage-location.yaml
apiVersion: hks.io/v1
kind: BackupStorageLocation
metadata:
  name: s3-dr-storage
spec:
  provider: aws
  objectStorage:
    bucket: my-hexabase-backups-dr-site
    region: us-west-2 # A different region from the primary
```

### Step 2: Create a Replication Plan

Replicate backups from your primary storage location to your DR storage location.

```yaml
apiVersion: hks.io/v1
kind: ReplicationPlan
metadata:
  name: replicate-prod-backups
spec:
  source:
    storageLocation: s3-primary
  destination:
    storageLocation: s3-dr-storage
  # Replicate every hour
  schedule:
    cron: "0 * * * *"
```

The AIOps controller will automatically copy new backups from `s3-primary` to `s3-dr-storage` on schedule.

### Step 3: Prepare the Recovery Site

The recovery site can be a "cold," "warm," or "hot" standby.

- **Cold Site**: Infrastructure is provisioned only when a disaster is declared. Lowest cost, highest Recovery Time Objective (RTO).
- **Warm Site**: Minimal infrastructure is running (e.g., the HKS control plane, a small node pool). Lower RTO.
- **Hot Site**: A fully scaled-out replica of the production site is running. Near-zero RTO, highest cost.

For most use cases, a **warm site** is a good compromise. You can use HKS automation to provision the full infrastructure during a DR event.

## The Disaster Recovery Process

### Declaring a Disaster

When a disaster is confirmed, the first step is to officially declare it. This initiates the failover process.

```bash
# Pause replication to prevent corrupted data from being copied
hb replication-plan pause replicate-prod-backups

# (External Step) Update DNS, notify stakeholders, etc.
```

### Initiating Failover

The goal is to bring up the application in the recovery site using the latest replicated backups.

```bash
# In the DR site cluster:

# 1. Restore the entire namespace from the replicated backup
hb restore create restore-production \
  --from-backup <latest-replicated-backup-name> \
  --from-storage-location s3-dr-storage

# 2. HKS restores all deployments, services, PVCs, and data.
#    The AIOps restore controller handles the entire workflow.

# 3. Verify application health in the DR site
hb get pods -n production
hb check-health -n production

# 4. (External Step) Switch public DNS to point to the DR site's load balancer.
```

## Failback Process

Once the primary site is operational again, you need to fail back.

### Step 1: Resynchronize Data

Data may have changed in the DR site while it was active. You need to replicate this data back to the primary site.

```bash
# In the DR cluster:
# 1. Back up the active DR namespace
hb backup create dr-site-data --include-namespaces production --storage-location s3-dr-storage

# In the Primary cluster:
# 2. Ensure the primary site is clean and ready
# 3. Restore from the backup of the DR site's data
hb restore create restore-from-dr --from-backup dr-site-data
```

### Step 2: Switch Traffic Back

1.  Perform health checks on the restored primary site.
2.  Place the DR site application in maintenance mode.
3.  (External Step) Switch DNS back to the primary site's load balancer.
4.  Once traffic is flowing to the primary site, you can de-provision the DR application.
5.  Re-enable your backup and replication plans.

```bash
hb replication-plan resume replicate-prod-backups
```

## Automated DR Testing

Manually testing DR is error-prone. Hexabase.AI allows you to automate DR tests.

```yaml
apiVersion: hks.io/v1
kind: DRTestPlan
metadata:
  name: quarterly-dr-drill
spec:
  schedule:
    # Run on the first Sunday of each quarter at 4 AM
    cron: "0 4 1 1,4,7,10 0"

  # The backup to test with
  sourceBackup:
    plan: production-daily-backup
    select: latest-weekly

  # The isolated environment to restore into
  testEnvironment:
    namespace: dr-test-zone
    networkPolicy: isolate-all

  # Tests to run against the restored environment
  validation:
    - type: httpGet
      target: /health
      service: frontend
    - type: customScript
      script: /scripts/verify-data.sh
      image: my-test-tools:latest

  onSuccess:
    notify:
      slack: { channel: "#dr-tests-success" }
  onFailure:
    notify:
      slack: { channel: "#dr-tests-failure", mention: "@oncall" }
```

This plan will automatically perform a test restore into an isolated namespace, run validation checks, and report the results, giving you confidence in your DR strategy without impacting production.

## Best Practices

- **Automate Everything**: Use HKS plans (`BackupPlan`, `ReplicationPlan`, `DRTestPlan`) to automate as much of the DR process as possible.
- **Keep It Simple**: The more complex your DR plan, the more likely it is to fail. Start with a simple, reliable plan and build on it.
- **Document the Plan**: Have a clear, written runbook that details the DR procedure, including manual steps (like DNS changes) and contact information for key personnel.
- **Test Regularly**: The only way to trust your DR plan is to test it. Use automated DR testing to do this frequently.
