# CronJob Integration Patterns

This guide covers common patterns for integrating CronJobs with other Hexabase.AI features and external systems.

## CI/CD Pipeline Integration

### Triggering Pipeline Builds

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-build-trigger
  namespace: ci-cd
spec:
  schedule: "0 2 * * *" # 2 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: pipeline-trigger
          containers:
            - name: trigger
              image: hexabase/cli:latest
              command:
                - /bin/sh
                - -c
                - |
                  # Trigger Hexabase.AI pipeline
                  hxb pipeline trigger \
                    --name=nightly-build \
                    --branch=main \
                    --params='{"build_type": "release", "run_tests": "true"}'

                  # Wait for pipeline to start
                  PIPELINE_ID=$(hxb pipeline status --name=nightly-build --format=json | jq -r '.latest_run_id')

                  # Monitor pipeline status
                  hxb pipeline wait --id=$PIPELINE_ID --timeout=3600
```

### Post-Deployment Verification

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: deployment-verifier
  namespace: production
spec:
  schedule: "*/30 * * * *" # Every 30 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: verifier
              image: verification/suite:latest
              env:
                - name: DEPLOYMENT_ENV
                  value: "production"
              command:
                - python
                - /app/verify_deployment.py
                - --checks=health,performance,security
                - --alert-on-failure
```

## Function Integration

### Scheduled Function Invocation

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: data-processor-function
  namespace: functions
spec:
  schedule: "0 * * * *" # Hourly
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: function-invoker
              image: hexabase/function-runner:latest
              env:
                - name: FUNCTION_NAME
                  value: "process-hourly-data"
                - name: FUNCTION_NAMESPACE
                  value: "data-processing"
              command:
                - /bin/sh
                - -c
                - |
                  # Prepare input data
                  INPUT_DATA=$(cat <<EOF
                  {
                    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
                    "data_source": "production-db",
                    "processing_type": "incremental"
                  }
                  EOF
                  )

                  # Invoke function
                  hxb function invoke \
                    --name=$FUNCTION_NAME \
                    --namespace=$FUNCTION_NAMESPACE \
                    --data="$INPUT_DATA" \
                    --wait
```

### Batch Function Processing

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: batch-function-processor
  namespace: batch-jobs
spec:
  schedule: "0 3 * * *" # 3 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: batch-processor
              image: batch/processor:latest
              command:
                - python
                - -c
                - |
                  import json
                  import subprocess
                  from datetime import datetime, timedelta

                  # Get items to process
                  items = fetch_pending_items()

                  # Process in batches
                  batch_size = 100
                  for i in range(0, len(items), batch_size):
                      batch = items[i:i+batch_size]
                      
                      # Invoke function for each batch
                      result = subprocess.run([
                          'hxb', 'function', 'invoke',
                          '--name=batch-processor',
                          '--data', json.dumps({'items': batch}),
                          '--async'
                      ], capture_output=True)
                      
                      print(f"Processed batch {i//batch_size + 1}")
```

## Backup System Integration

### Coordinated Backup Strategy

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: coordinated-backup
  namespace: backup-system
spec:
  schedule: "0 1 * * *" # 1 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup-coordinator
              image: backup/coordinator:latest
              command:
                - /bin/bash
                - -c
                - |
                  # 1. Trigger application backup
                  hxb backup create \
                    --type=application \
                    --name=daily-app-backup \
                    --retention=30d

                  # 2. Backup persistent volumes
                  for pvc in $(kubectl get pvc -o name); do
                    hxb backup create \
                      --type=volume \
                      --source=$pvc \
                      --name=daily-${pvc##*/}-backup
                  done

                  # 3. Export configuration
                  kubectl get all,cm,secret -o yaml > /tmp/k8s-config-backup.yaml
                  hxb storage upload \
                    --source=/tmp/k8s-config-backup.yaml \
                    --destination=backups/config/$(date +%Y%m%d).yaml

                  # 4. Verify backups
                  hxb backup verify --created-after="1 hour ago"
```

### Cross-Region Replication

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-replication
  namespace: disaster-recovery
spec:
  schedule: "0 4 * * *" # 4 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: replicator
              image: backup/replicator:latest
              env:
                - name: SOURCE_REGION
                  value: "us-east-1"
                - name: TARGET_REGIONS
                  value: "eu-west-1,ap-southeast-1"
              command:
                - /app/replicate_backups.sh
```

## Monitoring Integration

### Metrics Collection

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: custom-metrics-collector
  namespace: monitoring
spec:
  schedule: "*/5 * * * *" # Every 5 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: collector
              image: monitoring/collector:latest
              command:
                - python
                - /app/collect_metrics.py
                - |
                  # Collect custom metrics
                  metrics = {
                      "active_users": count_active_users(),
                      "api_usage": get_api_usage_stats(),
                      "resource_utilization": calculate_resource_usage()
                  }

                  # Push to monitoring system
                  push_to_prometheus(metrics)

                  # Store in ClickHouse for analytics
                  store_in_clickhouse(metrics)
```

### Alert Aggregation

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: alert-digest
  namespace: monitoring
spec:
  schedule: "0 8 * * 1-5" # 8 AM weekdays
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: alert-aggregator
              image: monitoring/alert-digest:latest
              command:
                - /bin/sh
                - -c
                - |
                  # Fetch alerts from last 24 hours
                  ALERTS=$(hxb monitoring alerts list \
                    --since="24h ago" \
                    --format=json)

                  # Generate digest
                  python /app/generate_digest.py \
                    --alerts="$ALERTS" \
                    --output=/tmp/alert_digest.html

                  # Send digest email
                  hxb notify send \
                    --type=email \
                    --recipients=ops-team@example.com \
                    --subject="Daily Alert Digest" \
                    --body-file=/tmp/alert_digest.html
```

## Event-Driven Patterns

### Webhook Processor

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: webhook-processor
  namespace: integrations
spec:
  schedule: "*/10 * * * *" # Every 10 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: webhook-handler
              image: integrations/webhook-processor:latest
              env:
                - name: WEBHOOK_QUEUE
                  value: "pending-webhooks"
              command:
                - python
                - /app/process_webhooks.py
                - --batch-size=50
                - --retry-failed=true
```

### Event Stream Consumer

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: event-consumer
  namespace: event-processing
spec:
  schedule: "*/5 * * * *" # Every 5 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: consumer
              image: events/consumer:latest
              command:
                - /app/consume_events.sh
                - --stream=application-events
                - --checkpoint-interval=1000
                - --max-runtime=280s # Stop before next run
```

## External Service Integration

### Slack Notifications

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: slack-reporter
  namespace: notifications
spec:
  schedule: "0 9 * * 1" # 9 AM every Monday
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: slack-bot
              image: notifications/slack-bot:latest
              env:
                - name: SLACK_WEBHOOK_URL
                  valueFrom:
                    secretKeyRef:
                      name: slack-config
                      key: webhook-url
              command:
                - python
                - /app/weekly_report.py
                - --format=slack
                - --channel=#weekly-updates
```

### Email Reports

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: email-reporter
  namespace: reporting
spec:
  schedule: "0 6 * * *" # 6 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: emailer
              image: reporting/emailer:latest
              env:
                - name: SMTP_CONFIG
                  valueFrom:
                    secretKeyRef:
                      name: smtp-config
                      key: connection-string
              command:
                - /app/send_daily_report.sh
```

## Data Pipeline Integration

### ETL Orchestration

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etl-orchestrator
  namespace: data-pipelines
spec:
  schedule: "0 2 * * *" # 2 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: orchestrator
              image: data/orchestrator:latest
              command:
                - python
                - /app/orchestrate_etl.py
                - |
                  # Step 1: Extract data
                  extract_job = trigger_job("data-extractor")
                  wait_for_completion(extract_job)

                  # Step 2: Transform data
                  transform_jobs = []
                  for dataset in get_datasets():
                      job = trigger_job("data-transformer", params={"dataset": dataset})
                      transform_jobs.append(job)

                  wait_for_all(transform_jobs)

                  # Step 3: Load data
                  load_job = trigger_job("data-loader")
                  wait_for_completion(load_job)

                  # Step 4: Validate
                  validate_job = trigger_job("data-validator")
                  wait_for_completion(validate_job)
```

### Stream Processing Bridge

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: stream-batch-bridge
  namespace: data-processing
spec:
  schedule: "*/15 * * * *" # Every 15 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: bridge
              image: streaming/bridge:latest
              command:
                - /app/bridge.sh
                - --source=kafka://streaming-cluster
                - --destination=clickhouse://analytics-db
                - --batch-window=15m
```

## Security Integration

### Certificate Rotation

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cert-rotator
  namespace: security
spec:
  schedule: "0 0 * * 0" # Weekly on Sunday
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: cert-manager
          containers:
            - name: rotator
              image: security/cert-rotator:latest
              command:
                - /app/rotate_certs.sh
                - --check-expiry=30d
                - --auto-renew=true
                - --update-secrets=true
```

### Security Scanning

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: security-scanner
  namespace: security
spec:
  schedule: "0 3 * * *" # 3 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: scanner
              image: security/scanner:latest
              command:
                - /app/scan.sh
                - --scan-images=true
                - --scan-configs=true
                - --scan-secrets=true
                - --report-critical=true
```

## Best Practices

### Error Handling Pattern

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: robust-job
  namespace: production
spec:
  schedule: "0 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: worker
              image: myapp/worker:latest
              command:
                - /bin/bash
                - -c
                - |
                  set -e  # Exit on error

                  # Error handling function
                  handle_error() {
                      echo "Error occurred: $1"
                      # Send alert
                      curl -X POST $ALERT_WEBHOOK \
                        -d "{\"error\": \"$1\", \"job\": \"$JOB_NAME\"}"
                      exit 1
                  }

                  # Set trap for errors
                  trap 'handle_error "Unexpected error"' ERR

                  # Main job logic
                  process_data || handle_error "Data processing failed"
                  validate_results || handle_error "Validation failed"

                  echo "Job completed successfully"
```

### Idempotent Job Pattern

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: idempotent-job
  namespace: data-processing
spec:
  schedule: "*/30 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: processor
              image: data/processor:latest
              command:
                - python
                - -c
                - |
                  # Check if job already ran
                  last_run = get_last_successful_run()
                  if last_run and last_run > datetime.now() - timedelta(minutes=30):
                      print("Job already completed in this window")
                      exit(0)

                  # Process with idempotency key
                  process_id = generate_idempotency_key()
                  if not start_processing(process_id):
                      print("Another instance is processing")
                      exit(0)

                  # Perform work
                  try:
                      do_work()
                      mark_success(process_id)
                  except Exception as e:
                      mark_failure(process_id, str(e))
                      raise
```

## Related Documentation

- [CronJob Examples](examples.md)
- [UI Configuration](ui-configuration.md)
- [Function Development](../functions/development.md)
- [Pipeline Configuration](../../cicd/pipeline-configuration.md)
