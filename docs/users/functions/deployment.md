# Function Deployment

This guide covers the deployment process for serverless functions on the Hexabase.AI platform, including configuration, optimization, and best practices.

## Deployment Methods

### 1. CLI Deployment

#### Quick Deploy

```bash
# Deploy a single function
hxb function deploy --name my-function --runtime nodejs18.x

# Deploy with configuration
hxb function deploy \
  --name my-function \
  --runtime python3.9 \
  --memory 512 \
  --timeout 30 \
  --env-file .env.production
```

#### Batch Deployment

```bash
# Deploy all functions in a directory
hxb function deploy-all --path ./functions

# Deploy with specific pattern
hxb function deploy-all --path ./functions --pattern "api-*"
```

### 2. UI Deployment

The Hexabase.AI console provides a visual deployment interface:

1. Navigate to **Functions** → **Deploy**
2. Upload your function code (ZIP or link to repository)
3. Configure runtime settings
4. Set environment variables
5. Review and deploy

### 3. GitOps Deployment

#### Function Configuration File

```yaml
# functions.yaml
functions:
  user-api:
    runtime: nodejs18.x
    handler: index.handler
    memory: 256
    timeout: 10
    environment:
      DATABASE_URL: ${secrets.database_url}
      API_KEY: ${secrets.api_key}
    triggers:
      - type: http
        path: /api/users/*
        methods: [GET, POST, PUT, DELETE]

  data-processor:
    runtime: python3.9
    handler: main.process
    memory: 1024
    timeout: 300
    layers:
      - arn:aws:lambda:layer:numpy-scipy:1
    triggers:
      - type: schedule
        expression: "rate(5 minutes)"
      - type: queue
        queue: data-processing-queue
```

#### Automated Deployment

```yaml
# .github/workflows/deploy-functions.yml
name: Deploy Functions

on:
  push:
    branches: [main]
    paths:
      - "functions/**"
      - "functions.yaml"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Hexabase CLI
        run: |
          curl -sL https://cli.hexabase.ai/install.sh | bash
          hxb auth login --token ${{ secrets.HXB_TOKEN }}

      - name: Validate Functions
        run: hxb function validate --config functions.yaml

      - name: Deploy Functions
        run: hxb function deploy-all --config functions.yaml --env production
```

## Deployment Configuration

### Runtime Configuration

#### Supported Runtimes

| Runtime | Version    | Features                            |
| ------- | ---------- | ----------------------------------- |
| Node.js | 18.x, 16.x | Full ES6+, native modules           |
| Python  | 3.9, 3.8   | Scientific libraries, ML frameworks |
| Go      | 1.19       | Fast cold starts, efficient memory  |
| Java    | 11, 8      | Enterprise frameworks               |
| .NET    | 6.0        | C#, F# support                      |
| Ruby    | 3.0        | Rails compatibility                 |

#### Runtime Selection

```javascript
// package.json for Node.js
{
  "name": "my-function",
  "version": "1.0.0",
  "main": "index.js",
  "engines": {
    "node": "18.x"
  },
  "dependencies": {
    "@hexabase/sdk": "^2.0.0"
  }
}
```

```python
# requirements.txt for Python
hexabase-sdk>=2.0.0
numpy==1.21.0
pandas==1.3.0
requests==2.26.0
```

### Resource Configuration

#### Memory and CPU Allocation

```yaml
# Plan-based limits
resources:
  single_user:
    memory_min: 128
    memory_max: 512
    cpu_shares: 0.25

  team:
    memory_min: 128
    memory_max: 2048
    cpu_shares: 1

  enterprise:
    memory_min: 128
    memory_max: 10240
    cpu_shares: 4
```

#### Function Sizing Guide

```javascript
// Memory configuration examples
const functionConfigs = {
  // Lightweight API endpoint
  minimal: {
    memory: 128,
    timeout: 10,
    use_cases: ["Simple API responses", "Webhooks"],
  },

  // Standard processing
  standard: {
    memory: 512,
    timeout: 30,
    use_cases: ["Data transformation", "API integrations"],
  },

  // Heavy processing
  intensive: {
    memory: 2048,
    timeout: 300,
    use_cases: ["Image processing", "ML inference", "Large data sets"],
  },
};
```

### Environment Configuration

#### Environment Variables

```bash
# Set via CLI
hxb function env set MY_FUNCTION \
  --var DATABASE_URL=postgres://... \
  --var API_KEY=secret123 \
  --encrypt API_KEY

# Set via configuration file
cat > function.env <<EOF
NODE_ENV=production
LOG_LEVEL=info
FEATURE_FLAGS={"newUI":true,"betaFeatures":false}
EOF

hxb function env import MY_FUNCTION --file function.env
```

#### Secrets Management

```yaml
# function-config.yaml
function:
  name: secure-function
  environment:
    # Plain text variables
    APP_NAME: MyApp
    LOG_LEVEL: info

    # Encrypted secrets
    DATABASE_URL:
      encrypted: true
      value: ${vault.database_url}

    API_KEY:
      encrypted: true
      value: ${vault.api_key}

    # Runtime injection
    AWS_ACCESS_KEY_ID:
      from_secret: aws-credentials
      key: access_key_id
```

## Deployment Strategies

### 1. Blue-Green Deployment

```yaml
deployment:
  strategy: blue-green
  settings:
    traffic_shift:
      type: gradual
      duration: 30m
      intervals:
        - weight: 10
          duration: 5m
        - weight: 50
          duration: 10m
        - weight: 100
          duration: 15m
    rollback:
      automatic: true
      error_threshold: 5%
```

### 2. Canary Deployment

```bash
# Deploy new version as canary
hxb function deploy my-function \
  --version v2 \
  --canary \
  --traffic 10

# Monitor metrics
hxb function metrics my-function --version v2

# Promote canary to production
hxb function promote my-function --version v2

# Or rollback
hxb function rollback my-function
```

### 3. Feature Flag Deployment

```javascript
// Function with feature flags
exports.handler = async (event) => {
  const features = await getFeatureFlags(event.userId);

  if (features.newAlgorithm) {
    return await newProcessingLogic(event);
  } else {
    return await legacyProcessingLogic(event);
  }
};
```

## Layer Management

### Creating Layers

```bash
# Create a layer for shared dependencies
mkdir nodejs
cd nodejs
npm install shared-utils aws-sdk moment
cd ..
zip -r shared-layer.zip nodejs

# Upload layer
hxb function layer create \
  --name shared-utils \
  --zip shared-layer.zip \
  --compatible-runtimes nodejs18.x nodejs16.x
```

### Using Layers

```yaml
function:
  name: api-handler
  runtime: nodejs18.x
  layers:
    - name: shared-utils
      version: 3
    - arn: arn:hexabase:layer:region:account:layer:name:version
```

## Trigger Configuration

### HTTP Triggers

```yaml
triggers:
  - type: http
    path: /api/v1/users/{userId}
    methods: [GET, PUT, DELETE]
    auth:
      type: jwt
      issuer: https://auth.hexabase.ai
    cors:
      origins: ["https://app.example.com"]
      credentials: true
    rate_limit:
      requests_per_second: 100
      burst: 200
```

### Event Triggers

```yaml
triggers:
  - type: event
    source: user-service
    events:
      - user.created
      - user.updated
    filters:
      - attribute: user.plan
        values: [premium, enterprise]

  - type: queue
    queue: processing-queue
    batch_size: 10
    visibility_timeout: 300
```

### Schedule Triggers

```yaml
triggers:
  - type: schedule
    expression: "cron(0 8 * * MON-FRI)"
    timezone: "America/New_York"
    input:
      type: "daily-report"
      recipients: ["team@example.com"]
```

## Monitoring Deployment

### Health Checks

```javascript
// Health check endpoint
exports.health = async (event) => {
  const checks = {
    function: "healthy",
    dependencies: await checkDependencies(),
    version: process.env.FUNCTION_VERSION,
  };

  return {
    statusCode: 200,
    body: JSON.stringify(checks),
  };
};
```

### Deployment Metrics

```yaml
# Monitor deployment
metrics:
  deployment:
    - success_rate
    - deployment_duration
    - rollback_count

  function:
    - invocation_count
    - error_rate
    - cold_start_duration
    - concurrent_executions
```

## Best Practices

### 1. Package Optimization

```javascript
// webpack.config.js for bundling
module.exports = {
  target: "node",
  mode: "production",
  entry: "./src/index.js",
  output: {
    filename: "index.js",
    libraryTarget: "commonjs2",
  },
  externals: {
    // Don't bundle AWS SDK (provided by runtime)
    "aws-sdk": "aws-sdk",
  },
  optimization: {
    minimize: true,
  },
};
```

### 2. Dependency Management

```json
// Separate dev and production dependencies
{
  "dependencies": {
    "express": "^4.18.0",
    "axios": "^0.27.0"
  },
  "devDependencies": {
    "jest": "^28.0.0",
    "eslint": "^8.0.0",
    "webpack": "^5.0.0"
  }
}
```

### 3. Version Management

```bash
# Tag versions
hxb function version create my-function \
  --tag v1.2.3 \
  --description "Added caching support"

# Deploy specific version
hxb function deploy my-function --version v1.2.3

# List versions
hxb function versions my-function
```

### 4. Rollback Strategy

```yaml
rollback:
  automatic:
    enabled: true
    conditions:
      - error_rate: 5%
        window: 5m
      - latency_p99: 1000ms
        window: 5m

  manual:
    preserve_data: true
    notification:
      channels: [slack, email]
```

## Troubleshooting Deployment

### Common Issues

1. **Deployment Timeout**

```bash
# Increase timeout for large functions
hxb function deploy my-function \
  --deployment-timeout 600 \
  --package-size-limit 250MB
```

2. **Permission Errors**

```bash
# Check and fix permissions
hxb function permissions my-function --check
hxb function permissions my-function --fix
```

3. **Package Size Issues**

```bash
# Use layers for large dependencies
hxb function analyze my-function --show-size

# Optimize package
npm prune --production
npm dedupe
```

### Deployment Logs

```bash
# View deployment logs
hxb function logs my-function --deployment

# Stream logs during deployment
hxb function deploy my-function --stream-logs

# Debug deployment
hxb function deploy my-function --debug --verbose
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/function-deploy.yml
name: Deploy Function

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Deploy to Hexabase
        uses: hexabase/function-deploy-action@v1
        with:
          function-name: ${{ github.event.repository.name }}
          runtime: nodejs18.x
          environment: production
          auth-token: ${{ secrets.HXB_DEPLOY_TOKEN }}
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - test
  - deploy

test:
  stage: test
  script:
    - npm install
    - npm test

deploy:
  stage: deploy
  only:
    - main
  script:
    - curl -sL https://cli.hexabase.ai/install.sh | bash
    - hxb auth login --token $HXB_DEPLOY_TOKEN
    - hxb function deploy --name $CI_PROJECT_NAME --env production
```

## Related Documentation

- [Function Development](development.md)
- [Function Runtime](runtime.md)
- [AI Agent Functions](ai-agent-functions.md)
- [CI/CD Integration](../../cicd/deployment-automation.md)
