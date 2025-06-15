# Functions

Deploy and manage serverless functions on Kubernetes with Hexabase.AI's Functions feature.

## Overview

Hexabase.AI Functions brings serverless computing to your Kubernetes infrastructure, allowing you to run code without managing servers or containers. Built on industry-standard frameworks, our Functions feature provides automatic scaling, event-driven execution, and seamless integration with your existing Kubernetes workloads.

## Functions Documentation

<div class="grid cards" markdown>

- :material-lightning-bolt:{ .lg .middle } **Quick Start**

  ***

  Deploy your first function in minutes

  [:octicons-arrow-right-24: Get Started](overview.md)

- :material-function:{ .lg .middle } **Function Types**

  ***

  HTTP endpoints, event handlers, and scheduled functions

  [:octicons-arrow-right-24: Function Types](architecture.md)

- :material-code-braces:{ .lg .middle } **Development Guide**

  ***

  Writing, testing, and debugging functions

  [:octicons-arrow-right-24: Development Guide](development.md)

- :material-rocket-launch:{ .lg .middle } **Deployment**

  ***

  Deploy and manage your functions with ease

  [:octicons-arrow-right-24: Deployment Guide](deployment.md)

</div>

## Key Features

### 1. Multi-Language Support

- **Python**: Data processing and ML workloads
- **Node.js**: API endpoints and webhooks
- **Go**: High-performance services
- **Java**: Enterprise integrations
- **Custom Runtimes**: Bring your own runtime

### 2. Event Sources

- **HTTP Triggers**: RESTful APIs and webhooks
- **Message Queues**: Kafka, RabbitMQ, NATS
- **Storage Events**: S3-compatible object storage
- **Scheduled Events**: Cron-based triggers
- **Custom Events**: Application-specific triggers

### 3. Automatic Scaling

- **Scale to Zero**: Save resources when idle
- **Instant Scale-Up**: Handle traffic spikes
- **Concurrent Execution**: Process multiple requests
- **Custom Metrics**: Scale based on your metrics

### 4. Developer Experience

- **Local Development**: Test functions locally
- **Hot Reload**: Instant updates during development
- **Integrated Logging**: Centralized function logs
- **Distributed Tracing**: Track request flow

## Use Cases

### API Endpoints

```python
# function.py
def handle(request):
    name = request.get('name', 'World')
    return {
        'statusCode': 200,
        'body': f'Hello, {name}!'
    }
```

### Data Processing

```python
# process_image.py
import base64
from PIL import Image

def handle(event):
    # Process uploaded image
    image_data = base64.b64decode(event['data'])
    img = Image.open(io.BytesIO(image_data))

    # Resize image
    thumbnail = img.resize((128, 128))

    # Return processed image
    output = io.BytesIO()
    thumbnail.save(output, format='JPEG')

    return {
        'statusCode': 200,
        'body': base64.b64encode(output.getvalue()),
        'headers': {'Content-Type': 'image/jpeg'}
    }
```

### Event Processing

```javascript
// handle_order.js
module.exports.handle = async (event) => {
  const order = JSON.parse(event.data);

  // Process order
  await validateOrder(order);
  await chargePayment(order);
  await sendConfirmation(order);

  return {
    statusCode: 200,
    body: JSON.stringify({
      orderId: order.id,
      status: "processed",
    }),
  };
};
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Event Source  │────▶│  Function Router │────▶│ Function Runtime │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │                          │
                               ▼                          ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │    Autoscaler   │     │   Your Function  │
                        └─────────────────┘     └─────────────────┘
```

## Function Lifecycle

1. **Development**: Write and test locally
2. **Packaging**: Bundle code and dependencies
3. **Deployment**: Push to Hexabase.AI
4. **Invocation**: Triggered by events
5. **Scaling**: Automatic based on load
6. **Monitoring**: Track performance and errors

## Quick Examples

### Deploy a Function

```bash
# Deploy from current directory
hks function deploy hello-world \
  --runtime python3.9 \
  --handler function.handle \
  --trigger http

# Deploy from Git repository
hks function deploy data-processor \
  --git-url https://github.com/myorg/functions \
  --git-path processors/etl \
  --trigger cron --schedule "0 * * * *"
```

### Invoke a Function

```bash
# HTTP trigger
curl https://api.hexabase.ai/functions/hello-world \
  -d '{"name": "Alice"}'

# Direct invocation
hks function invoke data-processor \
  --data '{"file": "s3://bucket/data.csv"}'
```

### View Function Logs

```bash
hks function logs hello-world --follow
```

## Best Practices

### 1. Stateless Design

Functions should not maintain state between invocations

### 2. Fast Cold Starts

Minimize dependencies and initialization time

### 3. Error Handling

Implement proper error handling and retries

### 4. Resource Limits

Set appropriate memory and timeout limits

### 5. Security

Use secrets management for sensitive data

## Comparison with CronJobs

| Feature  | Functions                     | CronJobs                  |
| -------- | ----------------------------- | ------------------------- |
| Trigger  | Events, HTTP, Schedule        | Schedule only             |
| Scaling  | Automatic (0 to N)            | Fixed replicas            |
| Duration | Short-lived (seconds-minutes) | Long-running possible     |
| Use Case | API endpoints, webhooks       | Batch processing, backups |

## Next Steps

- **Get Started**: Deploy your first function with our [Quick Start](overview.md)
- **Learn More**: Explore different [Function Types](architecture.md)
- **Build**: Follow our [Development Guide](development.md)
- **Deploy**: Master [Deployment](deployment.md)

## Related Documentation

- [CronJobs](../cronjobs/index.md) for scheduled batch jobs
- [API Reference](../api/function-api.md) for function API
- [Observability](../observability/index.md) for monitoring
- [Security Best Practices](../security/index.md)
