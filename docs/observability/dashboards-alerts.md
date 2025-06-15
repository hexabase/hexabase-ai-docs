# Dashboards and Alerts

Visualizing your system's health and being proactively notified of issues are core components of observability. Hexabase.AI provides a powerful, integrated solution for creating custom dashboards and configuring intelligent alerts.

## Dashboards

Dashboards in Hexabase.AI allow you to create a customized, at-a-glance view of the metrics, logs, and traces that are most important to you. The dashboarding system is built on Grafana, providing a rich set of visualization options.

### Default Dashboards

Out of the box, HKS provides several pre-configured dashboards for common use cases:

- **Kubernetes Cluster Health**: Overview of CPU, memory, and disk usage across all nodes.
- **Application Performance (RED)**: Key metrics for your services: Rate, Errors, and Duration.
- **Pod Resource Usage**: Detailed CPU and memory consumption for individual pods.
- **Nginx Ingress Controller**: Metrics for ingress traffic, including request volume and error rates.

### Creating a Custom Dashboard

You can easily create your own dashboards to visualize application-specific metrics.

1.  **Navigate to the Dashboards section** in the HKS UI.
2.  **Create a new dashboard** and add a panel.
3.  **Select a Data Source**: Your primary data source will be the HKS Metrics store (Prometheus/VictoriaMetrics), but you can also query logs from ClickHouse.
4.  **Write a Query**: Use PromQL (Prometheus Query Language) to select the metric you want to visualize.
    ```promql
    # Example: Graph the 95th percentile latency for a specific service
    histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service="my-app"}[5m])) by (le))
    ```
5.  **Choose a Visualization**: Select from a wide range of panel types, including:
    - Graphs and time series
    - Stat panels and gauges
    - Tables
    - Heatmaps
    - Logs panels

### Dashboard as Code

For better version control and repeatability, you can define your dashboards as code using a `ConfigMap`.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-dashboard
  labels:
    grafana_dashboard: "1"
data:
  my-app.json: |
    {
      "__inputs": [],
      "__requires": [],
      "annotations": { ... },
      "editable": true,
      "panels": [ ... ],
      "title": "My Application Dashboard"
    }
```

HKS will automatically discover this ConfigMap and import the dashboard into the UI.

## Alerting

The HKS alerting system, powered by the AIOps engine, allows you to define alerts based on metrics, logs, or traces.

### Creating an Alert Rule

Alert rules are defined as a custom resource.

```yaml
# alert-rule.yaml
apiVersion: hks.io/v1
kind: AlertRule
metadata:
  name: high-cpu-utilization
spec:
  # The condition that triggers the alert
  condition:
    type: metric
    query: 'sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (pod) > 0.8'
    for: 5m # Fire only if the condition is true for 5 continuous minutes

  # Severity of the alert
  severity: warning

  # Information about the alert
  summary: "Pod {{ $labels.pod }} has high CPU usage."
  description: "The pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has been using over 80% CPU for the last 5 minutes."

  # Where to send the notification
  notification:
    channel: "slack-channel-prod-alerts"
```

### Supported Alert Conditions

- **Metric-based**: Trigger an alert when a PromQL query returns a value that crosses a threshold (e.g., `cpu > 80%`, `error_rate > 5%`).
- **Log-based**: Trigger an alert when a certain pattern appears in the logs (e.g., `level=error` or `message contains "fatal"`).
- **AIOps Anomaly Detection**: Trigger an alert when the AIOps engine detects a significant deviation from the normal behavior of a metric (e.g., a sudden drop in request rate).

### Notification Channels

You can configure multiple channels to send alert notifications to.

```yaml
apiVersion: hks.io/v1
kind: NotificationChannel
metadata:
  name: slack-channel-prod-alerts
spec:
  type: slack
  config:
    urlSecretRef:
      name: slack-webhook-secret
      key: url
    channel: "#production-alerts"
---
apiVersion: hks.io/v1
kind: NotificationChannel
metadata:
  name: pagerduty-sre-oncall
spec:
  type: pagerduty
  config:
    integrationKeySecretRef:
      name: pagerduty-api-key
      key: key
```

**Supported Channel Types:**

- Slack
- PagerDuty
- Email
- Opsgenie
- Generic Webhook

## Best Practices

1.  **Dashboard for Your Audience**: Create different dashboards for different teams. A developer might need detailed application-level metrics, while a platform administrator might need a high-level cluster health overview.
2.  **Alert on Symptoms, Not Causes**: Your primary alerts should focus on user-facing symptoms like high error rates, high latency, or low availability. These are what directly impact the user experience. Alerting on causes (like high CPU) is still useful but should generally be a lower severity.
3.  **Avoid Alert Fatigue**: Be selective about what you alert on. If an alert is not actionable, it's just noise. Fine-tune your thresholds and use `for` durations to avoid alerts for transient spikes.
4.  **Use Templates**: Use dashboard and alert rule templates to ensure consistency across your services.
5.  **Document Your Alerts**: In the `description` or `runbook_url` field of your alert rule, provide clear instructions on how to diagnose and mitigate the issue. This helps the on-call engineer resolve the problem quickly.
