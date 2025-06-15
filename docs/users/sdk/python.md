# Python SDK

This comprehensive guide covers the Hexabase.AI Python SDK, providing everything you need to integrate Hexabase.AI services into your Python applications.

## Installation

### Requirements

- Python 3.8 or higher
- pip package manager
- Virtual environment (recommended)

### Installation Methods

```bash
# Install from PyPI
pip install hexabase-ai

# Install with optional dependencies
pip install hexabase-ai[async,monitoring,ml]

# Install from source
git clone https://github.com/hexabase-ai/python-sdk.git
cd python-sdk
pip install -e .
```

### Virtual Environment Setup

```bash
# Create virtual environment
python -m venv hexabase-env

# Activate virtual environment
# On Unix/macOS:
source hexabase-env/bin/activate
# On Windows:
hexabase-env\Scripts\activate

# Install SDK
pip install hexabase-ai
```

## Quick Start

### Basic Usage

```python
from hexabase import Client, Config

# Initialize client with API key
client = Client(
    api_key="your-api-key",
    endpoint="https://api.hexabase.ai"
)

# Or use environment variables
# export HEXABASE_API_KEY=your-api-key
# export HEXABASE_ENDPOINT=https://api.hexabase.ai
client = Client()

# List workspaces
workspaces = client.workspaces.list()
for workspace in workspaces:
    print(f"Workspace: {workspace.name} (ID: {workspace.id})")

# Get specific workspace
workspace = client.workspaces.get("workspace-id")

# Deploy an application
app = workspace.applications.create(
    name="my-python-app",
    runtime="python3.9",
    source_code="./app"
)
```

### Async Support

```python
import asyncio
from hexabase import AsyncClient

async def main():
    # Initialize async client
    async with AsyncClient() as client:
        # List workspaces asynchronously
        workspaces = await client.workspaces.list()

        # Deploy multiple applications concurrently
        tasks = []
        for i in range(5):
            task = client.applications.create(
                name=f"app-{i}",
                runtime="python3.9"
            )
            tasks.append(task)

        apps = await asyncio.gather(*tasks)
        print(f"Deployed {len(apps)} applications")

# Run async code
asyncio.run(main())
```

## Authentication

### API Key Authentication

```python
from hexabase import Client
from hexabase.auth import APIKeyAuth

# Direct API key
auth = APIKeyAuth(api_key="your-api-key")
client = Client(auth=auth)

# From environment variable
auth = APIKeyAuth.from_env("HEXABASE_API_KEY")
client = Client(auth=auth)

# From file
auth = APIKeyAuth.from_file("~/.hexabase/credentials")
client = Client(auth=auth)
```

### OAuth 2.0 Authentication

```python
from hexabase.auth import OAuth2Auth

# OAuth with client credentials
auth = OAuth2Auth(
    client_id="your-client-id",
    client_secret="your-client-secret",
    token_url="https://auth.hexabase.ai/oauth/token"
)

client = Client(auth=auth)

# OAuth with authorization code flow
auth = OAuth2Auth(
    client_id="your-client-id",
    redirect_uri="http://localhost:8080/callback",
    authorization_url="https://auth.hexabase.ai/oauth/authorize"
)

# Get authorization URL
auth_url = auth.get_authorization_url()
print(f"Visit: {auth_url}")

# Exchange code for token
auth.exchange_code(authorization_code)
client = Client(auth=auth)
```

### Service Account Authentication

```python
from hexabase.auth import ServiceAccountAuth

# From JSON key file
auth = ServiceAccountAuth.from_file("service-account-key.json")
client = Client(auth=auth)

# From dict
auth = ServiceAccountAuth(
    account_id="sa-12345",
    private_key="-----BEGIN RSA PRIVATE KEY-----...",
    project_id="my-project"
)
client = Client(auth=auth)
```

## Core Features

### Workspace Management

```python
from hexabase import Client
from hexabase.models import Workspace, WorkspaceSettings

client = Client()

# Create workspace
workspace = client.workspaces.create(
    name="production",
    description="Production environment",
    settings=WorkspaceSettings(
        node_type="dedicated",
        region="us-east-1",
        resource_limits={
            "cpu": "16",
            "memory": "64Gi",
            "storage": "1Ti"
        }
    )
)

# Update workspace
workspace.update(
    description="Updated production environment",
    settings=WorkspaceSettings(
        auto_scaling=True,
        min_nodes=2,
        max_nodes=10
    )
)

# List workspace resources
resources = workspace.get_resources()
print(f"CPU Usage: {resources.cpu_usage}%")
print(f"Memory Usage: {resources.memory_usage}%")
print(f"Storage Usage: {resources.storage_usage}%")

# Delete workspace (with confirmation)
workspace.delete(confirm=True)
```

### Application Deployment

```python
from hexabase import Client
from hexabase.models import Application, DeploymentConfig

client = Client()
workspace = client.workspaces.get("workspace-id")

# Deploy from source code
app = workspace.applications.create(
    name="flask-api",
    runtime="python3.9",
    source_code="./src",
    entry_point="app.py",
    environment_variables={
        "DATABASE_URL": "postgresql://...",
        "REDIS_URL": "redis://..."
    }
)

# Deploy from Docker image
app = workspace.applications.create(
    name="containerized-app",
    image="myregistry/myapp:latest",
    ports=[8080, 9090],
    deployment_config=DeploymentConfig(
        replicas=3,
        cpu_request="500m",
        cpu_limit="2",
        memory_request="1Gi",
        memory_limit="4Gi",
        autoscaling={
            "enabled": True,
            "min_replicas": 2,
            "max_replicas": 10,
            "target_cpu_utilization": 70
        }
    )
)

# Monitor deployment
deployment = app.get_latest_deployment()
while deployment.status != "ready":
    print(f"Deployment status: {deployment.status}")
    time.sleep(5)
    deployment.refresh()

print("Application deployed successfully!")

# Get application logs
logs = app.get_logs(
    container="main",
    lines=100,
    follow=True
)

for log in logs:
    print(f"[{log.timestamp}] {log.message}")
```

### Function Management

```python
from hexabase import Client
from hexabase.models import Function, FunctionTrigger

client = Client()
workspace = client.workspaces.get("workspace-id")

# Create serverless function
function = workspace.functions.create(
    name="data-processor",
    runtime="python3.9",
    handler="main.handler",
    source_code="./functions/processor",
    memory=512,
    timeout=300,
    environment={
        "PROCESSING_MODE": "batch",
        "OUTPUT_BUCKET": "processed-data"
    }
)

# Add HTTP trigger
http_trigger = function.add_trigger(
    type="http",
    config={
        "path": "/process",
        "methods": ["POST"],
        "auth": "api-key"
    }
)

# Add scheduled trigger
cron_trigger = function.add_trigger(
    type="schedule",
    config={
        "expression": "0 2 * * *",  # Daily at 2 AM
        "timezone": "UTC"
    }
)

# Invoke function directly
result = function.invoke(
    payload={"data": "test-data"},
    async_execution=False
)

print(f"Function result: {result.output}")
print(f"Execution time: {result.duration}ms")

# List function executions
executions = function.list_executions(
    status="failed",
    limit=10
)

for execution in executions:
    print(f"Execution {execution.id}: {execution.error}")
```

### Database Operations

```python
from hexabase import Client
from hexabase.database import Database, Table

client = Client()
workspace = client.workspaces.get("workspace-id")

# Create database
db = workspace.databases.create(
    name="analytics",
    engine="postgresql",
    version="14",
    size="db.m5.large",
    storage=100,  # GB
    backup_retention=7  # days
)

# Wait for database to be ready
db.wait_until_ready()

# Get connection details
conn_info = db.get_connection_info()
print(f"Host: {conn_info.host}")
print(f"Port: {conn_info.port}")
print(f"Database: {conn_info.database}")

# Execute queries
with db.connect() as conn:
    # Create table
    conn.execute("""
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Insert data
    conn.execute(
        "INSERT INTO users (email) VALUES (%s)",
        ("user@example.com",)
    )

    # Query data
    result = conn.query("SELECT * FROM users")
    for row in result:
        print(f"User: {row['email']}")

# Backup database
backup = db.create_backup(
    name="pre-migration-backup",
    description="Backup before schema migration"
)

# Restore from backup
db.restore_from_backup(backup.id)
```

## Advanced Features

### Batch Operations

```python
from hexabase import Client
from hexabase.batch import BatchOperation

client = Client()

# Batch application deployment
with BatchOperation(client) as batch:
    for i in range(10):
        batch.create_application(
            workspace_id="workspace-id",
            name=f"app-{i}",
            runtime="python3.9",
            source_code=f"./apps/app-{i}"
        )

    # Execute all operations
    results = batch.execute()

    # Check results
    for result in results:
        if result.success:
            print(f"Created: {result.resource.name}")
        else:
            print(f"Failed: {result.error}")
```

### Event Streaming

```python
from hexabase import Client
from hexabase.events import EventStream

client = Client()

# Subscribe to events
def handle_deployment_event(event):
    print(f"Deployment {event.deployment_id}: {event.status}")
    if event.status == "failed":
        print(f"Error: {event.error}")

# Create event stream
stream = client.events.stream(
    workspace_id="workspace-id",
    event_types=["deployment.*", "application.*"],
    handler=handle_deployment_event
)

# Start streaming
stream.start()

# Stop streaming after some time
time.sleep(3600)
stream.stop()
```

### Monitoring and Metrics

```python
from hexabase import Client
from hexabase.monitoring import MetricsClient
from datetime import datetime, timedelta

client = Client()
metrics = MetricsClient(client)

# Query metrics
cpu_usage = metrics.query(
    metric="node_cpu_usage_percent",
    workspace="workspace-id",
    start_time=datetime.now() - timedelta(hours=1),
    end_time=datetime.now(),
    aggregation="avg",
    interval="5m"
)

# Plot metrics
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6))
plt.plot(cpu_usage.timestamps, cpu_usage.values)
plt.xlabel("Time")
plt.ylabel("CPU Usage (%)")
plt.title("Node CPU Usage - Last Hour")
plt.show()

# Create custom metric
metrics.create_custom_metric(
    name="api_request_count",
    value=1,
    labels={
        "endpoint": "/api/users",
        "method": "GET",
        "status": "200"
    }
)

# Set up alerts
alert = metrics.create_alert(
    name="high-cpu-usage",
    condition="avg(node_cpu_usage_percent) > 80",
    duration="5m",
    actions=[
        {
            "type": "email",
            "recipients": ["ops@example.com"]
        },
        {
            "type": "webhook",
            "url": "https://alerts.example.com/webhook"
        }
    ]
)
```

### AI/ML Integration

```python
from hexabase import Client
from hexabase.ai import AIClient, Model

client = Client()
ai = AIClient(client)

# Deploy ML model
model = ai.models.deploy(
    name="sentiment-analyzer",
    framework="tensorflow",
    model_file="./models/sentiment_model.h5",
    preprocessing_script="./preprocess.py",
    requirements="./requirements.txt"
)

# Create inference endpoint
endpoint = model.create_endpoint(
    name="sentiment-api",
    instance_type="ml.m5.large",
    autoscaling={
        "min_instances": 1,
        "max_instances": 10,
        "target_rps": 100
    }
)

# Make predictions
result = endpoint.predict({
    "text": "This product is amazing!"
})

print(f"Sentiment: {result['sentiment']}")
print(f"Confidence: {result['confidence']}")

# Batch predictions
texts = ["Great service!", "Terrible experience", "It's okay"]
results = endpoint.batch_predict(
    [{"text": text} for text in texts]
)

for text, result in zip(texts, results):
    print(f"{text}: {result['sentiment']} ({result['confidence']:.2f})")

# Monitor model performance
metrics = model.get_metrics(
    start_time=datetime.now() - timedelta(days=7),
    metrics=["accuracy", "latency", "throughput"]
)

print(f"Model accuracy: {metrics['accuracy']:.2%}")
print(f"Average latency: {metrics['latency']}ms")
```

## Error Handling

### Exception Hierarchy

```python
from hexabase import Client
from hexabase.exceptions import (
    HexabaseError,
    AuthenticationError,
    AuthorizationError,
    ResourceNotFoundError,
    QuotaExceededError,
    ValidationError,
    ServerError
)

client = Client()

try:
    # Attempt operation
    app = client.applications.get("non-existent-id")
except ResourceNotFoundError as e:
    print(f"Application not found: {e}")
except AuthorizationError as e:
    print(f"Access denied: {e}")
except QuotaExceededError as e:
    print(f"Quota exceeded: {e}")
    print(f"Current usage: {e.current_usage}")
    print(f"Limit: {e.limit}")
except ValidationError as e:
    print(f"Invalid input: {e}")
    for error in e.errors:
        print(f"  - {error.field}: {error.message}")
except ServerError as e:
    print(f"Server error: {e}")
    print(f"Request ID: {e.request_id}")
except HexabaseError as e:
    print(f"Hexabase error: {e}")
```

### Retry Logic

```python
from hexabase import Client
from hexabase.retry import RetryPolicy, exponential_backoff

# Configure retry policy
retry_policy = RetryPolicy(
    max_attempts=5,
    backoff_strategy=exponential_backoff(base=2, max_delay=60),
    retry_on_exceptions=[ServerError, TimeoutError],
    retry_on_status_codes=[500, 502, 503, 504]
)

client = Client(retry_policy=retry_policy)

# Custom retry logic
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
def deploy_with_retry(client, app_config):
    return client.applications.create(**app_config)

# Use custom retry
app = deploy_with_retry(client, {
    "name": "resilient-app",
    "runtime": "python3.9"
})
```

## Testing

### Unit Testing

```python
import unittest
from unittest.mock import Mock, patch
from hexabase import Client
from hexabase.models import Application

class TestApplicationDeployment(unittest.TestCase):
    def setUp(self):
        self.client = Client(api_key="test-key")

    @patch('hexabase.client.requests')
    def test_create_application(self, mock_requests):
        # Mock API response
        mock_response = Mock()
        mock_response.json.return_value = {
            "id": "app-123",
            "name": "test-app",
            "status": "running"
        }
        mock_requests.post.return_value = mock_response

        # Create application
        app = self.client.applications.create(
            name="test-app",
            runtime="python3.9"
        )

        # Assert
        self.assertEqual(app.id, "app-123")
        self.assertEqual(app.name, "test-app")
        self.assertEqual(app.status, "running")

    def test_validation_error(self):
        with self.assertRaises(ValidationError):
            self.client.applications.create(
                name="",  # Empty name should fail
                runtime="python3.9"
            )

if __name__ == '__main__':
    unittest.main()
```

### Integration Testing

```python
import pytest
from hexabase import Client
from hexabase.testing import TestWorkspace

@pytest.fixture
def client():
    return Client(endpoint="https://api-test.hexabase.ai")

@pytest.fixture
def test_workspace(client):
    with TestWorkspace(client) as workspace:
        yield workspace

def test_full_deployment_cycle(client, test_workspace):
    # Create application
    app = test_workspace.applications.create(
        name="integration-test-app",
        runtime="python3.9",
        source_code="./test-app"
    )

    # Wait for deployment
    app.wait_until_ready(timeout=300)

    # Test application
    response = app.test_endpoint("/health")
    assert response.status_code == 200

    # Scale application
    app.scale(replicas=3)

    # Verify scaling
    status = app.get_status()
    assert status.replicas == 3

    # Cleanup happens automatically with TestWorkspace
```

## Performance Optimization

### Connection Pooling

```python
from hexabase import Client
from hexabase.pool import ConnectionPool

# Configure connection pool
pool = ConnectionPool(
    min_size=5,
    max_size=20,
    timeout=30,
    idle_time=300,
    retry_attempts=3
)

client = Client(connection_pool=pool)

# Pool automatically manages connections
workspaces = client.workspaces.list()

# Monitor pool statistics
stats = pool.get_stats()
print(f"Active connections: {stats.active}")
print(f"Idle connections: {stats.idle}")
print(f"Total connections: {stats.total}")
```

### Caching

```python
from hexabase import Client
from hexabase.cache import RedisCache
import redis

# Configure Redis cache
redis_client = redis.Redis(host='localhost', port=6379, db=0)
cache = RedisCache(
    redis_client=redis_client,
    ttl=300,  # 5 minutes
    prefix="hexabase:"
)

client = Client(cache=cache)

# First call hits API
workspaces1 = client.workspaces.list()

# Second call uses cache
workspaces2 = client.workspaces.list()

# Clear cache if needed
cache.clear()
```

## Best Practices

### Configuration Management

```python
# config.py
from hexabase import Config
import os

class Settings:
    def __init__(self):
        self.config = Config(
            api_key=os.getenv("HEXABASE_API_KEY"),
            endpoint=os.getenv("HEXABASE_ENDPOINT", "https://api.hexabase.ai"),
            timeout=int(os.getenv("HEXABASE_TIMEOUT", "30")),
            max_retries=int(os.getenv("HEXABASE_MAX_RETRIES", "3")),
            log_level=os.getenv("HEXABASE_LOG_LEVEL", "INFO")
        )

    @property
    def client(self):
        return Client(config=self.config)

# Usage
settings = Settings()
client = settings.client
```

### Logging

```python
import logging
from hexabase import Client

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Enable debug logging for SDK
logging.getLogger('hexabase').setLevel(logging.DEBUG)

client = Client()

# SDK logs all API calls and responses
app = client.applications.create(
    name="logged-app",
    runtime="python3.9"
)
```

### Resource Cleanup

```python
from contextlib import contextmanager
from hexabase import Client

@contextmanager
def temporary_resources(client):
    """Context manager for temporary resources"""
    resources = []

    try:
        yield resources
    finally:
        # Cleanup all resources
        for resource in reversed(resources):
            try:
                resource.delete()
                print(f"Deleted {resource.__class__.__name__}: {resource.id}")
            except Exception as e:
                print(f"Failed to delete {resource.id}: {e}")

# Usage
client = Client()

with temporary_resources(client) as resources:
    # Create temporary resources
    app = client.applications.create(name="temp-app", runtime="python3.9")
    resources.append(app)

    db = client.databases.create(name="temp-db", engine="postgresql")
    resources.append(db)

    # Use resources
    # ... do work ...

# Resources are automatically cleaned up
```

## Migration Guide

### Migrating from v1 to v2

```python
# v1 code
from hexabase_sdk import HexabaseClient

client = HexabaseClient("api-key")
apps = client.list_applications()

# v2 code
from hexabase import Client

client = Client(api_key="api-key")
apps = client.applications.list()

# Key differences:
# 1. Package name changed from hexabase_sdk to hexabase
# 2. Client class renamed from HexabaseClient to Client
# 3. Method naming changed from snake_case verbs to resource.action pattern
# 4. Async support added with AsyncClient
# 5. Enhanced type hints and IDE support
```

## Related Documentation

- [API Reference](../../api/index.md)
- [Node.js SDK](nodejs.md)
- [Go SDK](../../sdk/go.md)
- [CLI Reference](../../sdk/cli.md)
