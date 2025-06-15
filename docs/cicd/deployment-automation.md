# Deployment Automation

Hexabase.AI provides comprehensive deployment automation capabilities that streamline the process of deploying applications to Kubernetes clusters.

## Overview

Deployment automation in Hexabase.AI handles:

- Automatic rollouts with health checks
- Blue-green and canary deployments
- Rollback capabilities
- Multi-environment deployments
- GitOps integration

## Deployment Strategies

### 1. Rolling Updates

The default deployment strategy with zero-downtime updates:

```yaml
deploy:
  strategy: rolling
  config:
    maxSurge: 25%
    maxUnavailable: 0
    healthCheck:
      enabled: true
      path: /health
      interval: 10s
      timeout: 5s
      successThreshold: 3
```

### 2. Blue-Green Deployments

Deploy to a parallel environment before switching traffic:

```yaml
deploy:
  strategy: blue-green
  config:
    preDeploymentTests:
      enabled: true
      tests:
        - smoke-tests
        - integration-tests
    trafficSwitch:
      mode: instant # or gradual
      validation:
        duration: 5m
        rollbackOnError: true
```

### 3. Canary Deployments

Gradually roll out changes to a subset of users:

```yaml
deploy:
  strategy: canary
  config:
    steps:
      - weight: 10
        pause: 5m
        analysis:
          metrics:
            - error-rate < 1%
            - latency-p99 < 500ms
      - weight: 50
        pause: 10m
      - weight: 100
    rollback:
      automatic: true
      threshold:
        errorRate: 5%
```

## Automated Deployment Pipeline

### Basic Configuration

```yaml
# .hks/deploy.yaml
stages:
  - name: validate
    jobs:
      - name: lint
        commands:
          - hks validate deployment.yaml
          - hks validate service.yaml

  - name: deploy-staging
    jobs:
      - name: deploy
        environment: staging
        commands:
          - hks deploy --environment staging
          - hks wait --for condition=ready

  - name: test
    jobs:
      - name: smoke-tests
        commands:
          - npm run test:smoke

  - name: deploy-production
    when: manual
    jobs:
      - name: deploy
        environment: production
        commands:
          - hks deploy --environment production --strategy canary
```

### Environment-Specific Deployments

```yaml
environments:
  development:
    autoSync: true
    namespace: dev
    values:
      replicas: 1
      resources:
        requests:
          memory: 256Mi
          cpu: 100m

  staging:
    namespace: staging
    values:
      replicas: 2
      ingress:
        enabled: true
        host: staging.myapp.com

  production:
    namespace: prod
    approval:
      required: true
      approvers: ["sre-team", "platform-team"]
    values:
      replicas: 3
      autoscaling:
        enabled: true
        minReplicas: 3
        maxReplicas: 10
```

## GitOps Integration

### ArgoCD Integration

```yaml
gitops:
  provider: argocd
  config:
    repo: https://github.com/myorg/deployments
    path: environments/production
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      retry:
        limit: 5
        backoff:
          duration: 5s
          maxDuration: 3m
```

### Flux Integration

```yaml
gitops:
  provider: flux
  config:
    sourceRepo: https://github.com/myorg/app
    targetRepo: https://github.com/myorg/deployments
    branch: main
    interval: 1m
    automation:
      enabled: true
      updatePolicy: semver
```

## Deployment Hooks

### Pre-Deployment

```yaml
hooks:
  preDeployment:
    - name: database-migration
      command: ["migrate", "up"]
      timeout: 5m
    - name: cache-warm
      command: ["cache", "warm", "--endpoints", "/api/v1/*"]
```

### Post-Deployment

```yaml
hooks:
  postDeployment:
    - name: smoke-test
      command: ["test", "smoke", "--endpoint", "${SERVICE_URL}"]
    - name: notify
      command: ["notify", "slack", "--channel", "#deployments"]
```

## Health Checks and Readiness

### Liveness Probes

```yaml
health:
  liveness:
    httpGet:
      path: /health/live
      port: 8080
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
```

### Readiness Probes

```yaml
health:
  readiness:
    httpGet:
      path: /health/ready
      port: 8080
    initialDelaySeconds: 5
    periodSeconds: 5
    successThreshold: 2
```

### Startup Probes

```yaml
health:
  startup:
    httpGet:
      path: /health/startup
      port: 8080
    initialDelaySeconds: 0
    periodSeconds: 10
    failureThreshold: 30
```

## Rollback Automation

### Automatic Rollback

```yaml
rollback:
  automatic: true
  conditions:
    - metric: error_rate
      threshold: 5%
      window: 5m
    - metric: latency_p99
      threshold: 1000ms
      window: 5m
  strategy: immediate # or gradual
```

### Manual Rollback

```bash
# Rollback to previous version
hks rollback --app myapp

# Rollback to specific version
hks rollback --app myapp --version v1.2.3

# Rollback with custom strategy
hks rollback --app myapp --strategy gradual --steps 4
```

## Multi-Region Deployments

```yaml
deploy:
  multiRegion:
    regions:
      - name: us-east-1
        primary: true
        weight: 50
      - name: eu-west-1
        weight: 30
      - name: ap-southeast-1
        weight: 20
    failover:
      automatic: true
      healthCheck:
        interval: 30s
        threshold: 3
```

## Deployment Monitoring

### Metrics Collection

```yaml
monitoring:
  deployment:
    metrics:
      - deployment_duration
      - rollout_status
      - replica_availability
      - error_rate
      - latency_percentiles
    alerts:
      - name: deployment-failed
        condition: deployment_status == "failed"
        severity: critical
      - name: slow-rollout
        condition: deployment_duration > 15m
        severity: warning
```

### Deployment Dashboard

```bash
# View deployment status
hks deployment status --app myapp

# Watch deployment progress
hks deployment watch --app myapp

# View deployment history
hks deployment history --app myapp --limit 10
```

## Best Practices

1. **Progressive Delivery**

   - Start with canary deployments for critical services
   - Use feature flags for gradual rollouts
   - Implement proper observability

2. **Automated Testing**

   - Run comprehensive tests in staging
   - Implement smoke tests for production
   - Use contract testing for APIs

3. **Rollback Strategy**

   - Always have a rollback plan
   - Test rollback procedures regularly
   - Keep previous versions available

4. **Security**

   - Scan images before deployment
   - Use signed images
   - Implement RBAC for deployments

5. **Documentation**
   - Document deployment procedures
   - Maintain runbooks for common issues
   - Keep deployment configurations in version control

## CLI Commands

```bash
# Deploy application
hks deploy --app myapp --version v1.2.3

# Deploy with specific strategy
hks deploy --app myapp --strategy canary --steps 3

# Promote canary to full deployment
hks promote --app myapp --environment production

# Pause deployment
hks pause --deployment myapp-v1.2.3

# Resume deployment
hks resume --deployment myapp-v1.2.3

# Abort deployment
hks abort --deployment myapp-v1.2.3
```

## Integration with CI/CD

### GitHub Actions

```yaml
- name: Deploy to Hexabase
  uses: hexabase/deploy-action@v1
  with:
    app: myapp
    environment: production
    strategy: blue-green
    wait: true
```

### GitLab CI

```yaml
deploy:
  stage: deploy
  script:
    - hks deploy --app $CI_PROJECT_NAME --version $CI_COMMIT_TAG
  environment:
    name: production
    url: https://myapp.example.com
```
