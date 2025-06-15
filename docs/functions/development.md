# Function Development

Developing serverless functions in Hexabase.AI is designed to be a straightforward and familiar experience for developers. You can write functions in your preferred language, manage dependencies, and test locally before deploying.

## Supported Runtimes

Hexabase.AI provides managed, secure runtimes for several popular languages:

- **Node.js** (v18, v20)
- **Python** (v3.9, v3.11)
- **Go** (v1.21)

These runtimes are optimized for fast cold starts and include common libraries.

## Function Structure

A function is essentially a single file with a specific handler signature.

### Python Example

Your file (`main.py`) must contain a function named `handler`.

```python
# main.py
import json

def handler(event, context):
    """
    The main entry point for the function.

    :param event: A dictionary containing the request payload and headers.
    :param context: A dictionary containing runtime information (e.g., request ID).
    :return: A dictionary that will be serialized as the HTTP response.
    """

    # Get name from query parameter or request body
    name = "World"
    if event.get("queryStringParameters") and "name" in event["queryStringParameters"]:
        name = event["queryStringParameters"]["name"]
    elif event.get("body"):
        try:
            body = json.loads(event["body"])
            if "name" in body:
                name = body["name"]
        except json.JSONDecodeError:
            pass

    response_body = {
        "message": f"Hello, {name}!"
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(response_body)
    }
```

- **`event`**: Contains all the information about the HTTP request that triggered the function, including `httpMethod`, `path`, `headers`, `queryStringParameters`, and `body`.
- **`context`**: Provides information about the invocation, function, and execution environment.
- **Return Value**: The dictionary returned by the handler is transformed into an HTTP response. You must specify `statusCode`, `headers`, and a stringified `body`.

### Node.js Example

Your file (`index.js`) must export an `async` function named `handler`.

```javascript
// index.js
exports.handler = async (event, context) => {
  let name = "World";

  if (event.queryStringParameters && event.queryStringParameters.name) {
    name = event.queryStringParameters.name;
  } else if (event.body) {
    try {
      const body = JSON.parse(event.body);
      if (body.name) {
        name = body.name;
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }
  }

  const responseBody = {
    message: `Hello, ${name}!`,
  };

  const response = {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(responseBody),
  };

  return response;
};
```

## Managing Dependencies

### Python (`requirements.txt`)

For Python functions, you can specify third-party libraries by including a `requirements.txt` file in your function's directory.

```
# requirements.txt
requests==2.28.1
pyjwt>=2.0.0
```

When you deploy the function, HKS will automatically install these dependencies into the function's environment.

### Node.js (`package.json`)

For Node.js functions, include a `package.json` file.

```json
{
  "name": "my-hks-function",
  "version": "1.0.0",
  "dependencies": {
    "axios": "^1.4.0",
    "lodash": "^4.17.21"
  }
}
```

The HKS build process will run `npm install` to bundle the dependencies with your function.

## Local Development and Testing

You can develop and test your functions locally without needing to deploy them first. The HKS CLI provides a local invocation tool.

1.  **Write your function** (`main.py` or `index.js`) and its dependency file.
2.  **Run the local invoke command**:

    ```bash
    # For a Python function
    hks function invoke-local main.py --event sample-event.json

    # For a Node.js function
    hks function invoke-local index.js --event sample-event.json
    ```

3.  **Create a sample event file** (`sample-event.json`) to simulate an HTTP request:
    ```json
    {
      "httpMethod": "POST",
      "path": "/hello",
      "queryStringParameters": {
        "source": "local"
      },
      "body": "{\"name\": \"developer\"}"
    }
    ```

The `invoke-local` command runs your function in a local container that closely mimics the production HKS runtime environment, providing an accurate testing experience.

## Accessing Secrets and Environment Variables

Never hard-code sensitive information in your function code.

- **Environment Variables**: You can configure environment variables when you deploy your function.
- **Secrets**: For sensitive data like API keys or database passwords, mount them as environment variables from HKS Secrets.

When you deploy a function, you can specify environment variables and secret references in the UI or in your `function.yaml` file. These will be securely injected into the function's runtime environment.

```yaml
# In your function.yaml
---
spec:
  environment:
    variables:
      LOG_LEVEL: "info"
    secrets:
      - name: STRIPE_API_KEY
        secretName: payment-gateway-secret
        secretKey: api-key
```

Inside your function code, you can then access these as standard environment variables: `os.environ.get("LOG_LEVEL")` or `process.env.STRIPE_API_KEY`.
