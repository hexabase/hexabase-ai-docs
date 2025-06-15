# CronJob Examples

This guide provides practical examples of CronJobs for common use cases in Hexabase.AI. Each example includes the complete YAML configuration and explains the key components.

## Database Backup Jobs

### Daily PostgreSQL Backup

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup-daily
  namespace: production
spec:
  schedule: "0 2 * * *" # 2 AM daily
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 7
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: postgres-backup
              image: postgres:14-alpine
              env:
                - name: PGPASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: postgres-credentials
                      key: password
                - name: BACKUP_DATE
                  value: $(date +%Y%m%d_%H%M%S)
              command:
                - /bin/sh
                - -c
                - |
                  pg_dump -h postgres-service -U postgres -d myapp > /backup/db_${BACKUP_DATE}.sql
                  gzip /backup/db_${BACKUP_DATE}.sql
                  aws s3 cp /backup/db_${BACKUP_DATE}.sql.gz s3://my-backups/postgres/
              volumeMounts:
                - name: backup-storage
                  mountPath: /backup
              resources:
                requests:
                  memory: "256Mi"
                  cpu: "250m"
                limits:
                  memory: "512Mi"
                  cpu: "500m"
          volumes:
            - name: backup-storage
              emptyDir: {}
          restartPolicy: OnFailure
```

### MongoDB Incremental Backup

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mongodb-incremental-backup
  namespace: production
spec:
  schedule: "0 */6 * * *" # Every 6 hours
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: mongodump
              image: mongo:5.0
              env:
                - name: MONGO_URI
                  valueFrom:
                    secretKeyRef:
                      name: mongodb-uri
                      key: connection-string
              command:
                - /bin/bash
                - -c
                - |
                  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                  mongodump --uri="$MONGO_URI" --archive=/tmp/mongo_backup_${TIMESTAMP}.gz --gzip

                  # Upload to Hexabase.AI object storage
                  hxb storage upload \
                    --source=/tmp/mongo_backup_${TIMESTAMP}.gz \
                    --destination=backups/mongodb/${TIMESTAMP}/
                    
                  # Clean up local file
                  rm /tmp/mongo_backup_${TIMESTAMP}.gz
              resources:
                requests:
                  memory: "512Mi"
                  cpu: "500m"
                limits:
                  memory: "1Gi"
                  cpu: "1"
          restartPolicy: OnFailure
```

## Data Processing Jobs

### ETL Pipeline Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etl-pipeline
  namespace: data-processing
  labels:
    app: etl
    team: data-engineering
spec:
  schedule: "30 1 * * *" # 1:30 AM daily
  concurrencyPolicy: Replace
  startingDeadlineSeconds: 300
  jobTemplate:
    spec:
      activeDeadlineSeconds: 7200 # 2 hour timeout
      parallelism: 3
      template:
        spec:
          containers:
            - name: etl-processor
              image: myregistry/etl-processor:v2.1
              env:
                - name: SOURCE_DB
                  value: "postgres://source-db:5432/analytics"
                - name: TARGET_DB
                  value: "clickhouse://analytics-cluster:9000/warehouse"
                - name: PROCESSING_DATE
                  value: "$(date -d 'yesterday' +%Y-%m-%d)"
              command:
                - python
                - /app/etl_pipeline.py
                - --date=$(PROCESSING_DATE)
                - --mode=incremental
              resources:
                requests:
                  memory: "2Gi"
                  cpu: "1"
                limits:
                  memory: "4Gi"
                  cpu: "2"
          nodeSelector:
            workload-type: batch-processing
          tolerations:
            - key: batch-processing
              operator: Equal
              value: "true"
              effect: NoSchedule
          restartPolicy: OnFailure
```

### Data Aggregation Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hourly-metrics-aggregation
  namespace: analytics
spec:
  schedule: "5 * * * *" # 5 minutes past every hour
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: aggregator
              image: analytics/aggregator:latest
              command:
                - /bin/sh
                - -c
                - |
                  # Calculate hourly metrics
                  python /scripts/aggregate_metrics.py \
                    --start-time="$(date -d '1 hour ago' --iso-8601)" \
                    --end-time="$(date --iso-8601)" \
                    --output-table=hourly_metrics

                  # Send completion notification
                  curl -X POST $WEBHOOK_URL \
                    -H "Content-Type: application/json" \
                    -d '{"status": "completed", "job": "hourly-metrics"}'
              env:
                - name: WEBHOOK_URL
                  valueFrom:
                    configMapKeyRef:
                      name: job-config
                      key: webhook-url
              resources:
                requests:
                  memory: "1Gi"
                  cpu: "500m"
          restartPolicy: Never
```

## Maintenance Jobs

### Log Cleanup Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: log-cleanup
  namespace: system-maintenance
spec:
  schedule: "0 3 * * 0" # 3 AM every Sunday
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: log-cleaner
          containers:
            - name: cleanup
              image: busybox:latest
              command:
                - /bin/sh
                - -c
                - |
                  # Clean up logs older than 30 days
                  find /var/log/apps -name "*.log" -type f -mtime +30 -delete

                  # Compress logs older than 7 days
                  find /var/log/apps -name "*.log" -type f -mtime +7 -exec gzip {} \;

                  # Report disk usage
                  df -h /var/log/apps
              volumeMounts:
                - name: app-logs
                  mountPath: /var/log/apps
              resources:
                requests:
                  memory: "128Mi"
                  cpu: "100m"
                limits:
                  memory: "256Mi"
                  cpu: "200m"
          volumes:
            - name: app-logs
              persistentVolumeClaim:
                claimName: app-logs-pvc
          restartPolicy: OnFailure
```

### Certificate Renewal Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cert-renewal
  namespace: cert-manager
spec:
  schedule: "0 0 1 * *" # Monthly on the 1st
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: cert-renewer
          containers:
            - name: certbot
              image: certbot/certbot:latest
              command:
                - /bin/sh
                - -c
                - |
                  # Check certificate expiration
                  for domain in app.example.com api.example.com; do
                    if openssl x509 -checkend 2592000 -noout -in /etc/letsencrypt/live/$domain/cert.pem; then
                      echo "Certificate for $domain is still valid"
                    else
                      echo "Renewing certificate for $domain"
                      certbot renew --cert-name $domain --non-interactive
                      
                      # Update Kubernetes secret
                      kubectl create secret tls ${domain}-tls \
                        --cert=/etc/letsencrypt/live/$domain/fullchain.pem \
                        --key=/etc/letsencrypt/live/$domain/privkey.pem \
                        --dry-run=client -o yaml | kubectl apply -f -
                    fi
                  done
              volumeMounts:
                - name: letsencrypt
                  mountPath: /etc/letsencrypt
              resources:
                requests:
                  memory: "128Mi"
                  cpu: "100m"
          volumes:
            - name: letsencrypt
              persistentVolumeClaim:
                claimName: letsencrypt-pvc
          restartPolicy: OnFailure
```

## Reporting Jobs

### Daily Usage Report

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-usage-report
  namespace: reporting
spec:
  schedule: "0 6 * * *" # 6 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: report-generator
              image: reporting/usage-reporter:v1.2
              env:
                - name: REPORT_DATE
                  value: "$(date -d 'yesterday' +%Y-%m-%d)"
                - name: SMTP_HOST
                  valueFrom:
                    configMapKeyRef:
                      name: smtp-config
                      key: host
                - name: RECIPIENTS
                  value: "team@example.com,manager@example.com"
              command:
                - python
                - /app/generate_report.py
                - --date=$(REPORT_DATE)
                - --format=pdf
                - --send-email
              resources:
                requests:
                  memory: "512Mi"
                  cpu: "250m"
          restartPolicy: OnFailure
```

### Cost Analysis Report

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: weekly-cost-analysis
  namespace: finops
spec:
  schedule: "0 9 * * 1" # 9 AM every Monday
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: cost-analyzer
              image: finops/cost-analyzer:latest
              command:
                - /bin/bash
                - -c
                - |
                  # Fetch usage data from Hexabase.AI API
                  hxb usage export \
                    --start-date="$(date -d '7 days ago' +%Y-%m-%d)" \
                    --end-date="$(date -d 'yesterday' +%Y-%m-%d)" \
                    --format=json > /tmp/usage.json

                  # Generate cost report
                  python /app/analyze_costs.py \
                    --input=/tmp/usage.json \
                    --output=/tmp/cost_report.html

                  # Upload to shared storage
                  hxb storage upload \
                    --source=/tmp/cost_report.html \
                    --destination=reports/costs/week_$(date +%Y%W).html

                  # Send notification
                  python /app/send_notification.py \
                    --report-url="https://storage.hexabase.ai/reports/costs/week_$(date +%Y%W).html"
              resources:
                requests:
                  memory: "256Mi"
                  cpu: "200m"
          restartPolicy: OnFailure
```

## Integration Jobs

### Slack Notification Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-standup-reminder
  namespace: notifications
spec:
  schedule: "0 9 * * 1-5" # 9 AM Monday-Friday
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: slack-notifier
              image: curlimages/curl:latest
              env:
                - name: SLACK_WEBHOOK
                  valueFrom:
                    secretKeyRef:
                      name: slack-credentials
                      key: webhook-url
              command:
                - /bin/sh
                - -c
                - |
                  curl -X POST $SLACK_WEBHOOK \
                    -H 'Content-Type: application/json' \
                    -d '{
                      "text": "🏃 Daily Standup Reminder",
                      "blocks": [
                        {
                          "type": "header",
                          "text": {
                            "type": "plain_text",
                            "text": "Time for Daily Standup!"
                          }
                        },
                        {
                          "type": "section",
                          "text": {
                            "type": "mrkdwn",
                            "text": "*Meeting Link:* <https://meet.example.com/standup|Join Here>\n*Time:* 9:15 AM"
                          }
                        }
                      ]
                    }'
              resources:
                requests:
                  memory: "32Mi"
                  cpu: "50m"
          restartPolicy: OnFailure
```

### GitHub Actions Trigger

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-build-trigger
  namespace: ci-cd
spec:
  schedule: "0 0 * * *" # Midnight daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: github-trigger
              image: ghcr.io/github/gh:latest
              env:
                - name: GITHUB_TOKEN
                  valueFrom:
                    secretKeyRef:
                      name: github-token
                      key: token
              command:
                - /bin/sh
                - -c
                - |
                  # Trigger workflow dispatch
                  gh workflow run nightly-build.yml \
                    --repo myorg/myrepo \
                    --ref main \
                    --field environment=production \
                    --field version=$(date +%Y%m%d)
              resources:
                requests:
                  memory: "64Mi"
                  cpu: "50m"
          restartPolicy: OnFailure
```

## Monitoring Jobs

### Health Check Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: endpoint-health-check
  namespace: monitoring
spec:
  schedule: "*/5 * * * *" # Every 5 minutes
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: health-checker
              image: monitoring/health-checker:v1.0
              env:
                - name: ENDPOINTS
                  value: "https://api.example.com/health,https://app.example.com/health"
                - name: ALERT_WEBHOOK
                  valueFrom:
                    secretKeyRef:
                      name: alerting-config
                      key: webhook-url
              command:
                - python
                - /app/check_health.py
                - --timeout=30
                - --alert-on-failure
              resources:
                requests:
                  memory: "128Mi"
                  cpu: "100m"
                limits:
                  memory: "256Mi"
                  cpu: "200m"
          restartPolicy: OnFailure
```

## Best Practices Examples

### Job with Init Container

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: data-processor-with-init
  namespace: batch-jobs
spec:
  schedule: "0 */4 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          initContainers:
            - name: wait-for-db
              image: busybox:latest
              command:
                [
                  "sh",
                  "-c",
                  "until nc -z postgres-service 5432; do sleep 2; done",
                ]
          containers:
            - name: processor
              image: data/processor:latest
              command: ["/app/process.sh"]
          restartPolicy: OnFailure
```

### Job with Multiple Containers

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: multi-container-job
  namespace: complex-jobs
spec:
  schedule: "30 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: data-fetcher
              image: fetcher:latest
              volumeMounts:
                - name: shared-data
                  mountPath: /data
            - name: data-processor
              image: processor:latest
              volumeMounts:
                - name: shared-data
                  mountPath: /data
          volumes:
            - name: shared-data
              emptyDir: {}
          restartPolicy: OnFailure
```

## Related Documentation

- [UI Configuration Guide](ui-configuration.md)
- [Integration Patterns](integration-patterns.md)
- [CronJob Best Practices](../../cronjobs/index.md)
- [Monitoring CronJobs](../observability/dashboards-alerts.md)
