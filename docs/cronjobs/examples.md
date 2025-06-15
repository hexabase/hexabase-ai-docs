# CronJob Examples

This page provides a collection of practical, copy-paste-ready examples for common CronJob use cases in Hexabase.AI.

## Example 1: Basic "Hello World"

This is the simplest possible CronJob, which runs every minute and prints the current date. It's useful for verifying that the CronJob scheduler is working correctly.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-world
spec:
  # Run every minute
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: hello
              image: busybox:1.28
              args:
                - /bin/sh
                - -c
                - date; echo "Hello, World!"
          restartPolicy: OnFailure
```

## Example 2: Database Backup

This example runs `pg_dump` to back up a PostgreSQL database and uploads the dump to an S3-compatible object store using the `mc` (MinIO Client) tool.

- **Prerequisites**:
  - A `Secret` named `db-backup-secrets` containing the database password (`DB_PASSWORD`) and S3 access keys (`S3_ACCESS_KEY`, `S3_SECRET_KEY`).
- **Container Image**: A custom image that contains both the `psql` and `mc` command-line tools.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-db-backup
spec:
  # Run daily at 1:00 AM
  schedule: "0 1 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: db-backup
              image: my-registry/backup-tools:latest
              command: ["/bin/sh", "-c"]
              args:
                - |
                  set -e
                  echo "Starting database backup..."
                  export PGPASSWORD=$DB_PASSWORD
                  pg_dump -h db.my-app.svc -U admin my_database > /tmp/backup.sql

                  echo "Uploading backup to S3..."
                  mc alias set s3 https://s3.example.com $S3_ACCESS_KEY $S3_SECRET_KEY
                  mc cp /tmp/backup.sql s3/my-backups/db-$(date +%Y-%m-%d).sql

                  echo "Backup complete."
              env:
                - name: DB_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: db-backup-secrets
                      key: DB_PASSWORD
                - name: S3_ACCESS_KEY
                  valueFrom:
                    secretKeyRef:
                      name: db-backup-secrets
                      key: S3_ACCESS_KEY
                - name: S3_SECRET_KEY
                  valueFrom:
                    secretKeyRef:
                      name: db-backup-secrets
                      key: S3_SECRET_KEY
          restartPolicy: OnFailure
```

## Example 3: Application Health Check

This CronJob runs a simple `curl` command to periodically check the health endpoint of a web service and reports a failure if it doesn't get a `200 OK` response.

- **Use Case**: A simple, external health check for a critical service.
- **Note**: HKS has built-in, more sophisticated health checking, but this is a good example of a simple monitoring task.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: check-app-health
spec:
  # Run every 5 minutes
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: health-checker
              image: curlimages/curl:latest
              # The `-f` flag causes curl to exit with an error (non-zero)
              # if the HTTP status code is not in the 2xx range.
              # The CronJob will be marked as 'Failed' if the check fails.
              args: ["-f", "http://my-web-app.production.svc/health"]
          restartPolicy: OnFailure
```

## Example 4: Data Cleanup

This job runs weekly to clean up old, temporary files from a shared storage volume.

- **Prerequisites**: A `PersistentVolumeClaim` named `shared-temp-storage` that is also mounted by your application.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: weekly-data-cleanup
spec:
  # Run every Sunday at 4:00 AM
  schedule: "0 4 * * 0"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: cleaner
              image: busybox:1.28
              command: ["/bin/sh", "-c"]
              # Deletes files older than 7 days from the /data directory
              args:
                - "find /data -type f -mtime +7 -delete"
              volumeMounts:
                - name: temp-data
                  mountPath: /data
          volumes:
            - name: temp-data
              persistentVolumeClaim:
                claimName: shared-temp-storage
          restartPolicy: OnFailure
```

These examples can be adapted to a wide variety of scheduled tasks. The key is to find or build a container image with the necessary tools and then orchestrate its execution with a `CronJob` resource.
