# Container Registry Service

Hexabase.AI provides a **project-scoped Container Registry Service** that enables secure storage, management, and distribution of container images within your Hexabase.AI projects. Built with support for multiple registry providers including Harbor as the default platform, our service ensures enterprise-grade security, scalability, and seamless integration with your CI/CD workflows.

## Overview

The Container Registry Service is **project-scoped**, meaning each Hexabase.AI project can have its own dedicated container registry space. This approach provides better isolation, security, and resource management compared to workspace-wide registries. Whether you're deploying microservices, managing CI/CD pipelines, or distributing applications across multiple environments, our registry service ensures your container images are secure, accessible, and properly managed at the project level.

## Key Features

<div class="grid cards" markdown>

- :material-package:{ .lg .middle } **Secure Image Storage**

  ***

  Enterprise-grade security with role-based access control and image signing

  [:octicons-arrow-right-24: Security Features](#security-features)

- :material-shield-check:{ .lg .middle } **Vulnerability Scanning**

  ***

  Automated security scanning with detailed vulnerability reports

  [:octicons-arrow-right-24: Security Scanning](#vulnerability-scanning)

- :material-sync:{ .lg .middle } **Multi-Registry Replication**

  ***

  Cross-region replication and disaster recovery capabilities

  [:octicons-arrow-right-24: Replication](#replication)

- :material-api:{ .lg .middle } **API Integration**

  ***

  RESTful APIs and webhook support for seamless CI/CD integration

  [:octicons-arrow-right-24: API Reference](https://api.hexabase.ai/docs#registry)

</div>

## Harbor: Default Registry Platform

Hexabase.AI uses **Harbor** as the default container registry platform, providing:

### Core Harbor Features

- **Project-based Organization**: Organize images by projects with granular access control
- **Role-based Access Control (RBAC)**: Fine-grained permissions for users and groups
- **Image Vulnerability Scanning**: Built-in security scanning with Trivy and Clair
- **Content Trust**: Docker Content Trust and Notary for image signing
- **Garbage Collection**: Automated cleanup of unused images and layers
- **Audit Logging**: Comprehensive logging of all registry operations

### Enterprise Enhancements

- **Multi-tenancy Support**: Isolated registry spaces per workspace
- **SSO Integration**: Seamless integration with your identity providers
- **High Availability**: Clustered deployment with load balancing
- **Backup and Recovery**: Automated backup with point-in-time recovery
- **Monitoring Integration**: Built-in metrics and alerting

## Registry Architecture

### Project-Scoped Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Hexabase.AI                          │
│                 Container Registry                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Workspace A │  │ Workspace B │  │ Workspace C │     │
│  │             │  │             │  │             │     │
│  │ ┌─Project 1─┐ │  │ ┌─Project 1─┐ │  │ ┌─Project 1─┐ │     │
│  │ │ Registry  │ │  │ │ Registry  │ │  │ │ Registry  │ │     │
│  │ └───────────┘ │  │ └───────────┘ │  │ └───────────┘ │     │
│  │ ┌─Project 2─┐ │  │ ┌─Project 2─┐ │  │ ┌─Project 2─┐ │     │
│  │ │ Registry  │ │  │ │ Registry  │ │  │ │ Registry  │ │     │
│  │ └───────────┘ │  │ └───────────┘ │  │ └───────────┘ │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
├─────────────────────────────────────────────────────────┤
│         Registry Providers (Harbor, ECR, ACR...)      │
├─────────────────────────────────────────────────────────┤
│    Storage Backend (Object Storage + Database)         │
└─────────────────────────────────────────────────────────┘
```

### Service Components

- **Registry Core**: Harbor registry engine with OCI compliance
- **Database**: PostgreSQL for metadata and configuration
- **Redis Cache**: High-performance caching layer
- **Storage Backend**: Object storage for container layers
- **Security Scanner**: Integrated vulnerability scanning engines
- **Replication Controller**: Cross-region synchronization

## Getting Started

### 1. Create a Project Registry

Each project can have its own dedicated registry. First, create a registry for your project:

```bash
# Create a registry for your project
hb registry create-project \
  --project-id my-project \
  --name "My Project Registry" \
  --provider harbor \
  --description "Container registry for my application"

# Registry URL format (project-scoped)
https://<registry-id>.registry.hexabase.ai/<project-id>

# Example
https://harbor-01.registry.hexabase.ai/my-project
```

### 2. Authentication

#### Using Docker CLI

```bash
# Login to your project registry
docker login harbor-01.registry.hexabase.ai

# Enter your Hexabase.AI credentials
Username: your-username
Password: your-token-or-password
```

#### Using Robot Accounts

For automated workflows, create robot accounts:

```bash
# Create robot account for project
hb registry robot create \
  --name ci-cd-bot \
  --project-id my-project \
  --permissions read,write \
  --description "CI/CD automation account"

# Use robot credentials
docker login harbor-01.registry.hexabase.ai \
  -u robot$ci-cd-bot \
  -p <robot-token>
```

### 3. Basic Operations

#### Push Images

```bash
# Tag your image (project-scoped)
docker tag myapp:latest harbor-01.registry.hexabase.ai/my-project/myapp:latest

# Push to project registry
docker push harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

#### Pull Images

```bash
# Pull from project registry
docker pull harbor-01.registry.hexabase.ai/my-project/myapp:latest

# Deploy to Kubernetes
kubectl create deployment myapp \
  --image=harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

## API Endpoints

The Container Registry Service provides project-scoped REST API endpoints:

### Registry Management (Admin Level)
```bash
# Register a new registry instance
POST /api/v1/registries

# List all available registries
GET /api/v1/registries

# Get registry details
GET /api/v1/registries/{id}

# Update registry configuration
PUT /api/v1/registries/{id}

# Delete registry
DELETE /api/v1/registries/{id}

# Check registry health
GET /api/v1/registries/{id}/health
```

### Project-Scoped Registry Operations
```bash
# Create registry for a project
POST /api/v1/projects/{projectId}/registry

# Get project registry details
GET /api/v1/projects/{projectId}/registry

# Update project registry
PUT /api/v1/projects/{projectId}/registry

# Delete project registry
DELETE /api/v1/projects/{projectId}/registry

# Get project storage usage
GET /api/v1/projects/{projectId}/registry/usage

# Configure project security settings
PUT /api/v1/projects/{projectId}/registry/security

# Update storage quota
PUT /api/v1/projects/{projectId}/registry/quota
```

### Example API Usage

#### Create Project Registry
```bash
curl -X POST "https://api.hexabase.ai/api/v1/projects/my-project/registry" \
  -H "Authorization: Bearer $HB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Project Registry",
    "provider": "harbor",
    "visibility": "private",
    "description": "Container registry for my application"
  }'
```

#### Get Project Registry Info
```bash
curl -X GET "https://api.hexabase.ai/api/v1/projects/my-project/registry" \
  -H "Authorization: Bearer $HB_TOKEN"
```

## Project Registry Management

### Creating Project Registries

Each Hexabase.AI project can have its own container registry:

```bash
# Create a registry for a project
hb registry create-project \
  --project-id frontend-app \
  --name "Frontend Application Registry" \
  --provider harbor \
  --visibility private \
  --description "Registry for frontend microservices"

# List project registries
hb registry list-projects --workspace production

# Get project registry details
hb registry get-project --project-id frontend-app
```

### Project Registry Configuration

#### Access Control

```yaml
# Project registry RBAC configuration
project_id: frontend-app
registry_id: harbor-01
members:
  - user: "alice@company.com"
    role: "ProjectAdmin"
  - user: "bob@company.com"
    role: "Developer"
  - group: "frontend-team"
    role: "Developer"

security_policies:
  vulnerability_scanning: true
  content_trust: required
  prevent_vulnerable_images: true
  auto_scan_on_push: true
  severity_threshold: "high"
```

#### Retention Policies

```yaml
# Image retention configuration
retention_policy:
  rules:
    - priority: 1
      disabled: false
      action: "retain"
      template: "latestPushedK"
      params:
        latestPushedK: 10  # Keep latest 10 images
      tag_selectors:
        - kind: "doublestar"
          decoration: "matches"
          pattern: "**"
      scope_selectors:
        - repository:
            - kind: "doublestar"
              decoration: "repoMatches"
              pattern: "**"
```

## Security Features

### Vulnerability Scanning

#### Automated Scanning

- **Scan on Push**: Automatic vulnerability scanning when images are uploaded
- **Scheduled Scans**: Regular scanning of existing images for new vulnerabilities
- **Multi-Scanner Support**: Integration with Trivy, Clair, and other scanners

#### Vulnerability Reports

```bash
# Get vulnerability report for project image
hb registry scan report \
  --project-id my-project \
  --image harbor-01.registry.hexabase.ai/my-project/myapp:latest

# Example output
Vulnerability Summary:
  High: 2
  Medium: 5
  Low: 12
  Unknown: 1

Critical Vulnerabilities:
  CVE-2023-12345: Remote Code Execution in libssl
  CVE-2023-67890: Buffer Overflow in base image
```

#### Security Policies

```yaml
# Security policy configuration
security_policy:
  prevent_vulnerable_images:
    enabled: true
    severity_threshold: "high"
  
  content_trust:
    enabled: true
    cosign_verification: true
  
  image_scanning:
    auto_scan: true
    scan_on_push: true
    scanner: "trivy"
```

### Content Trust and Signing

#### Docker Content Trust

```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1
export DOCKER_CONTENT_TRUST_SERVER=https://harbor-01.registry.hexabase.ai:4443

# Push signed image
docker push harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

#### Cosign Integration

```bash
# Sign image with Cosign
cosign sign harbor-01.registry.hexabase.ai/my-project/myapp:latest

# Verify signature
cosign verify harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

## Replication

### Cross-Region Replication

Set up replication for disaster recovery and global distribution:

```bash
# Create replication endpoint
hb registry replication endpoint create \
  --name disaster-recovery \
  --url https://dr-harbor.registry.hexabase.ai \
  --project-id my-project

# Create replication rule
hb registry replication rule create \
  --name project-to-dr \
  --source-project my-project \
  --destination-endpoint disaster-recovery \
  --filter-pattern "my-project/**" \
  --trigger manual
```

#### Replication Configuration

```yaml
# Replication rule configuration
replication_rule:
  name: "prod-to-dr"
  description: "Production to disaster recovery replication"
  source_registry:
    type: "harbor"
    url: "https://prod-workspace.registry.hexabase.ai"
  destination_registry:
    type: "harbor"
    url: "https://dr-workspace.registry.hexabase.ai"
  filters:
    - type: "repository"
      value: "production/**"
    - type: "tag"
      value: "v*"
  trigger:
    type: "scheduled"
    schedule: "0 2 * * *"  # Daily at 2 AM
  settings:
    override: false
    deletion: false
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/build-and-push.yml
name: Build and Push to Registry

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to Hexabase Registry
        uses: docker/login-action@v2
        with:
          registry: harbor-01.registry.hexabase.ai
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            harbor-01.registry.hexabase.ai/my-project/myapp:latest
            harbor-01.registry.hexabase.ai/my-project/myapp:${{ github.sha }}
      
      - name: Scan image
        run: |
          hb registry scan start \
            --project-id my-project \
            --image harbor-01.registry.hexabase.ai/my-project/myapp:${{ github.sha }} \
            --wait
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - build
  - scan
  - deploy

variables:
  REGISTRY: "harbor-01.registry.hexabase.ai"
  PROJECT_ID: "my-project"
  IMAGE_NAME: "$REGISTRY/$PROJECT_ID/myapp"

build:
  stage: build
  script:
    - docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD $REGISTRY
    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHA .
    - docker push $IMAGE_NAME:$CI_COMMIT_SHA

security_scan:
  stage: scan
  script:
    - hb registry scan start --project-id $PROJECT_ID --image $IMAGE_NAME:$CI_COMMIT_SHA --wait
    - hb registry scan report --project-id $PROJECT_ID --image $IMAGE_NAME:$CI_COMMIT_SHA --format json > scan-results.json
  artifacts:
    reports:
      vulnerability: scan-results.json
```

## Monitoring and Analytics

### Registry Metrics

Monitor registry performance and usage:

```bash
# Get project registry statistics
hb registry stats --project-id my-project

# Example output
Registry Statistics:
  Total Repositories: 156
  Total Images: 1,247
  Storage Used: 2.3 TB
  Pulls (24h): 15,847
  Pushes (24h): 234
  Active Users: 45
```

### Common Metrics

- **Storage Usage**: Track storage consumption by project
- **Pull/Push Rates**: Monitor registry traffic and usage patterns  
- **Vulnerability Trends**: Track security improvements over time
- **User Activity**: Monitor access patterns and usage
- **Replication Status**: Monitor cross-region sync health

### Alerts and Notifications

```yaml
# Alert configuration
alerts:
  - name: "high_storage_usage"
    condition: "storage_usage > 80%"
    notification:
      - webhook: "https://hooks.slack.com/services/..."
      - email: "ops-team@company.com"
  
  - name: "vulnerability_detected"
    condition: "new_critical_vulnerability == true"
    notification:
      - webhook: "https://hooks.teams.microsoft.com/..."
```

## Best Practices

### Image Management

1. **Use Semantic Versioning**: Tag images with semantic versions (v1.2.3)
2. **Immutable Tags**: Avoid overwriting existing tags
3. **Multi-Stage Builds**: Optimize image size and security
4. **Base Image Updates**: Regularly update base images for security patches

### Security Best Practices

1. **Regular Scanning**: Enable automatic vulnerability scanning
2. **Minimal Images**: Use distroless or minimal base images
3. **Image Signing**: Implement content trust and image signing
4. **Access Control**: Follow principle of least privilege
5. **Secrets Management**: Never include secrets in images

### Performance Optimization

1. **Layer Caching**: Optimize Dockerfile for layer reuse
2. **Registry Location**: Use regional registries for faster pulls
3. **Cleanup Policies**: Implement retention policies to manage storage
4. **Parallel Pulls**: Configure concurrent layer downloads

## Future Roadmap

### Alternative Registry Support

While Harbor serves as our default platform, we're planning support for additional registry platforms:

#### Near-term (Q1-Q2)
- **AWS ECR Integration**: Native support for Amazon Elastic Container Registry
- **Azure ACR Support**: Integration with Azure Container Registry
- **Google GCR/Artifact Registry**: Support for Google Cloud registry services

#### Medium-term (Q3-Q4)
- **GitLab Container Registry**: Direct integration with GitLab's registry
- **JFrog Artifactory**: Enterprise artifact management integration
- **Nexus Repository**: Sonatype Nexus support for enterprise customers

#### Long-term (Next Year)
- **Multi-Registry Federation**: Unified view across multiple registry providers
- **Registry Mesh**: Distributed registry architecture
- **AI-Powered Optimization**: Intelligent image optimization and recommendations
- **OCI Artifacts**: Full support for OCI artifact types beyond container images

### Enhanced Features

- **Advanced Caching**: Global content delivery network for images
- **Build Caching**: Registry-based build cache for faster CI/CD
- **Image Promotion**: Automated image promotion pipelines
- **Compliance Scanning**: Enhanced compliance and policy enforcement

## Getting Help

### Documentation and Support

```bash
# Get help with registry commands
hb registry help

# Check project registry status
hb registry status --project-id my-project

# View project registry logs
hb registry logs --follow --project-id my-project
```

### Troubleshooting Common Issues

#### Authentication Problems
```bash
# Clear Docker credentials
docker logout harbor-01.registry.hexabase.ai

# Re-authenticate
docker login harbor-01.registry.hexabase.ai

# Test connection
docker pull harbor-01.registry.hexabase.ai/my-project/hello-world
```

#### Network Issues
```bash
# Test registry connectivity
curl -v https://harbor-01.registry.hexabase.ai/v2/

# Check DNS resolution
nslookup harbor-01.registry.hexabase.ai
```

## Related Documentation

- [Applications Deployment](../applications/index.md) - Using registry images in deployments
- [CI/CD Pipelines](../cicd/index.md) - Integrating registry with pipelines
- [RBAC Configuration](../rbac/index.md) - Managing registry access permissions
- [API Reference](https://api.hexabase.ai/docs#registry) - Complete API documentation