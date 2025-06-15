# Function Development

This comprehensive guide covers developing serverless functions for the Hexabase.AI platform, including local development, testing, and best practices.

## Getting Started

### Development Environment Setup

#### Install Hexabase CLI

```bash
# macOS/Linux
curl -sL https://cli.hexabase.ai/install.sh | bash

# Windows
iwr -useb https://cli.hexabase.ai/install.ps1 | iex

# Verify installation
hxb --version
```

#### Initialize Project

```bash
# Create new function project
hxb function init my-function --runtime nodejs18.x

# Project structure created:
# my-function/
# ├── src/
# │   └── index.js
# ├── test/
# │   └── index.test.js
# ├── package.json
# ├── .env.example
# ├── .gitignore
# └── hexabase.yaml
```

### Function Structure

#### Node.js Function

```javascript
// src/index.js
const { Logger } = require("@hexabase/functions");

const logger = new Logger();

/**
 * Main handler function
 * @param {Object} event - The event object
 * @param {Object} context - The context object
 * @returns {Object} - Response object
 */
exports.handler = async (event, context) => {
  logger.info("Function invoked", {
    requestId: context.requestId,
    functionName: context.functionName,
  });

  try {
    // Your business logic here
    const result = await processRequest(event);

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "X-Request-ID": context.requestId,
      },
      body: JSON.stringify({
        success: true,
        data: result,
      }),
    };
  } catch (error) {
    logger.error("Function error", { error: error.message });

    return {
      statusCode: error.statusCode || 500,
      body: JSON.stringify({
        success: false,
        error: error.message,
      }),
    };
  }
};

async function processRequest(event) {
  // Implementation
  return { message: "Hello from Hexabase Function!" };
}
```

#### Python Function

```python
# src/main.py
import json
import logging
from hexabase.functions import Logger

logger = Logger()

def handler(event, context):
    """
    Main handler function

    Args:
        event (dict): The event object
        context (object): The context object

    Returns:
        dict: Response object
    """
    logger.info('Function invoked', {
        'request_id': context.request_id,
        'function_name': context.function_name
    })

    try:
        # Your business logic here
        result = process_request(event)

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'X-Request-ID': context.request_id
            },
            'body': json.dumps({
                'success': True,
                'data': result
            })
        }
    except Exception as error:
        logger.error('Function error', {'error': str(error)})

        return {
            'statusCode': getattr(error, 'status_code', 500),
            'body': json.dumps({
                'success': False,
                'error': str(error)
            })
        }

def process_request(event):
    # Implementation
    return {'message': 'Hello from Hexabase Function!'}
```

## Local Development

### Local Runtime Environment

#### Using Function Emulator

```bash
# Start local emulator
hxb function serve --port 3000

# In another terminal, invoke function
hxb function invoke my-function --local --data '{"name":"test"}'

# Or use curl
curl -X POST http://localhost:3000/functions/my-function \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}'
```

#### Docker Development

```dockerfile
# Dockerfile.dev
FROM hexabase/function-runtime:nodejs18.x

WORKDIR /function

# Copy dependencies
COPY package*.json ./
RUN npm ci

# Copy source
COPY src/ ./src/

# Development mode
ENV NODE_ENV=development
ENV LOG_LEVEL=debug

# Hot reload support
CMD ["npm", "run", "dev"]
```

```bash
# docker-compose.yml
version: '3.8'
services:
  function:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "9000:9000"
    volumes:
      - ./src:/function/src
      - ./test:/function/test
    environment:
      - LOCAL_DEVELOPMENT=true
      - AWS_LAMBDA_FUNCTION_NAME=my-function
    command: npm run watch
```

### Environment Variables

#### Local Configuration

```bash
# .env.local
NODE_ENV=development
LOG_LEVEL=debug
DATABASE_URL=postgres://localhost:5432/dev_db
API_KEY=dev_api_key_12345
FEATURE_FLAGS={"newFeature":true}
```

#### Loading Environment

```javascript
// src/config.js
const dotenv = require("dotenv");

// Load environment-specific config
const environment = process.env.NODE_ENV || "development";
dotenv.config({ path: `.env.${environment}` });

module.exports = {
  database: {
    url: process.env.DATABASE_URL,
    poolSize: parseInt(process.env.DB_POOL_SIZE || "10"),
  },
  api: {
    key: process.env.API_KEY,
    timeout: parseInt(process.env.API_TIMEOUT || "30000"),
  },
  features: JSON.parse(process.env.FEATURE_FLAGS || "{}"),
};
```

## Testing

### Unit Testing

#### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  testEnvironment: "node",
  coverageDirectory: "coverage",
  collectCoverageFrom: ["src/**/*.js", "!src/**/*.test.js"],
  testMatch: ["**/test/**/*.test.js"],
  setupFilesAfterEnv: ["./test/setup.js"],
};
```

#### Test Examples

```javascript
// test/handler.test.js
const { handler } = require("../src/index");

describe("Function Handler", () => {
  const mockContext = {
    requestId: "test-request-id",
    functionName: "my-function",
    getRemainingTimeInMillis: () => 30000,
  };

  test("should handle valid request", async () => {
    const event = {
      body: JSON.stringify({ name: "test" }),
      headers: { "content-type": "application/json" },
    };

    const response = await handler(event, mockContext);

    expect(response.statusCode).toBe(200);
    expect(JSON.parse(response.body)).toMatchObject({
      success: true,
      data: expect.any(Object),
    });
  });

  test("should handle errors gracefully", async () => {
    const event = {
      body: "invalid-json",
    };

    const response = await handler(event, mockContext);

    expect(response.statusCode).toBe(400);
    expect(JSON.parse(response.body)).toMatchObject({
      success: false,
      error: expect.any(String),
    });
  });
});
```

### Integration Testing

#### Test Harness

```javascript
// test/integration/api.test.js
const { FunctionTestHarness } = require("@hexabase/testing");

describe("API Integration", () => {
  let harness;

  beforeAll(async () => {
    harness = new FunctionTestHarness({
      functionName: "my-function",
      environment: {
        DATABASE_URL: "postgres://test:5432/test_db",
      },
    });
    await harness.start();
  });

  afterAll(async () => {
    await harness.stop();
  });

  test("should process API request", async () => {
    const response = await harness.invoke({
      path: "/api/users",
      method: "GET",
      headers: {
        Authorization: "Bearer test-token",
      },
    });

    expect(response.statusCode).toBe(200);
    expect(response.body).toHaveProperty("users");
  });
});
```

### Performance Testing

```javascript
// test/performance/load.test.js
const { PerformanceTest } = require("@hexabase/testing");

describe("Performance Tests", () => {
  test("should handle concurrent requests", async () => {
    const test = new PerformanceTest({
      function: "my-function",
      duration: 60, // seconds
      concurrency: 100,
      rampUp: 10,
    });

    const results = await test.run();

    expect(results.successRate).toBeGreaterThan(0.99);
    expect(results.p99Latency).toBeLessThan(1000);
    expect(results.throughput).toBeGreaterThan(500);
  });
});
```

## Advanced Development

### Middleware Pattern

```javascript
// src/middleware/auth.js
exports.authenticate = async (event) => {
  const token = event.headers.authorization?.replace("Bearer ", "");

  if (!token) {
    throw new UnauthorizedError("No token provided");
  }

  const user = await verifyToken(token);
  event.user = user;
  return event;
};

// src/middleware/validation.js
const Joi = require("joi");

exports.validate = (schema) => async (event) => {
  const body = JSON.parse(event.body || "{}");
  const { error, value } = schema.validate(body);

  if (error) {
    throw new ValidationError(error.details[0].message);
  }

  event.validatedBody = value;
  return event;
};

// src/index.js
const { compose } = require("@hexabase/functions");
const { authenticate } = require("./middleware/auth");
const { validate } = require("./middleware/validation");

const schema = Joi.object({
  name: Joi.string().required(),
  email: Joi.string().email().required(),
});

exports.handler = compose(
  authenticate,
  validate(schema),
  async (event, context) => {
    // Main handler with authenticated user and validated body
    const { user, validatedBody } = event;

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: `Hello ${user.name}`,
        data: validatedBody,
      }),
    };
  }
);
```

### Database Connections

```javascript
// src/db/connection.js
const { Pool } = require("pg");

let pool;

exports.getConnection = () => {
  if (!pool) {
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });

    // Handle cleanup
    process.on("SIGTERM", async () => {
      await pool.end();
    });
  }

  return pool;
};

// src/db/queries.js
const { getConnection } = require("./connection");

exports.getUser = async (userId) => {
  const pool = getConnection();
  const result = await pool.query("SELECT * FROM users WHERE id = $1", [
    userId,
  ]);
  return result.rows[0];
};

// Prepared statements for better performance
exports.createUser = async (userData) => {
  const pool = getConnection();
  const query = {
    name: "create-user",
    text: "INSERT INTO users(name, email) VALUES($1, $2) RETURNING *",
    values: [userData.name, userData.email],
  };
  const result = await pool.query(query);
  return result.rows[0];
};
```

### External API Integration

```javascript
// src/services/external-api.js
const axios = require("axios");
const CircuitBreaker = require("opossum");

class ExternalAPIService {
  constructor() {
    this.client = axios.create({
      baseURL: process.env.EXTERNAL_API_URL,
      timeout: 5000,
      headers: {
        "X-API-Key": process.env.EXTERNAL_API_KEY,
      },
    });

    // Circuit breaker configuration
    this.breaker = new CircuitBreaker(this.makeRequest.bind(this), {
      timeout: 3000,
      errorThresholdPercentage: 50,
      resetTimeout: 30000,
    });
  }

  async makeRequest(config) {
    return this.client.request(config);
  }

  async getResource(id) {
    try {
      const response = await this.breaker.fire({
        method: "GET",
        url: `/resources/${id}`,
      });
      return response.data;
    } catch (error) {
      if (error.code === "EOPENBREAKER") {
        // Circuit is open, use fallback
        return this.getFallbackResource(id);
      }
      throw error;
    }
  }

  getFallbackResource(id) {
    // Return cached or default data
    return { id, status: "fallback" };
  }
}

module.exports = new ExternalAPIService();
```

## Debugging

### Local Debugging

#### VS Code Configuration

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Function",
      "program": "${workspaceFolder}/node_modules/.bin/hxb",
      "args": ["function", "invoke", "my-function", "--local", "--debug"],
      "env": {
        "NODE_ENV": "development",
        "DEBUG": "*"
      },
      "console": "integratedTerminal"
    }
  ]
}
```

#### Remote Debugging

```bash
# Enable debug logs
hxb function update my-function --env LOG_LEVEL=debug

# View real-time logs
hxb function logs my-function --follow

# Get detailed error traces
hxb function logs my-function --filter ERROR --include-traces
```

### Monitoring Development

```javascript
// src/monitoring.js
const { Metrics } = require("@hexabase/functions");

const metrics = new Metrics();

// Custom metrics
exports.recordMetric = (name, value, unit = "Count") => {
  metrics.putMetric(name, value, unit);
};

// Performance tracking
exports.trackPerformance = async (operation, fn) => {
  const start = Date.now();
  try {
    const result = await fn();
    const duration = Date.now() - start;

    metrics.putMetric(`${operation}.duration`, duration, "Milliseconds");
    metrics.putMetric(`${operation}.success`, 1, "Count");

    return result;
  } catch (error) {
    const duration = Date.now() - start;

    metrics.putMetric(`${operation}.duration`, duration, "Milliseconds");
    metrics.putMetric(`${operation}.error`, 1, "Count");

    throw error;
  }
};
```

## Development Tools

### Code Generation

```bash
# Generate function from template
hxb function generate api-endpoint \
  --template rest-api \
  --method GET,POST \
  --path /users

# Generate test files
hxb function generate-tests my-function \
  --framework jest \
  --coverage 80
```

### Hot Reload Development

```javascript
// dev-server.js
const chokidar = require("chokidar");
const { spawn } = require("child_process");

let functionProcess;

function startFunction() {
  if (functionProcess) {
    functionProcess.kill();
  }

  functionProcess = spawn("hxb", ["function", "serve"], {
    stdio: "inherit",
  });
}

// Watch for changes
chokidar.watch("src/**/*.js").on("change", () => {
  console.log("Reloading function...");
  startFunction();
});

startFunction();
```

## Best Practices

### 1. Error Handling

```javascript
// src/errors.js
class ApplicationError extends Error {
  constructor(message, statusCode = 500, code = "INTERNAL_ERROR") {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

class ValidationError extends ApplicationError {
  constructor(message) {
    super(message, 400, "VALIDATION_ERROR");
  }
}

class NotFoundError extends ApplicationError {
  constructor(resource) {
    super(`${resource} not found`, 404, "NOT_FOUND");
  }
}

// Global error handler
exports.errorHandler = (fn) => async (event, context) => {
  try {
    return await fn(event, context);
  } catch (error) {
    console.error("Function error:", error);

    return {
      statusCode: error.statusCode || 500,
      body: JSON.stringify({
        error: {
          message: error.message,
          code: error.code || "INTERNAL_ERROR",
        },
      }),
    };
  }
};
```

### 2. Input Validation

```javascript
// src/validation.js
const validator = require("validator");

exports.validateEmail = (email) => {
  if (!validator.isEmail(email)) {
    throw new ValidationError("Invalid email format");
  }
  return validator.normalizeEmail(email);
};

exports.sanitizeInput = (input) => {
  if (typeof input === "string") {
    return validator.escape(input);
  }
  return input;
};
```

### 3. Performance Optimization

```javascript
// Reuse connections
const connections = new Map();

exports.getOptimizedConnection = (key, factory) => {
  if (!connections.has(key)) {
    connections.set(key, factory());
  }
  return connections.get(key);
};

// Lazy loading
let heavyModule;
exports.getHeavyModule = () => {
  if (!heavyModule) {
    heavyModule = require("heavy-computation-lib");
  }
  return heavyModule;
};
```

## Related Documentation

- [Function Deployment](deployment.md)
- [Function Runtime](runtime.md)
- [AI Agent Functions](ai-agent-functions.md)
- [SDK Documentation](../../sdk/javascript.md)
