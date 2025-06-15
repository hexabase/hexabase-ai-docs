# Core Concepts

Welcome to the Hexabase.AI Core Concepts section. This guide introduces the fundamental concepts and terminology you need to understand when working with Hexabase.AI.

## Overview

Hexabase.AI is built on several key concepts that work together to provide a powerful, multi-tenant Kubernetes as a Service platform. Understanding these concepts is essential for effectively using and managing the platform.

## Key Concepts

<div class="grid cards" markdown>

- :material-domain:{ .lg .middle } **Organizations**

  ***

  Top-level entities that represent companies or teams using Hexabase.AI

  [:octicons-arrow-right-24: Learn about Organizations](multi-tenancy.md)

- :material-view-dashboard:{ .lg .middle } **Workspaces**

  ***

  Isolated environments within organizations for different teams or projects

  [:octicons-arrow-right-24: Learn about Workspaces](multi-tenancy.md)

- :material-folder-multiple:{ .lg .middle } **Projects**

  ***

  Deployable units that contain your applications and configurations

  [:octicons-arrow-right-24: Learn about Projects](core-concepts.md)

- :material-kubernetes:{ .lg .middle } **Clusters**

  ***

  Kubernetes clusters managed by Hexabase.AI for running your workloads

  [:octicons-arrow-right-24: Learn about Clusters](technology-stack.md)

</div>

## Multi-tenancy Model

Hexabase.AI implements a hierarchical multi-tenancy model:

```
Organization
└── Workspaces
    └── Projects
        └── Resources (Deployments, Services, etc.)
```

This structure provides:

- **Isolation**: Complete separation between different organizations
- **Flexibility**: Multiple workspaces for different teams or environments
- **Security**: Role-based access control at each level
- **Resource Management**: Quotas and limits per workspace

## Platform Components

### Control Plane

- Manages the overall platform operations
- Handles authentication and authorization
- Orchestrates cluster provisioning and management

### Data Plane

- Runs actual workloads in Kubernetes clusters
- Provides compute, storage, and networking resources
- Implements security policies and resource quotas

### AIOps Engine

- Monitors resource usage and performance
- Provides intelligent recommendations
- Automates optimization and scaling decisions

## Next Steps

- **New to Hexabase.AI?** Start with [Organizations](multi-tenancy.md) to understand the top-level structure
- **Setting up a team?** Learn about [Workspaces](multi-tenancy.md) and how to organize your environments
- **Ready to deploy?** Understand [Projects](core-concepts.md) and how to package your applications
- **Managing infrastructure?** Explore [Clusters](technology-stack.md) and their capabilities

## Related Documentation

- [Overview](overview.md)
- [Architecture Overview](../architecture/index.md)
- [API Reference](../api/index.md)
