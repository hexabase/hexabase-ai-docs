# Observability

Gain deep insights into your applications and infrastructure with Hexabase.AI's comprehensive observability platform.

## Overview

Hexabase.AI provides a unified observability platform that combines metrics, logs, traces, and alerts to give you complete visibility into your Kubernetes workloads. Our AI-powered insights help you quickly identify issues, optimize performance, and ensure reliability.

## Observability Components

<div class="grid cards" markdown>

- :material-chart-line:{ .lg .middle } **Metrics & Monitoring**

  ***

  Real-time metrics collection and visualization

  [:octicons-arrow-right-24: Explore Metrics](monitoring-setup.md)

- :material-text-box-search:{ .lg .middle } **Logging**

  ***

  Centralized log aggregation and analysis

  [:octicons-arrow-right-24: Logging Guide](logging.md)

- :material-transit-connection-variant:{ .lg .middle } **Distributed Tracing**

  ***

  Track requests across microservices

  [:octicons-arrow-right-24: Tracing Guide](tracing.md)

- :material-bell-alert:{ .lg .middle } **Alerting**

  ***

  Intelligent alerts and incident management

  [:octicons-arrow-right-24: Alerting Setup](dashboards-alerts.md)

</div>

## The Three Pillars of Observability

### 1. Metrics

Quantitative measurements of system behavior

- **System Metrics**: CPU, memory, disk, network usage
- **Application Metrics**: Request rates, error rates, latency
- **Business Metrics**: User activity, transaction volumes
- **Custom Metrics**: Application-specific measurements

### 2. Logs

Detailed records of system events

- **Application Logs**: Debug messages, errors, audit trails
- **System Logs**: Kernel messages, container runtime logs
- **Access Logs**: HTTP requests, API calls
- **Security Logs**: Authentication attempts, policy violations

### 3. Traces

End-to-end request flow tracking

- **Distributed Traces**: Cross-service request paths
- **Performance Analysis**: Identify bottlenecks
- **Dependency Mapping**: Service interaction visualization
- **Error Propagation**: Track error sources

## AI-Powered Features

### Anomaly Detection

- Automatic baseline learning
- Real-time anomaly alerts
- Predictive failure detection
- Seasonal pattern recognition

### Root Cause Analysis

- Intelligent correlation of metrics, logs, and traces
- Automated incident investigation
- Suggested remediation steps
- Historical pattern matching

### Performance Optimization

- Resource usage recommendations
- Cost optimization suggestions
- Scaling predictions
- Capacity planning insights

## Observability Stack

```
┌─────────────────────────────────────────┐
│           Dashboards & UI               │
│     (Grafana, Custom Dashboards)        │
├─────────────────────────────────────────┤
│         Query & Analytics               │
│   (PromQL, LogQL, TraceQL, AI/ML)      │
├─────────────────────────────────────────┤
│           Data Storage                  │
│  (Prometheus, Loki, Tempo, S3)         │
├─────────────────────────────────────────┤
│         Data Collection                 │
│  (Agents, Sidecars, OpenTelemetry)     │
├─────────────────────────────────────────┤
│          Applications                   │
│    (Your Workloads, System Pods)       │
└─────────────────────────────────────────┘
```

## Quick Start

### 1. Enable Observability

```bash
hks observability enable --workspace my-workspace
```

### 2. View Metrics Dashboard

```bash
hks dashboard open metrics --workspace my-workspace
```

### 3. Search Logs

```bash
hks logs search "error" --workspace my-workspace --last 1h
```

### 4. Create Alert

```bash
hks alert create high-cpu \
  --metric "cpu_usage > 80" \
  --duration 5m \
  --notify slack
```

## Common Use Cases

### Application Performance Monitoring

- Track response times and error rates
- Identify slow endpoints
- Monitor database query performance
- Analyze user experience metrics

### Infrastructure Monitoring

- Resource utilization tracking
- Capacity planning
- Cost optimization
- Predictive scaling

### Security Monitoring

- Detect unusual access patterns
- Monitor failed authentication attempts
- Track configuration changes
- Compliance auditing

### Business Intelligence

- User behavior analytics
- Feature adoption tracking
- Revenue impact analysis
- SLA compliance monitoring

## Best Practices

### 1. Structured Logging

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "ERROR",
  "service": "payment-api",
  "trace_id": "abc123",
  "user_id": "user456",
  "message": "Payment processing failed",
  "error": "Insufficient funds"
}
```

### 2. Meaningful Metrics

```yaml
# Good metric naming
http_requests_total{method="GET", endpoint="/api/users", status="200"}
payment_processing_duration_seconds{gateway="stripe"}

# Include relevant labels
deployment_info{version="1.2.3", environment="production"}
```

### 3. Effective Alerting

- Alert on symptoms, not causes
- Include runbook links
- Set appropriate severity levels
- Avoid alert fatigue

### 4. Cost Management

- Use sampling for high-volume data
- Set retention policies
- Archive old data to object storage
- Monitor observability costs

## Integration Examples

### OpenTelemetry SDK

```python
from opentelemetry import trace, metrics

tracer = trace.get_tracer(__name__)
meter = metrics.get_meter(__name__)

counter = meter.create_counter(
    "api_calls",
    description="Number of API calls"
)

@tracer.start_as_current_span("process_request")
def process_request(request):
    counter.add(1, {"endpoint": request.path})
    # Process request...
```

### Prometheus Metrics

```go
var (
    httpDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "Duration of HTTP requests in seconds",
        },
        []string{"path", "method"},
    )
)

func init() {
    prometheus.MustRegister(httpDuration)
}
```

## Compliance and Governance

- **Data Retention**: Configurable retention policies
- **Access Control**: RBAC for observability data
- **Audit Logging**: Track who accessed what data
- **Data Privacy**: PII masking and encryption
- **Compliance Reports**: SOC2, HIPAA, GDPR ready

## Next Steps

- **Metrics**: Set up [Metrics & Monitoring](monitoring-setup.md)
- **Logs**: Configure [Centralized Logging](logging.md)
- **Traces**: Implement [Distributed Tracing](tracing.md)
- **Alerts**: Create [Intelligent Alerts](dashboards-alerts.md)

## Related Documentation

- [AIOps Features](../aiops/index.md)
- [Architecture Overview](../architecture/index.md)
- [API Reference](../api/index.md)
- [Best Practices](../security/index.md)
