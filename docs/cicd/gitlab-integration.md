# GitLab Integration

Integrate your GitLab repositories with Hexabase.AI for automated CI/CD workflows and GitOps deployments.

## Overview

Hexabase.AI supports full GitLab integration, enabling you to leverage GitLab CI/CD while deploying to Hexabase-managed Kubernetes clusters.

## Setup

### Connect GitLab

```bash
# Connect GitLab instance
hks gitlab connect --url https://gitlab.com --token <token>

# For self-hosted GitLab
hks gitlab connect --url https://gitlab.company.com --token <token>
```

### Repository Integration

```yaml
# .hexabase/gitlab.yml
integration:
  provider: gitlab
  project: mygroup/myproject
  branches:
    main: production
    develop: staging
    feature/*: preview
```

## GitLab CI Integration

### Basic Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  HEXABASE_URL: https://api.hexabase.ai

test:
  stage: test
  script:
    - npm install
    - npm test

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy:production:
  stage: deploy
  only:
    - main
  script:
    - |
      curl -X POST $HEXABASE_URL/deploy \
        -H "Authorization: Bearer $HEXABASE_TOKEN" \
        -d '{
          "workspace": "production",
          "image": "'$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA'",
          "manifest": "k8s/"
        }'
```

### Using Hexabase GitLab Runner

Deploy Hexabase-optimized GitLab runners:

```bash
# Install runner in cluster
hks gitlab runner install --workspace production

# Register with GitLab
hks gitlab runner register --token <registration-token>
```

## Merge Request Integration

### Preview Environments

```yaml
# .gitlab-ci.yml
deploy:preview:
  stage: deploy
  only:
    - merge_requests
  environment:
    name: preview/$CI_MERGE_REQUEST_IID
    url: https://mr-$CI_MERGE_REQUEST_IID.preview.example.com
    on_stop: stop:preview
  script:
    - hks deploy --preview --mr-id $CI_MERGE_REQUEST_IID

stop:preview:
  stage: deploy
  only:
    - merge_requests
  when: manual
  environment:
    name: preview/$CI_MERGE_REQUEST_IID
    action: stop
  script:
    - hks destroy --preview --mr-id $CI_MERGE_REQUEST_IID
```

### MR Comments

Use merge request comments for actions:

- `/deploy` - Deploy to preview
- `/deploy staging` - Deploy to staging
- `/restart` - Restart deployment
- `/logs` - Show deployment logs
- `/destroy` - Remove preview

## GitLab Container Registry

### Automatic Integration

```yaml
# .hexabase/registry.yml
registry:
  provider: gitlab
  auto_sync: true
  cleanup_policy:
    keep_latest: 10
    older_than: 30d
```

### Manual Configuration

```bash
# Configure registry credentials
hks secret create gitlab-registry \
  --docker-server=$CI_REGISTRY \
  --docker-username=$CI_REGISTRY_USER \
  --docker-password=$CI_REGISTRY_PASSWORD
```

## Security Integration

### GitLab Security Scanning

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml

hexabase:security:sync:
  stage: .post
  script:
    - hks security import --source gitlab --report gl-sast-report.json
```

## Variables and Secrets

### CI/CD Variables

Sync GitLab CI/CD variables:

```bash
# Sync all variables
hks gitlab variables sync

# Sync specific variable
hks gitlab variables sync DATABASE_URL --workspace production
```

### Protected Variables

```yaml
# .hexabase/variables.yml
variables:
  sync:
    - name: API_KEY
      protected: true
      environments: [production]
    - name: DEBUG
      protected: false
      environments: [staging, development]
```

## GitLab Pages Integration

Deploy documentation to GitLab Pages:

```yaml
pages:
  stage: deploy
  script:
    - mkdocs build
    - mv site public
  artifacts:
    paths:
      - public
  only:
    - main
```

## Monitoring

### Pipeline Metrics

Monitor GitLab CI/CD performance:

```bash
# View pipeline metrics
hks gitlab metrics pipelines

# Set up alerts
hks gitlab alerts create \
  --name "pipeline-failure" \
  --condition "failure_rate > 0.1" \
  --notify slack
```

## Best Practices

1. **Use GitLab Flow**: Follow GitLab's recommended branching strategy
2. **Leverage CI/CD Templates**: Create reusable pipeline templates
3. **Secure Variables**: Use protected and masked variables
4. **Cache Dependencies**: Speed up builds with caching
5. **Parallel Testing**: Use GitLab's parallel keyword

## Troubleshooting

### Common Issues

**Runner Connection Issues**
```bash
# Check runner status
hks gitlab runner status

# View runner logs
hks logs -l app=gitlab-runner
```

**Registry Authentication**
```bash
# Test registry access
hks gitlab registry test

# Update credentials
hks gitlab registry auth refresh
```

**Pipeline Failures**
- Check job logs in GitLab UI
- Verify Hexabase API connectivity
- Review variable configuration
- Check runner resource limits