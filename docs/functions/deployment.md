# Function Deployment

Once you have developed and tested your function locally, the next step is to deploy it to the Hexabase.AI platform. Deployment packages your code and dependencies, and makes your function available via a secure HTTP endpoint.

## Deployment Methods

You can deploy functions using two primary methods:

1.  **Using the HKS CLI**: The recommended method for automated, CI/CD-driven deployments.
2.  **Using the HKS UI**: A user-friendly, wizard-based approach for manual deployments.

## The `function.yaml` Manifest

The deployment of a function and its configuration are defined in a `function.yaml` manifest file. This file should be stored alongside your function code in version control.

```yaml
# function.yaml
apiVersion: hks.io/v1
kind: Function
metadata:
  name: my-hello-world-function
  # This function will be deployed to the 'development' workspace
  workspace: development
spec:
  # The function's source code details
  source:
    # Path to the directory containing your code and dependencies
    path: ./src

  # The runtime environment for the function
  runtime:
    name: python
    version: "3.9"

  # The entry point for the function
  handler: main.handler # (file.function_name)

  # Configuration for the HTTP endpoint
  trigger:
    type: http
    # The path where the function will be exposed
    path: /api/hello
    method: GET
    auth:
      # 'public' makes the endpoint available without authentication
      # 'token' would require a valid HKS JWT
      type: public

  # Resource allocation for the function
  resources:
    memory: 128Mi
    cpu: "100m"
    timeout: 30s # Function will time out after 30 seconds

  # Environment variables and secrets
  environment:
    variables:
      LOG_LEVEL: "debug"
    secrets:
      - name: MY_API_KEY
        secretName: external-service-key
        secretKey: api-key
```

## Deployment with the HKS CLI

The `hks function deploy` command reads your `function.yaml`, packages the source code directory, and deploys it to your workspace.

```bash
# Deploy the function defined in the current directory's function.yaml
hks function deploy
```

**What happens during deployment:**

1.  The CLI archives the source directory specified in `function.yaml`.
2.  It uploads the archive to the HKS build service.
3.  The build service creates a container image for your function:
    - It uses the specified runtime base image.
    - It installs any dependencies from `requirements.txt` or `package.json`.
    - It adds your function code to the image.
4.  The new function image is pushed to the secure, internal HKS container registry.
5.  The HKS FaaS (Function-as-a-Service) controller updates the function's configuration, pointing it to the new image.
6.  The HTTP endpoint is created or updated in the Function Gateway.

Subsequent deployments will create a new version of the function, and you can easily roll back to a previous version if needed.

```bash
# Roll back to the previous version of a function
hks function rollback my-hello-world-function
```

## CI/CD Integration

For a robust workflow, integrate function deployment into your CI/CD pipeline.

**Example GitLab CI Job:**

```yaml
deploy_function:
  stage: deploy
  image: hexabase/hks-cli:latest
  script:
    - echo "Deploying my-hello-world-function..."
    # The HKS_API_KEY for a service account should be stored as a secure CI/CD variable
    - hks function deploy --api-key $HKS_API_KEY
  rules:
    # Only run when changes are made in the function's source directory
    - changes:
        - functions/my-hello-world/**/*
```

## Viewing Deployment Status

You can check the status and details of your deployed functions at any time.

```bash
# List all functions in your current workspace
hks function list

# Get detailed information about a specific function, including its endpoint URL
hks function get my-hello-world-function

# View the real-time logs for a function
hks function logs -f my-hello-world-function
```

The HKS UI also provides a complete overview of all your deployed functions, their versions, invocation metrics, and logs.
