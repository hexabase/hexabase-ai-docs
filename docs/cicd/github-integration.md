# GitHub Integration

Seamlessly integrate your GitHub repositories with Hexabase.AI to enable automated CI/CD workflows, code deployments, and GitOps practices.

## Overview

Hexabase.AI provides native GitHub integration that allows you to connect your repositories, set up automated pipelines, and deploy applications directly from your GitHub workflow.

## Initial Setup

### 1. Connect Your GitHub Account

#### Via UI

1. Navigate to **Settings** → **Integrations** → **GitHub**
2. Click **Connect GitHub Account**
3. Authorize Hexabase.AI to access your repositories
4. Select repositories to integrate

#### Via CLI

```bash
# Connect GitHub account
hb github connect

# List available repositories
hb github repos list

# Connect specific repository
hb github repo connect owner/repo --workspace production
```

### 2. Repository Configuration

Once connected, configure your repository settings:

```yaml
# .hexabase/github.yml
integration:
  provider: github
  repository: myorg/myapp
  branch:
    main: production
    develop: staging
    feature/*: preview
  secrets:
    inherit: true  # Inherit GitHub secrets
```

## Webhook Configuration

### Automatic Webhook Setup

Hexabase.AI automatically configures webhooks when you connect a repository:

- **Push events**: Trigger builds on code pushes
- **Pull request events**: Run tests and preview deployments
- **Release events**: Deploy to production
- **Issue comments**: Trigger actions via comments

### Manual Webhook Configuration

If needed, manually configure webhooks:

1. Go to GitHub repository → Settings → Webhooks
2. Add webhook URL: `https://api.hexabase.ai/webhooks/github`
3. Select events:
   - Push
   - Pull requests
   - Releases
   - Issue comments
4. Set content type to `application/json`

## GitHub Actions Integration

### Using Hexabase.AI in GitHub Actions

Install the Hexabase.AI GitHub Action:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Hexabase
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Hexabase
        uses: hexabase/deploy-action@v1
        with:
          api-key: ${{ secrets.HEXABASE_API_KEY }}
          workspace: production
          manifest: ./k8s/
```

### Advanced GitHub Actions Workflow

```yaml
name: Complete CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Tests
        run: |
          npm install
          npm test
      
      - name: Security Scan
        uses: hexabase/security-scan@v1
        with:
          api-key: ${{ secrets.HEXABASE_API_KEY }}

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Container
        uses: hexabase/build-action@v1
        with:
          api-key: ${{ secrets.HEXABASE_API_KEY }}
          dockerfile: ./Dockerfile
          tags: |
            latest
            ${{ github.sha }}

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Production
        uses: hexabase/deploy-action@v1
        with:
          api-key: ${{ secrets.HEXABASE_API_KEY }}
          workspace: production
          image: ${{ github.sha }}
          wait: true
          timeout: 300
```

## Pull Request Workflows

### Preview Environments

Automatically create preview environments for pull requests:

```yaml
# .hexabase/preview.yml
preview:
  enabled: true
  auto_deploy: true
  resources:
    cpu: 100m
    memory: 256Mi
  lifetime: 72h  # Auto-cleanup after 3 days
  domains:
    pattern: "pr-{number}.preview.example.com"
```

### PR Comments Commands

Use comments to control deployments:

- `/deploy` - Deploy PR to preview environment
- `/deploy staging` - Deploy PR to staging
- `/destroy` - Remove preview environment
- `/test` - Run integration tests
- `/approve` - Approve for production deployment

### Status Checks

Hexabase.AI provides GitHub status checks:

```yaml
# .hexabase/checks.yml
checks:
  - name: build
    required: true
    
  - name: security-scan
    required: true
    severity: high
    
  - name: integration-tests
    required: true
    
  - name: preview-deploy
    required: false
```

## Secrets Management

### Using GitHub Secrets

Reference GitHub secrets in your pipelines:

```yaml
# .hexabase/pipeline.yml
stages:
  - name: deploy
    env:
      - name: API_KEY
        valueFrom:
          githubSecret: API_KEY
      - name: DATABASE_URL
        valueFrom:
          githubSecret: DATABASE_URL
```

### Syncing Secrets

Sync GitHub secrets to Hexabase.AI:

```bash
# Sync all secrets
hb github secrets sync

# Sync specific secret
hb github secrets sync API_KEY --workspace production
```

## Branch Protection

### Automated Branch Protection

Configure branch protection rules that integrate with Hexabase.AI:

```yaml
# .hexabase/protection.yml
protection:
  branches:
    main:
      required_checks:
        - hexabase/build
        - hexabase/security
        - hexabase/deploy-staging
      require_up_to_date: true
      enforce_admins: true
    
    develop:
      required_checks:
        - hexabase/build
        - hexabase/test
```

## GitHub Apps

### Creating a GitHub App

For organization-wide integration:

1. Create GitHub App in your organization
2. Configure permissions:
   - Repository: Read & Write
   - Pull requests: Read & Write
   - Checks: Write
   - Webhooks: Read
3. Install in Hexabase.AI:

```bash
hb github app install \
  --app-id 123456 \
  --private-key @private-key.pem \
  --organization myorg
```

## Monitoring Integration

### GitHub Metrics

Monitor your GitHub integration:

- Webhook delivery success rate
- Build trigger latency
- PR deployment statistics
- Repository activity

### Alerts

Configure alerts for GitHub events:

```yaml
alerts:
  - name: failed-deployment
    condition: github.deployment.status == "failure"
    notify:
      - github-issue
      - slack
    
  - name: long-running-pr
    condition: github.pr.age > "7d"
    notify:
      - github-comment
```

## Best Practices

### 1. Repository Structure

Organize your repository for Hexabase.AI:

```
myapp/
├── .hexabase/
│   ├── pipeline.yml
│   ├── preview.yml
│   └── github.yml
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── src/
└── Dockerfile
```

### 2. Commit Message Conventions

Use conventional commits for better automation:

- `feat:` - Triggers feature deployment
- `fix:` - Triggers hotfix deployment
- `docs:` - Skips deployment
- `chore:` - Skips deployment

### 3. Security

- Use GitHub secrets for sensitive data
- Enable secret scanning
- Require signed commits
- Use branch protection rules

### 4. Performance

- Use shallow clones for faster builds
- Cache dependencies in GitHub Actions
- Parallelize test execution
- Use build matrices wisely

## Troubleshooting

### Common Issues

**Webhook Not Triggering**
```bash
# Check webhook status
hb github webhook status

# Redeliver webhook
hb github webhook redeliver <delivery-id>
```

**Authentication Errors**
```bash
# Refresh GitHub token
hb github auth refresh

# Check permissions
hb github auth check
```

**Build Not Starting**
- Verify branch patterns in configuration
- Check GitHub App permissions
- Review webhook delivery logs

### Debug Mode

Enable detailed GitHub integration logging:

```bash
# Enable debug logs
hb github debug --enable

# View integration logs
hb logs -n hexabase-system -l component=github-integration
```

## Migration Guide

### From GitHub Actions to Hexabase Pipelines

1. Export existing workflow:
```bash
hb github migrate workflow .github/workflows/deploy.yml
```

2. Review generated pipeline:
```bash
cat .hexabase/pipeline.yml
```

3. Test in staging:
```bash
hb pipeline run --workspace staging
```

4. Enable automatic triggers:
```bash
hb github triggers enable
```