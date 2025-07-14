# Technology Stack

## Overview

Hexabase.AI is built on a modern, cloud-native technology stack that combines proven CNCF open-source technologies with custom AI-oriented components to deliver a comprehensive AI-first Kubernetes platform.

## Core Technologies

### Container Orchestration

#### K3s + vCluster

- **K3s**: Lightweight Kubernetes distribution as the host cluster
- **vCluster**: Virtual Kubernetes clusters for workspace isolation
- **Benefits**: 
  - Minimal resource overhead compared to full Kubernetes
  - Complete API server isolation per workspace
  - Production-ready with enterprise features

### Programming Languages & Frameworks

#### Backend

- **Go (Golang)**: API server, CLI tools, and core platform components
- **Python**: AI operations service, ML pipelines, and automation scripts

#### Frontend

- **Next.js**: Modern React-based web UI
- **TypeScript**: Type-safe JavaScript for frontend development

#### Communication

- **REST APIs**: Primary interface for external integrations
- **HTTP/HTTPS**: Standard web protocols for all communications
- **WebSocket**: Real-time updates and notifications

### Data Layer

#### Databases

- **PostgreSQL**: Primary relational database for all platform data
- **Redis**: Caching, session management, and real-time data
- **NATS**: Messaging system for async processing and event handling

#### Storage

- **Persistent Volumes**: Kubernetes-native storage for workloads
- **Cloud Storage**: S3, GCS, Azure Blob for backup and object storage
- **MinIO**: S3-compatible object storage for on-premises deployments

### Observability Stack

#### Monitoring & Metrics

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **OpenTelemetry**: Distributed tracing and metrics
- **ClickHouse**: Time-series analytics and aggregation

#### Logging

- **Loki**: Log aggregation and storage
- **Grafana**: Log visualization and querying
- **Vector**: High-performance log processing

### CI/CD & GitOps

#### Flux

- GitOps continuous delivery
- Multi-tenancy support
- Automatic synchronization with Git repositories

#### Tekton

- Cloud-native CI/CD pipelines
- Kubernetes-native workflows
- Extensible task library

### Security

#### Authentication & Authorization

- **OIDC**: OAuth2/OpenID Connect for external identity providers
- **RBAC**: Kubernetes role-based access control
- **vCluster Isolation**: Complete API server isolation per workspace

#### Policy Management

- **Kyverno**: Kubernetes admission controller for policy enforcement
- **Network Policies**: Pod-to-pod communication control
- **Pod Security Standards**: Kubernetes-native pod security

#### Runtime Security

- **Falco**: Runtime security monitoring and threat detection
- **Trivy**: Container and infrastructure vulnerability scanning

### AI Operations

#### AI Engine

- **Python**: Core AI operations service
- **LangChain**: LLM application framework for AI agents
- **OpenAI/Claude API**: Integration with large language models

#### Function Runtime

- **HKS Functions**: Serverless function platform for AI workloads
- **Python/Node.js**: Supported runtime environments
- **Auto-scaling**: AI-powered resource optimization

### Infrastructure

#### Virtualization

- **Proxmox**: VM management for dedicated node plans
- **Cloud Providers**: EKS, GKE, AKS, OKE integration

#### Networking

- **Calico/Flannel**: Container networking
- **NGINX Ingress**: HTTP/HTTPS routing and SSL termination
- **Cert-Manager**: Automatic TLS certificate management

## System Architecture

### Infrastructure Foundation

```
┌─────────────────────────────────────┐
│         Infrastructure              │
│   Proxmox | AWS | GCP | Azure      │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│         Host K3s Cluster            │
│    (Lightweight Kubernetes)        │
└─────────────────────────────────────┘
```

### Platform Layer

```
┌─────────────────────────────────────┐
│      Hexabase.AI Control Plane     │
│    (Go API + PostgreSQL + Redis)   │
├─────────────────────────────────────┤
│         vClusters (Workspaces)      │
│   ┌─────────┐ ┌─────────┐ ┌──────┐  │
│   │vCluster1│ │vCluster2│ │ ...  │  │
│   └─────────┘ └─────────┘ └──────┘  │
└─────────────────────────────────────┘
```

### Application Layer

```
┌─────────────────────────────────────┐
│          User Workloads             │
├─────────────────────────────────────┤
│ AI Apps │ Functions │ Web Services │
├─────────────────────────────────────┤
│      Projects (Namespaces)         │
└─────────────────────────────────────┘
```

## Integration Points

### External Services

- **Identity Providers**: Google, GitHub, and other OIDC providers
- **Version Control**: GitHub, GitLab integration for CI/CD
- **Container Registries**: Docker Hub, ECR, GCR, private registries
- **Cloud Storage**: S3, GCS, Azure Blob for backups and artifacts
- **AI Services**: OpenAI, Anthropic, and other LLM providers

### API Interfaces

- **REST APIs**: Primary interface for all platform operations
- **WebSocket**: Real-time notifications and live updates
- **OIDC Provider**: Authentication for vClusters and workspaces
- **Kubernetes API**: Direct kubectl access to workspaces

## SDKs & CLI Tools

### HKS CLI

- **Go-based**: Native CLI for Hexabase.AI operations
- **Functions**: Deploy and manage serverless functions
- **Workspaces**: Create and manage isolated environments
- **Projects**: Application lifecycle management

### SDKs

- **Python SDK**: For AI/ML workflows and automation
- **JavaScript/Node.js SDK**: For web applications and functions
- **REST API**: Language-agnostic HTTP interface

## Deployment Options

### Cloud Deployments

- **Amazon EKS**: Managed Kubernetes on AWS
- **Google GKE**: Managed Kubernetes on Google Cloud
- **Azure AKS**: Managed Kubernetes on Microsoft Azure
- **Oracle OKE**: Managed Kubernetes on Oracle Cloud

### On-Premises

- **Proxmox**: VM-based deployment with dedicated resources
- **Bare Metal**: Direct Kubernetes installation
- **Edge Computing**: Lightweight K3s for edge locations

## Performance & Scalability

### AI-Powered Optimization

- **Intelligent Scaling**: AI-driven resource optimization
- **Predictive Scaling**: Learn from workload patterns
- **Cost Optimization**: Automatic right-sizing recommendations
- **Performance Insights**: AI-generated optimization suggestions

### Multi-Tenancy Efficiency

- **vCluster Overhead**: Minimal resource impact per workspace
- **Shared Infrastructure**: Efficient resource utilization
- **Dedicated Nodes**: Premium isolation for enterprise workloads

## Development Workflow

### For AI Developers

1. **Create Workspace**: Isolated environment for AI projects
2. **Deploy Functions**: Serverless AI agent deployment
3. **CI/CD Integration**: Automated testing and deployment
4. **Monitoring**: Built-in observability for AI workloads

### Development Tools

- **kubectl**: Direct Kubernetes access to workspaces
- **HKS CLI**: Hexabase.AI-specific operations
- **Docker**: Container building and testing
- **VS Code Extensions**: IDE integration for seamless development

## Related Topics

- [Multi-Tenancy](./multi-tenancy.md) - Understanding workspace and project isolation
- [System Architecture](../architecture/index.md) - Detailed technical architecture
- [API Reference](https://api.hexabase.ai/docs) - Complete API documentation
