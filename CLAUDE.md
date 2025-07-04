# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the user-facing documentation repository for Hexabase.AI (HKS - Multi-tenant Kubernetes as a Service with AIOps). The documentation is built using Material for MkDocs and is now functionally complete for its first version. It targets four main audiences:

1. **HKS Admin users** - Organization and Workspace administration
2. **HKS users** - Project deployment and resource management
3. **Contributors** - Development environment setup and contribution guidelines
4. **VM deployers** - Infrastructure setup with Proxmox

## Common Commands

### Documentation Development

The project environment is standard for MkDocs with multi-language support.

```bash
# Setup environment (first time)
./scripts/setup.sh

# Development servers
./scripts/serve.sh en     # English development server
./scripts/serve.sh ja     # Japanese development server
./scripts/serve-all.sh    # Build and serve both languages

# Build documentation
./scripts/build.sh        # Build both English and Japanese sites

# Manual commands (if needed)
mkdocs serve --config-file mkdocs.yml      # English only
mkdocs serve --config-file mkdocs.ja.yml   # Japanese only
mkdocs build --clean                       # English build
mkdocs build --config-file mkdocs.ja.yml --site-dir site/ja  # Japanese build
```

## Documentation Structure

The documentation is organized by functional areas and concepts. The structure is now complete:

```
docs/
├── concept/        # Core concepts and overview
├── usecases/       # Use cases and scenarios
├── architecture/   # System architecture and ADRs
│   └── adr/       # Architecture Decision Records
├── rbac/          # RBAC for both Hexabase and Kubernetes
├── nodes/         # Dedicated VM and node management
├── applications/  # Application resources and deployment
├── cicd/          # CI/CD pipelines and integrations
├── cronjobs/      # Scheduled job management
├── functions/     # Serverless functions (FaaS)
├── observability/ # Monitoring, logging, and tracing
├── backups/       # Backup and disaster recovery
├── security/      # Security policies and best practices
├── aiops/         # AI Operations and automation
├── api/           # API reference documentation
├── sdk/           # SDKs and CLI tools
├── ja/            # Japanese translations (mirrors above structure)
└── index.md       # Landing page
```

All sections listed in the original `MISSING_DOCUMENTATION_REPORT.md` are now complete.

## Brand Guidelines

Use the following color palette for consistency:

- Primary Background: #000000
- Primary: #00C6AB
- Secondary: #FF346B
- Success: #4CAF50
- Warning: #FF9800
- Error: #F44336
- Info: #2196F3

## Related Resources

The main Hexabase.AI repository is located at `/Users/hi/src/hexabase-ai/` and contains:

- Comprehensive technical documentation in `/docs/`
- API implementation (Go)
- UI implementation (Next.js)
- AI-Ops service (Python)
- SDK and CLI tools

When creating documentation, reference the existing technical documentation and architecture decisions in the main repository.

## Key Considerations

1. **Multi-language Support**: Documentation must be available in both English and Japanese. The next major task is to generate the Japanese translations.
2. **Functional Organization**: Documentation is organized by features and concepts rather than user roles.
3. **Integration**: Link to relevant technical documentation in the main Hexabase.AI repository.
4. **Material Theme**: Utilize Material for MkDocs features like admonitions, tabs, and code highlighting.
5. **RBAC Focus**: Special emphasis on explaining the relationship between Hexabase RBAC and Kubernetes RBAC.
6. **AI-Ops Integration**: Highlight AI-powered features throughout relevant sections.
