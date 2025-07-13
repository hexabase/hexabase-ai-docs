# Pipeline Configuration

Configure powerful CI/CD pipelines in Hexabase.AI to automate your application build, test, and deployment workflows.

## Overview

Hexabase.AI provides a flexible pipeline system that integrates with your existing Git repositories and follows GitOps principles. Pipelines are defined using YAML configuration files and support multiple stages, parallel execution, and conditional logic.

## Pipeline Structure

### Basic Pipeline Configuration

Create a `.hexabase/pipeline.yml` file in your repository:

```yaml
apiVersion: cicd.hexabase.ai/v1
kind: Pipeline
metadata:
  name: my-app-pipeline
  workspace: production
spec:
  triggers:
    - type: push
      branches: [main, develop]
    - type: pull_request
      branches: [main]
  
  stages:
    - name: build
      jobs:
        - name: build-app
          image: node:18
          commands:
            - npm install
            - npm run build
            - npm test
          
    - name: deploy
      jobs:
        - name: deploy-to-k8s
          when: branch == 'main'
          commands:
            - hb deploy --manifest k8s/
```

## Pipeline Components

### Triggers

Define when pipelines should run:

```yaml
triggers:
  # Git push trigger
  - type: push
    branches: [main, develop, feature/*]
    
  # Pull request trigger
  - type: pull_request
    branches: [main]
    
  # Schedule trigger (cron)
  - type: schedule
    cron: "0 2 * * *"  # Daily at 2 AM
    
  # Manual trigger
  - type: manual
```

### Stages and Jobs

Organize your pipeline into logical stages:

```yaml
stages:
  - name: test
    jobs:
      # Parallel jobs
      - name: unit-tests
        image: golang:1.21
        commands:
          - go test ./...
          
      - name: lint
        image: golangci/golangci-lint
        commands:
          - golangci-lint run
          
  - name: build
    # Sequential execution after test stage
    dependsOn: [test]
    jobs:
      - name: docker-build
        commands:
          - docker build -t myapp:${GIT_COMMIT} .
          - docker push registry.hexabase.ai/myapp:${GIT_COMMIT}
```

### Environment Variables

#### Built-in Variables

Available in all pipeline runs:

- `${GIT_COMMIT}` - Git commit SHA
- `${GIT_BRANCH}` - Current branch name
- `${GIT_TAG}` - Git tag (if applicable)
- `${WORKSPACE}` - Current workspace
- `${PROJECT}` - Current project name
- `${BUILD_ID}` - Unique build identifier

#### Custom Variables

Define custom environment variables:

```yaml
env:
  global:
    - NODE_ENV=production
    - API_VERSION=v2
    
stages:
  - name: build
    env:
      - BUILD_TARGET=production
    jobs:
      - name: compile
        env:
          - OPTIMIZATION_LEVEL=3
```

### Secrets Management

Access secrets securely in pipelines:

```yaml
stages:
  - name: deploy
    secrets:
      - name: docker-registry
        keys: [username, password]
      - name: api-keys
        keys: [stripe-key, sendgrid-key]
    jobs:
      - name: push-image
        commands:
          # Secrets available as environment variables
          - docker login -u $DOCKER_REGISTRY_USERNAME -p $DOCKER_REGISTRY_PASSWORD
```

## Advanced Features

### Conditional Execution

Control job execution with conditions:

```yaml
jobs:
  - name: deploy-prod
    when: branch == 'main' && tag =~ /^v\d+\.\d+\.\d+$/
    
  - name: deploy-staging
    when: branch == 'develop'
    
  - name: security-scan
    when: pullRequest.labels contains 'security'
```

### Matrix Builds

Test across multiple configurations:

```yaml
stages:
  - name: test
    strategy:
      matrix:
        node_version: [16, 18, 20]
        os: [ubuntu, alpine]
    jobs:
      - name: test-matrix
        image: node:${{ matrix.node_version }}-${{ matrix.os }}
        commands:
          - npm test
```

### Artifacts

Share data between stages:

```yaml
stages:
  - name: build
    jobs:
      - name: compile
        commands:
          - npm run build
        artifacts:
          paths:
            - dist/
            - build/
          expire: 7d
          
  - name: deploy
    jobs:
      - name: upload
        commands:
          # Artifacts from build stage available
          - aws s3 sync dist/ s3://my-bucket/
```

### Caching

Speed up builds with caching:

```yaml
cache:
  paths:
    - node_modules/
    - .npm/
    - vendor/
  key: ${GIT_BRANCH}-${CHECKSUM("package-lock.json")}
```

## Pipeline Templates

### Reusable Templates

Create template pipelines:

```yaml
# .hexabase/templates/node-app.yml
apiVersion: cicd.hexabase.ai/v1
kind: PipelineTemplate
metadata:
  name: node-app-template
spec:
  parameters:
    - name: nodeVersion
      default: "18"
  stages:
    - name: test
      jobs:
        - name: test
          image: node:{{ .nodeVersion }}
          commands:
            - npm install
            - npm test
```

Use templates in pipelines:

```yaml
apiVersion: cicd.hexabase.ai/v1
kind: Pipeline
metadata:
  name: my-app
spec:
  extends:
    template: node-app-template
    parameters:
      nodeVersion: "20"
  stages:
    # Additional stages
    - name: deploy
      jobs:
        - name: deploy
          commands:
            - hb deploy
```

## Integration with Hexabase Features

### Automatic Kubernetes Deployment

```yaml
stages:
  - name: deploy
    jobs:
      - name: k8s-deploy
        type: kubernetes  # Special job type
        config:
          manifest: k8s/deployment.yaml
          namespace: production
          strategy: rolling
          healthCheck:
            enabled: true
            timeout: 300s
```

### Function Deployment

Deploy serverless functions:

```yaml
stages:
  - name: deploy-functions
    jobs:
      - name: function-deploy
        type: function
        config:
          source: ./functions/
          runtime: node18
          triggers:
            - http:
                path: /api/webhook
                method: POST
```

## Monitoring and Notifications

### Pipeline Notifications

Configure notifications for pipeline events:

```yaml
notifications:
  - type: slack
    webhook: ${SLACK_WEBHOOK}
    events: [failure, success]
    channels: ["#deployments"]
    
  - type: email
    recipients: ["team@example.com"]
    events: [failure]
```

### Pipeline Metrics

Monitor pipeline performance:

- Build duration trends
- Success/failure rates
- Queue wait times
- Resource utilization

## Best Practices

1. **Version Control**: Keep pipeline configs in version control
2. **Modular Stages**: Break complex pipelines into logical stages
3. **Fail Fast**: Run tests early in the pipeline
4. **Parallel Execution**: Run independent jobs in parallel
5. **Cache Dependencies**: Use caching to speed up builds
6. **Security Scanning**: Include security checks in pipelines
7. **Environment Parity**: Keep staging and production pipelines similar

## Troubleshooting

### Common Issues

**Pipeline Not Triggering**
- Verify branch patterns match
- Check webhook configuration
- Review trigger conditions

**Build Failures**
- Check build logs: `hb pipeline logs <build-id>`
- Verify image availability
- Check resource limits

**Slow Builds**
- Enable caching
- Use smaller base images
- Parallelize test execution

### Debugging

Enable debug mode for detailed logs:

```yaml
debug:
  enabled: true
  verbose: true
```

View pipeline execution:

```bash
# List recent pipeline runs
hb pipeline list

# Get pipeline details
hb pipeline get <pipeline-id>

# Stream logs
hb pipeline logs -f <build-id>
```