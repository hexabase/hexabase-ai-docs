# Node.js SDK

This comprehensive guide covers the Hexabase.AI Node.js SDK, enabling seamless integration of Hexabase.AI services into your JavaScript and TypeScript applications.

## Installation

### Requirements

- Node.js 14.x or higher
- npm 6.x or yarn 1.x or higher
- TypeScript 4.x (optional, for TypeScript projects)

### Installation Methods

```bash
# Using npm
npm install @hexabase/sdk

# Using yarn
yarn add @hexabase/sdk

# Using pnpm
pnpm add @hexabase/sdk

# Install with additional features
npm install @hexabase/sdk @hexabase/monitoring @hexabase/ai
```

### TypeScript Setup

```bash
# Install TypeScript definitions
npm install --save-dev @types/node

# tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

## Quick Start

### Basic Usage

```javascript
const { HexabaseClient } = require("@hexabase/sdk");

// Initialize client
const client = new HexabaseClient({
  apiKey: "your-api-key",
  endpoint: "https://api.hexabase.ai",
});

// Or use environment variables
// process.env.HEXABASE_API_KEY = 'your-api-key'
// process.env.HEXABASE_ENDPOINT = 'https://api.hexabase.ai'
const client = new HexabaseClient();

// List workspaces
async function listWorkspaces() {
  const workspaces = await client.workspaces.list();
  workspaces.forEach((workspace) => {
    console.log(`Workspace: ${workspace.name} (ID: ${workspace.id})`);
  });
}

// Deploy application
async function deployApp() {
  const workspace = await client.workspaces.get("workspace-id");
  const app = await workspace.applications.create({
    name: "my-node-app",
    runtime: "nodejs18.x",
    sourceCode: "./app",
  });

  console.log(`Application deployed: ${app.id}`);
}
```

### TypeScript Usage

```typescript
import { HexabaseClient, Workspace, Application } from "@hexabase/sdk";

// Initialize typed client
const client = new HexabaseClient({
  apiKey: process.env.HEXABASE_API_KEY!,
  endpoint: "https://api.hexabase.ai",
});

// Type-safe operations
async function deployApplication(): Promise<Application> {
  const workspace: Workspace = await client.workspaces.get("workspace-id");

  const app = await workspace.applications.create({
    name: "typescript-app",
    runtime: "nodejs18.x",
    sourceCode: "./src",
    environmentVariables: {
      NODE_ENV: "production",
      API_KEY: process.env.API_KEY!,
    },
  });

  return app;
}

// Using async/await with error handling
async function main() {
  try {
    const app = await deployApplication();
    console.log(`Deployed: ${app.name}`);
  } catch (error) {
    console.error("Deployment failed:", error);
  }
}
```

## Authentication

### API Key Authentication

```javascript
const { HexabaseClient, APIKeyAuth } = require("@hexabase/sdk");

// Direct API key
const auth = new APIKeyAuth("your-api-key");
const client = new HexabaseClient({ auth });

// From environment variable
const auth = APIKeyAuth.fromEnv("HEXABASE_API_KEY");
const client = new HexabaseClient({ auth });

// From file
const auth = await APIKeyAuth.fromFile("~/.hexabase/credentials");
const client = new HexabaseClient({ auth });

// Rotating API keys
async function rotateApiKey() {
  const newKey = await client.auth.rotateApiKey();
  console.log("New API key:", newKey);

  // Update client with new key
  client.updateAuth(new APIKeyAuth(newKey));
}
```

### OAuth 2.0 Authentication

```javascript
const { HexabaseClient, OAuth2Auth } = require("@hexabase/sdk");

// Client credentials flow
const auth = new OAuth2Auth({
  clientId: "your-client-id",
  clientSecret: "your-client-secret",
  tokenUrl: "https://auth.hexabase.ai/oauth/token",
});

const client = new HexabaseClient({ auth });

// Authorization code flow (for web apps)
const express = require("express");
const app = express();

const auth = new OAuth2Auth({
  clientId: "your-client-id",
  redirectUri: "http://localhost:3000/callback",
  authorizationUrl: "https://auth.hexabase.ai/oauth/authorize",
});

// Redirect to authorization
app.get("/login", (req, res) => {
  const authUrl = auth.getAuthorizationUrl({
    scope: "read write",
    state: req.session.state,
  });
  res.redirect(authUrl);
});

// Handle callback
app.get("/callback", async (req, res) => {
  const { code } = req.query;
  await auth.exchangeCode(code);

  const client = new HexabaseClient({ auth });
  req.session.client = client;

  res.redirect("/dashboard");
});
```

### Service Account Authentication

```javascript
const { HexabaseClient, ServiceAccountAuth } = require("@hexabase/sdk");

// From JSON key file
const auth = await ServiceAccountAuth.fromFile("service-account-key.json");
const client = new HexabaseClient({ auth });

// From object
const auth = new ServiceAccountAuth({
  accountId: "sa-12345",
  privateKey: "-----BEGIN RSA PRIVATE KEY-----...",
  projectId: "my-project",
});

const client = new HexabaseClient({ auth });

// JWT assertion
const jwt = auth.createJWT({
  audience: "https://api.hexabase.ai",
  expiresIn: "1h",
});
```

## Core Features

### Workspace Management

```javascript
const { HexabaseClient } = require("@hexabase/sdk");

const client = new HexabaseClient();

// Create workspace
async function createWorkspace() {
  const workspace = await client.workspaces.create({
    name: "production",
    description: "Production environment",
    settings: {
      nodeType: "dedicated",
      region: "us-east-1",
      resourceLimits: {
        cpu: "16",
        memory: "64Gi",
        storage: "1Ti",
      },
    },
  });

  console.log("Workspace created:", workspace.id);
  return workspace;
}

// List and filter workspaces
async function listWorkspaces() {
  const workspaces = await client.workspaces.list({
    filter: {
      nodeType: "dedicated",
      region: "us-east-1",
    },
    sort: "created_at:desc",
    limit: 10,
  });

  return workspaces;
}

// Update workspace
async function updateWorkspace(workspaceId) {
  const workspace = await client.workspaces.get(workspaceId);

  await workspace.update({
    description: "Updated production environment",
    settings: {
      autoScaling: true,
      minNodes: 2,
      maxNodes: 10,
    },
  });

  // Monitor resources
  const resources = await workspace.getResources();
  console.log(`CPU Usage: ${resources.cpuUsage}%`);
  console.log(`Memory Usage: ${resources.memoryUsage}%`);
}
```

### Application Deployment

```javascript
const { HexabaseClient } = require("@hexabase/sdk");
const path = require("path");

const client = new HexabaseClient();

// Deploy from local source
async function deployFromSource() {
  const workspace = await client.workspaces.get("workspace-id");

  const app = await workspace.applications.create({
    name: "express-api",
    runtime: "nodejs18.x",
    sourceCode: path.join(__dirname, "./app"),
    entryPoint: "server.js",
    buildCommand: "npm install && npm run build",
    startCommand: "npm start",
    environmentVariables: {
      NODE_ENV: "production",
      PORT: "8080",
    },
    secrets: {
      DATABASE_URL: await client.secrets.get("db-url"),
      API_KEY: await client.secrets.get("api-key"),
    },
  });

  // Monitor deployment progress
  app.on("deploymentProgress", (progress) => {
    console.log(`Deployment progress: ${progress.percentage}%`);
    console.log(`Status: ${progress.status}`);
  });

  await app.waitUntilReady();
  console.log("Application deployed successfully!");

  return app;
}

// Deploy from Docker image
async function deployFromDocker() {
  const workspace = await client.workspaces.get("workspace-id");

  const app = await workspace.applications.create({
    name: "containerized-app",
    image: "myregistry/myapp:latest",
    ports: [8080, 9090],
    deploymentConfig: {
      replicas: 3,
      resources: {
        requests: {
          cpu: "500m",
          memory: "1Gi",
        },
        limits: {
          cpu: "2",
          memory: "4Gi",
        },
      },
      autoscaling: {
        enabled: true,
        minReplicas: 2,
        maxReplicas: 10,
        metrics: [
          {
            type: "cpu",
            targetAverageUtilization: 70,
          },
          {
            type: "memory",
            targetAverageUtilization: 80,
          },
        ],
      },
    },
  });

  return app;
}

// Blue-green deployment
async function blueGreenDeploy(appId, newVersion) {
  const app = await client.applications.get(appId);

  const deployment = await app.createDeployment({
    version: newVersion,
    strategy: "blue-green",
    config: {
      trafficSplitting: {
        blue: 100,
        green: 0,
      },
      healthCheck: {
        path: "/health",
        interval: 30,
        timeout: 10,
        unhealthyThreshold: 3,
      },
    },
  });

  // Test green environment
  const greenUrl = await deployment.getGreenUrl();
  const testResult = await testEndpoint(greenUrl);

  if (testResult.success) {
    // Switch traffic
    await deployment.switchTraffic({
      blue: 0,
      green: 100,
    });

    // Complete deployment
    await deployment.complete();
  } else {
    // Rollback
    await deployment.rollback();
  }
}
```

### Function Management

```javascript
const { HexabaseClient } = require("@hexabase/sdk");
const fs = require("fs").promises;

const client = new HexabaseClient();

// Create serverless function
async function createFunction() {
  const workspace = await client.workspaces.get("workspace-id");

  const functionCode = await fs.readFile("./functions/handler.js", "utf8");

  const func = await workspace.functions.create({
    name: "data-processor",
    runtime: "nodejs18.x",
    handler: "index.handler",
    code: functionCode,
    memory: 512,
    timeout: 300,
    environment: {
      PROCESSING_MODE: "batch",
      OUTPUT_BUCKET: "s3://processed-data",
    },
    layers: ["arn:aws:lambda:us-east-1:123456:layer:nodejs-utils:1"],
  });

  return func;
}

// Add triggers
async function addTriggers(functionId) {
  const func = await client.functions.get(functionId);

  // HTTP trigger
  const httpTrigger = await func.addTrigger({
    type: "http",
    config: {
      path: "/process",
      methods: ["POST", "PUT"],
      cors: {
        origins: ["https://app.example.com"],
        credentials: true,
      },
      auth: {
        type: "jwt",
        issuer: "https://auth.example.com",
      },
    },
  });

  // Schedule trigger
  const cronTrigger = await func.addTrigger({
    type: "schedule",
    config: {
      expression: "0 2 * * *", // Daily at 2 AM
      timezone: "America/New_York",
      enabled: true,
    },
  });

  // Event trigger
  const eventTrigger = await func.addTrigger({
    type: "event",
    config: {
      source: "hexabase.storage",
      events: ["object.created", "object.deleted"],
      filters: {
        bucket: "input-data",
        prefix: "raw/",
      },
    },
  });

  return { httpTrigger, cronTrigger, eventTrigger };
}

// Invoke function
async function invokeFunction(functionId) {
  const func = await client.functions.get(functionId);

  // Synchronous invocation
  const result = await func.invoke({
    payload: {
      action: "process",
      data: [1, 2, 3, 4, 5],
    },
    async: false,
  });

  console.log("Result:", result.output);
  console.log("Duration:", result.duration, "ms");
  console.log("Memory used:", result.memoryUsed, "MB");

  // Asynchronous invocation
  const asyncResult = await func.invoke({
    payload: { largeDataSet: true },
    async: true,
  });

  console.log("Invocation ID:", asyncResult.invocationId);

  // Check status
  const status = await func.getInvocation(asyncResult.invocationId);
  console.log("Status:", status.state);
}
```

### Stream Processing

```javascript
const { HexabaseClient } = require("@hexabase/sdk");

const client = new HexabaseClient();

// Event streaming
async function streamEvents() {
  const eventStream = await client.events.stream({
    workspaceId: "workspace-id",
    eventTypes: ["deployment.*", "application.*", "function.*"],
    filters: {
      severity: ["error", "warning"],
      environment: "production",
    },
  });

  eventStream.on("event", (event) => {
    console.log(`Event: ${event.type}`);
    console.log(`Resource: ${event.resourceId}`);
    console.log(`Details:`, event.data);

    // Process event
    processEvent(event);
  });

  eventStream.on("error", (error) => {
    console.error("Stream error:", error);
  });

  // Start streaming
  await eventStream.start();

  // Stop after some time
  setTimeout(async () => {
    await eventStream.stop();
  }, 3600000); // 1 hour
}

// Log streaming
async function streamLogs(appId) {
  const app = await client.applications.get(appId);

  const logStream = await app.streamLogs({
    container: "main",
    since: "10m",
    filter: {
      level: ["error", "warn"],
      pattern: /database|connection/i,
    },
  });

  logStream.on("log", (log) => {
    console.log(`[${log.timestamp}] ${log.level}: ${log.message}`);

    // Alert on errors
    if (log.level === "error") {
      sendAlert(log);
    }
  });

  await logStream.start();
}
```

## Advanced Features

### Batch Operations

```javascript
const { HexabaseClient, BatchOperation } = require("@hexabase/sdk");

const client = new HexabaseClient();

// Batch deployment
async function batchDeploy() {
  const batch = new BatchOperation(client);

  const apps = [
    {
      name: "api-service",
      runtime: "nodejs18.x",
      sourceCode: "./services/api",
    },
    {
      name: "worker-service",
      runtime: "nodejs18.x",
      sourceCode: "./services/worker",
    },
    { name: "frontend", runtime: "static", sourceCode: "./frontend/dist" },
  ];

  // Add operations to batch
  apps.forEach((app) => {
    batch.add("createApplication", {
      workspaceId: "workspace-id",
      ...app,
    });
  });

  // Execute batch
  const results = await batch.execute({
    parallel: true,
    stopOnError: false,
  });

  // Process results
  results.forEach((result, index) => {
    if (result.success) {
      console.log(`✅ Deployed ${apps[index].name}: ${result.data.id}`);
    } else {
      console.error(`❌ Failed ${apps[index].name}: ${result.error.message}`);
    }
  });

  return results.filter((r) => r.success).map((r) => r.data);
}

// Transaction support
async function transactionalUpdate() {
  const transaction = await client.beginTransaction();

  try {
    // Create resources within transaction
    const app = await transaction.applications.create({
      name: "transactional-app",
      runtime: "nodejs18.x",
    });

    const db = await transaction.databases.create({
      name: "app-database",
      engine: "postgresql",
      linkedTo: app.id,
    });

    const secret = await transaction.secrets.create({
      name: "db-connection",
      value: db.connectionString,
    });

    // Commit all changes
    await transaction.commit();

    console.log("Transaction completed successfully");
  } catch (error) {
    // Rollback on error
    await transaction.rollback();
    console.error("Transaction failed:", error);
  }
}
```

### Monitoring and Observability

```javascript
const { HexabaseClient, MetricsClient } = require("@hexabase/sdk");

const client = new HexabaseClient();
const metrics = new MetricsClient(client);

// Query metrics
async function queryMetrics() {
  const cpuMetrics = await metrics.query({
    metric: "node_cpu_usage_percent",
    workspace: "workspace-id",
    timeRange: {
      start: new Date(Date.now() - 3600000), // 1 hour ago
      end: new Date(),
    },
    aggregation: "avg",
    groupBy: ["node_id"],
    interval: "5m",
  });

  // Process metrics
  cpuMetrics.series.forEach((series) => {
    console.log(`Node ${series.labels.node_id}:`);
    series.points.forEach((point) => {
      console.log(`  ${point.timestamp}: ${point.value.toFixed(2)}%`);
    });
  });

  // Create custom metrics
  await metrics.record({
    name: "custom_api_latency",
    value: 125.5,
    labels: {
      endpoint: "/api/users",
      method: "GET",
      status: "200",
    },
    timestamp: new Date(),
  });
}

// Real-time monitoring
async function setupMonitoring(appId) {
  const app = await client.applications.get(appId);

  const monitor = await app.createMonitor({
    metrics: ["cpu", "memory", "requests", "errors"],
    interval: 30, // seconds
    alerts: [
      {
        metric: "cpu",
        condition: "avg > 80",
        duration: "5m",
        actions: ["email", "slack"],
      },
      {
        metric: "errors",
        condition: "rate > 10",
        duration: "1m",
        actions: ["pagerduty"],
      },
    ],
  });

  monitor.on("alert", (alert) => {
    console.log(`Alert triggered: ${alert.metric}`);
    console.log(`Condition: ${alert.condition}`);
    console.log(`Current value: ${alert.currentValue}`);
  });

  await monitor.start();
}

// Distributed tracing
async function setupTracing() {
  const { TracingClient } = require("@hexabase/monitoring");

  const tracing = new TracingClient(client);

  // Configure tracing
  await tracing.configure({
    serviceName: "my-api",
    samplingRate: 0.1, // 10% of requests
    exporters: ["jaeger", "hexabase"],
  });

  // Instrument code
  const span = tracing.startSpan("process-request");

  try {
    // Your code here
    span.setAttribute("user.id", userId);
    span.setAttribute("request.method", "GET");

    const childSpan = tracing.startSpan("database-query", { parent: span });
    // Database operation
    childSpan.end();

    span.setStatus({ code: "OK" });
  } catch (error) {
    span.setStatus({ code: "ERROR", message: error.message });
    span.recordException(error);
  } finally {
    span.end();
  }
}
```

### AI/ML Integration

```javascript
const { HexabaseClient, AIClient } = require("@hexabase/sdk");

const client = new HexabaseClient();
const ai = new AIClient(client);

// Deploy ML model
async function deployModel() {
  const model = await ai.models.deploy({
    name: "sentiment-analyzer",
    framework: "tensorflow",
    modelFile: "./models/sentiment_model.json",
    weightsFile: "./models/sentiment_weights.bin",
    preprocessing: "./preprocessing.js",
    postprocessing: "./postprocessing.js",
  });

  // Create prediction endpoint
  const endpoint = await model.createEndpoint({
    name: "sentiment-api",
    instanceType: "ml.m5.large",
    autoscaling: {
      minInstances: 1,
      maxInstances: 10,
      targetRequestsPerInstance: 100,
    },
  });

  return endpoint;
}

// Make predictions
async function predict(endpointId, texts) {
  const endpoint = await ai.endpoints.get(endpointId);

  // Single prediction
  const result = await endpoint.predict({
    text: "This product is amazing!",
  });

  console.log("Sentiment:", result.sentiment);
  console.log("Confidence:", result.confidence);

  // Batch prediction
  const batchResults = await endpoint.batchPredict(
    texts.map((text) => ({ text }))
  );

  batchResults.forEach((result, index) => {
    console.log(`${texts[index]}: ${result.sentiment} (${result.confidence})`);
  });
}

// Fine-tune model
async function fineTuneModel(modelId) {
  const model = await ai.models.get(modelId);

  const fineTuneJob = await model.fineTune({
    trainingData: "./data/training.jsonl",
    validationData: "./data/validation.jsonl",
    hyperparameters: {
      epochs: 10,
      batchSize: 32,
      learningRate: 0.001,
    },
    callbacks: {
      onEpochEnd: (epoch, metrics) => {
        console.log(
          `Epoch ${epoch}: Loss=${metrics.loss}, Accuracy=${metrics.accuracy}`
        );
      },
    },
  });

  await fineTuneJob.waitUntilComplete();

  const newModel = await fineTuneJob.getModel();
  console.log("Fine-tuned model:", newModel.id);
}
```

## Error Handling

### Error Types and Handling

```javascript
const {
  HexabaseClient,
  HexabaseError,
  AuthenticationError,
  AuthorizationError,
  ResourceNotFoundError,
  QuotaExceededError,
  ValidationError,
  ServerError,
} = require("@hexabase/sdk");

const client = new HexabaseClient();

// Comprehensive error handling
async function robustOperation() {
  try {
    const app = await client.applications.get("app-id");
    await app.scale(10);
  } catch (error) {
    if (error instanceof ResourceNotFoundError) {
      console.error("Application not found:", error.resourceId);
    } else if (error instanceof AuthorizationError) {
      console.error("Access denied:", error.message);
      console.error("Required permissions:", error.requiredPermissions);
    } else if (error instanceof QuotaExceededError) {
      console.error("Quota exceeded:", error.quotaType);
      console.error("Current usage:", error.currentUsage);
      console.error("Limit:", error.limit);
    } else if (error instanceof ValidationError) {
      console.error("Validation failed:");
      error.errors.forEach((err) => {
        console.error(`  ${err.field}: ${err.message}`);
      });
    } else if (error instanceof ServerError) {
      console.error("Server error:", error.message);
      console.error("Request ID:", error.requestId);
      console.error("Status code:", error.statusCode);
    } else if (error instanceof HexabaseError) {
      console.error("Hexabase error:", error.message);
    } else {
      console.error("Unexpected error:", error);
    }
  }
}

// Retry with exponential backoff
async function retryOperation(operation, maxRetries = 3) {
  const { retry } = require("@hexabase/sdk/utils");

  return retry(operation, {
    retries: maxRetries,
    factor: 2,
    minTimeout: 1000,
    maxTimeout: 30000,
    randomize: true,
    onRetry: (error, attempt) => {
      console.log(`Retry attempt ${attempt} after error:`, error.message);
    },
    retryIf: (error) => {
      return (
        error instanceof ServerError ||
        error.code === "ETIMEDOUT" ||
        error.statusCode >= 500
      );
    },
  });
}
```

## Testing

### Unit Testing

```javascript
const { HexabaseClient } = require("@hexabase/sdk");
const { MockClient } = require("@hexabase/sdk/testing");
const assert = require("assert");

describe("Application Deployment", () => {
  let client;

  beforeEach(() => {
    client = new MockClient();
  });

  it("should deploy application successfully", async () => {
    // Setup mock
    client.mockWorkspace("workspace-id", {
      name: "test-workspace",
    });

    client.mockApplicationCreation({
      name: "test-app",
      id: "app-123",
      status: "running",
    });

    // Test deployment
    const workspace = await client.workspaces.get("workspace-id");
    const app = await workspace.applications.create({
      name: "test-app",
      runtime: "nodejs18.x",
    });

    // Assertions
    assert.strictEqual(app.id, "app-123");
    assert.strictEqual(app.status, "running");
    assert.strictEqual(client.calls.createApplication, 1);
  });

  it("should handle deployment failure", async () => {
    client.mockApplicationCreationFailure(
      new ValidationError("Invalid runtime")
    );

    const workspace = await client.workspaces.get("workspace-id");

    await assert.rejects(
      () => workspace.applications.create({ name: "test-app" }),
      ValidationError
    );
  });
});
```

### Integration Testing

```javascript
const { HexabaseClient } = require("@hexabase/sdk");
const { TestEnvironment } = require("@hexabase/sdk/testing");

describe("Integration Tests", () => {
  let env;
  let client;

  beforeAll(async () => {
    env = await TestEnvironment.create({
      isolateWorkspace: true,
      cleanup: true,
    });

    client = new HexabaseClient({
      apiKey: env.apiKey,
      endpoint: env.endpoint,
    });
  });

  afterAll(async () => {
    await env.cleanup();
  });

  test("full deployment lifecycle", async () => {
    // Create application
    const app = await env.workspace.applications.create({
      name: "integration-test-app",
      runtime: "nodejs18.x",
      sourceCode: "./test-fixtures/sample-app",
    });

    // Wait for deployment
    await app.waitUntilReady({ timeout: 300000 });

    // Test application
    const response = await app.testEndpoint("/health");
    expect(response.status).toBe(200);
    expect(response.data).toEqual({ status: "healthy" });

    // Scale application
    await app.scale(3);

    // Verify scaling
    const status = await app.getStatus();
    expect(status.replicas).toBe(3);
  });
});
```

## Performance Optimization

### Connection Pooling

```javascript
const { HexabaseClient, ConnectionPool } = require("@hexabase/sdk");

// Configure connection pool
const pool = new ConnectionPool({
  minConnections: 5,
  maxConnections: 20,
  idleTimeout: 300000, // 5 minutes
  acquireTimeout: 30000, // 30 seconds
  createRetries: 3,
});

const client = new HexabaseClient({
  connectionPool: pool,
});

// Monitor pool statistics
setInterval(() => {
  const stats = pool.getStatistics();
  console.log("Pool statistics:", {
    active: stats.activeConnections,
    idle: stats.idleConnections,
    pending: stats.pendingRequests,
    total: stats.totalConnections,
  });
}, 60000);

// Graceful shutdown
process.on("SIGTERM", async () => {
  await pool.drain();
  await pool.close();
  process.exit(0);
});
```

### Caching

```javascript
const { HexabaseClient } = require("@hexabase/sdk");
const { RedisCache } = require("@hexabase/sdk/cache");
const Redis = require("ioredis");

// Configure Redis cache
const redis = new Redis({
  host: "localhost",
  port: 6379,
  db: 0,
});

const cache = new RedisCache({
  client: redis,
  prefix: "hexabase:",
  ttl: 300, // 5 minutes
  compression: true,
});

const client = new HexabaseClient({
  cache: cache,
});

// Cached operations
async function getCachedWorkspaces() {
  // First call hits API
  const workspaces1 = await client.workspaces.list();

  // Subsequent calls use cache
  const workspaces2 = await client.workspaces.list();

  // Force cache refresh
  const workspaces3 = await client.workspaces.list({
    cache: false,
  });

  // Clear specific cache
  await cache.delete("workspaces:list");

  // Clear all cache
  await cache.flush();
}
```

## Best Practices

### Project Structure

```
my-hexabase-app/
├── src/
│   ├── config/
│   │   ├── index.js
│   │   └── environments/
│   │       ├── development.js
│   │       ├── staging.js
│   │       └── production.js
│   ├── services/
│   │   ├── hexabase.js
│   │   └── deployment.js
│   ├── utils/
│   │   └── logger.js
│   └── index.js
├── test/
│   ├── unit/
│   └── integration/
├── .env.example
├── .eslintrc.js
├── package.json
└── README.md
```

### Configuration Management

```javascript
// config/index.js
const convict = require("convict");

const config = convict({
  env: {
    doc: "The application environment",
    format: ["production", "development", "staging", "test"],
    default: "development",
    env: "NODE_ENV",
  },
  hexabase: {
    apiKey: {
      doc: "Hexabase API key",
      format: String,
      default: "",
      env: "HEXABASE_API_KEY",
      sensitive: true,
    },
    endpoint: {
      doc: "Hexabase API endpoint",
      format: "url",
      default: "https://api.hexabase.ai",
      env: "HEXABASE_ENDPOINT",
    },
    timeout: {
      doc: "Request timeout in milliseconds",
      format: "nat",
      default: 30000,
      env: "HEXABASE_TIMEOUT",
    },
  },
});

// Load environment-specific config
const env = config.get("env");
config.loadFile(`./config/environments/${env}.js`);
config.validate({ allowed: "strict" });

module.exports = config;
```

### Logging and Debugging

```javascript
const { HexabaseClient } = require("@hexabase/sdk");
const winston = require("winston");

// Configure logging
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: "hexabase.log" }),
  ],
});

// Enable SDK debugging
const client = new HexabaseClient({
  debug: true,
  logger: logger,
});

// Log all API calls
client.on("request", (req) => {
  logger.info("API Request", {
    method: req.method,
    url: req.url,
    headers: req.headers,
  });
});

client.on("response", (res) => {
  logger.info("API Response", {
    status: res.status,
    headers: res.headers,
    duration: res.duration,
  });
});
```

## Migration Guide

### Migrating from v1 to v2

```javascript
// v1 code
const HexabaseSDK = require("hexabase-sdk");
const sdk = new HexabaseSDK("api-key");

sdk.listApplications((err, apps) => {
  if (err) throw err;
  console.log(apps);
});

// v2 code
const { HexabaseClient } = require("@hexabase/sdk");
const client = new HexabaseClient({ apiKey: "api-key" });

// Promise-based API
const apps = await client.applications.list();
console.log(apps);

// Or with async/await error handling
try {
  const apps = await client.applications.list();
  console.log(apps);
} catch (error) {
  console.error("Failed to list applications:", error);
}

// Key changes:
// 1. Package name: hexabase-sdk → @hexabase/sdk
// 2. Constructor: HexabaseSDK → HexabaseClient
// 3. Callbacks → Promises/async-await
// 4. Flat methods → Resource-based methods
// 5. Better TypeScript support
```

## Related Documentation

- [API Reference](../../api/index.md)
- [Python SDK](python.md)
- [Go SDK](../../sdk/go.md)
- [CLI Reference](../../sdk/cli.md)
