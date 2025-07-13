# Architecture

Explore the technical architecture of Hexabase.AI, from high-level system design to detailed component interactions.

## Overview

Hexabase.AI is built on a modern, cloud-native architecture that combines the power of Kubernetes with intelligent automation. Our architecture prioritizes scalability, security, and extensibility while maintaining operational simplicity.

## Architecture Documentation

<div class="grid cards" markdown>

- :material-sitemap:{ .lg .middle } **System Overview**

  ***

  High-level architecture and component relationships

  [:octicons-arrow-right-24: View System Architecture](system-architecture.md)

- :material-layers:{ .lg .middle } **Platform Components**

  ***

  Detailed breakdown of control plane and data plane components

  [:octicons-arrow-right-24: Explore Components](technical-design.md)

- :material-network:{ .lg .middle } **Networking**

  ***

  Network architecture, service mesh, and traffic management

  [:octicons-arrow-right-24: Technical Design](technical-design.md)

- :material-security:{ .lg .middle } **Security Architecture**

  ***

  Security layers, authentication, and compliance features

  [:octicons-arrow-right-24: Security Architecture](security-architecture.md)

</div>

## Key Architectural Principles

### 1. Multi-tenancy First

- Hard isolation between organizations
- Soft isolation between workspaces
- Resource quotas and limits enforcement

### 2. API-Driven Design

- Everything accessible via REST APIs
- GraphQL for complex queries
- WebSocket for real-time updates

### 3. Cloud-Native Patterns

- Microservices architecture
- Container-first approach
- Declarative configuration

### 4. Intelligent Automation

- AI/ML integration for operations
- Predictive scaling and optimization
- Anomaly detection and remediation

## System Layers

```
┌─────────────────────────────────────────┐
│          User Interface Layer           │
│    (Web Portal, CLI, Mobile Apps)       │
├─────────────────────────────────────────┤
│           API Gateway Layer             │
│  (Authentication, Rate Limiting, etc.)  │
├─────────────────────────────────────────┤
│         Control Plane Services          │
│ (Orchestration, Scheduling, Monitoring) │
├─────────────────────────────────────────┤
│           Data Plane Layer              │
│   (Kubernetes Clusters, Workloads)      │
├─────────────────────────────────────────┤
│        Infrastructure Layer             │
│    (Compute, Storage, Networking)       │
└─────────────────────────────────────────┘
```

## Technology Stack

### Core Technologies

- **Kubernetes**: Container orchestration
- **Istio**: Service mesh for traffic management
- **Prometheus**: Metrics and monitoring
- **Grafana**: Visualization and dashboards
- **ArgoCD**: GitOps and continuous deployment

### AI/ML Stack

- **TensorFlow**: Model training and inference
- **Kubeflow**: ML workflow orchestration
- **Custom Models**: Resource optimization and anomaly detection

### Development Stack

- **Go**: Control plane services
- **Python**: AI/ML components
- **React**: Web interface
- **PostgreSQL**: Metadata storage
- **Redis**: Caching and queuing

## Architecture Decision Records

We maintain Architecture Decision Records (ADRs) to document significant architectural choices:

[:octicons-arrow-right-24: View Technical Design](technical-design.md)

## Deployment Models

### SaaS Deployment

- Fully managed by Hexabase team
- Multi-region availability
- Automatic updates and maintenance

### On-Premises Deployment

- Deploy in your data center
- Full control over infrastructure
- Support for air-gapped environments

### Hybrid Deployment

- Control plane in cloud
- Data plane on-premises
- Best of both worlds

## Next Steps

- **Deep Dive**: Explore [Platform Components](technical-design.md) for detailed technical information
- **Security Focus**: Review [Security Architecture](security-architecture.md) for compliance requirements
- **Design Decisions**: Browse [Technical Design](technical-design.md) to understand our architectural choices
- **Integration**: Check [API Documentation](https://api.hexabase.ai/docs) for integration options

## Related Documentation

- [Core Concepts](../concept/index.md)
- [Kubernetes RBAC](../rbac/index.md)
- [Observability](../observability/index.md)
- [API Reference](https://api.hexabase.ai/docs)
