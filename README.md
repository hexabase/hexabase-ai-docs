# Hexabase.AI Documentation

[![MkDocs](https://img.shields.io/badge/MkDocs-Material-blue.svg)](https://squidfunk.github.io/mkdocs-material/)
[![i18n](https://img.shields.io/badge/i18n-EN%20%7C%20JA-green.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Multi-language documentation for Hexabase.AI - Multi-tenant Kubernetes as a Service with AIOps.

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Git
- Node.js 16+ (optional, for advanced customization)

### 1. Clone and Setup

```bash
git clone https://github.com/KoribanDev/hexabase-ai-docs.git
cd hexabase-ai-docs
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 2. Local Development

```bash
# Start development server (English)
./scripts/serve.sh en

# Start development server (Japanese)
./scripts/serve.sh ja

# Start both languages
./scripts/serve-all.sh

# Or manually:
mkdocs serve --config-file mkdocs.yml      # English
mkdocs serve --config-file mkdocs.ja.yml   # Japanese
```

Visit: 
- English: http://localhost:8000
- Japanese: http://localhost:8000 (when using serve.sh ja)

### 3. Build Documentation

```bash
# Build static site
./scripts/build.sh

# Or manually:
mkdocs build
```

## 📖 Documentation Structure

```
docs/
├── index.md                    # English homepage
├── concept/                    # Core concepts
├── usecases/                   # Use cases and scenarios
├── architecture/               # System architecture
├── rbac/                      # RBAC and security
├── nodes/                     # Node management
├── applications/              # Application deployment
├── cicd/                      # CI/CD pipelines
├── cronjobs/                  # Scheduled jobs
├── functions/                 # Serverless functions
├── observability/             # Monitoring and logging
├── backups/                   # Backup strategies
├── security/                  # Security policies
├── aiops/                     # AI Operations
├── api/                       # API reference
├── sdk/                       # SDKs and tools
├── users/                     # User examples
└── ja/                        # Japanese translations
    ├── index.md
    ├── concept/
    ├── usecases/
    └── ...                    # Mirror structure
```

## 🌐 Multi-Language Support

This documentation supports English and Japanese:

- **English**: `/` (default)
- **Japanese**: `/ja/`

### Language Features

- ✅ Automatic navigation translation
- ✅ Language-specific content
- ✅ SEO-optimized URLs
- ✅ Fallback to English for missing content

## 🛠️ Local Development

### Manual Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start development server
mkdocs serve --dev-addr localhost:8000
```

### Development Commands

```bash
# Install dependencies
./scripts/install-deps.sh

# Start development server (English)
./scripts/serve.sh en

# Start development server (Japanese)  
./scripts/serve.sh ja

# Start both languages
./scripts/serve-all.sh

# Build documentation
./scripts/build.sh

# Deploy to GitHub Pages
./scripts/deploy.sh

# Clean build artifacts
./scripts/clean.sh
```

## 🐳 Docker Development

### Quick Start with Docker

```bash
# Build and run with Docker
docker-compose up -d

# Or manually:
docker build -t hexabase-docs .
docker run -p 8000:8000 hexabase-docs
```

### Docker Files

- `Dockerfile` - Production-ready container
- `docker-compose.yml` - Development environment
- `docker-compose.prod.yml` - Production deployment

## ☸️ Kubernetes Deployment

### Production Deployment

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/

# Or use Helm
helm install hexabase-docs ./helm/hexabase-docs
```

### Kubernetes Resources

- **Deployment**: Multi-replica documentation service
- **Service**: Load balancer and service discovery
- **Ingress**: HTTPS termination and routing
- **ConfigMap**: Environment-specific configuration
- **HPA**: Horizontal Pod Autoscaler

### Environment Configuration

Create environment-specific configurations:

```bash
# Development
kubectl apply -f k8s/overlays/dev/

# Staging
kubectl apply -f k8s/overlays/staging/

# Production
kubectl apply -f k8s/overlays/prod/
```

## 📝 Contributing

### Adding Content

1. **English Content**: Add to `docs/`
2. **Japanese Content**: Add to `docs/ja/`
3. **Navigation**: Update `mkdocs.yml` nav_translations

### Translation Workflow

```bash
# 1. Create English content
echo "# New Page" > docs/new-page.md

# 2. Add to navigation (mkdocs.yml)
# 3. Create Japanese translation
echo "# 新しいページ" > docs/ja/new-page.md

# 4. Update nav_translations in mkdocs.yml
```

### Writing Guidelines

- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Follow existing structure
- Test all links and examples

## 🚀 Production Deployment

### GitHub Pages (Recommended)

```bash
# Automatic deployment on push to main
git push origin main

# Manual deployment
./scripts/deploy.sh
```

### Custom Server

```bash
# Build and deploy
./scripts/build.sh
rsync -av site/ user@server:/var/www/docs/
```

### CDN Integration

Optimize for global distribution:

- CloudFlare for caching and performance
- AWS CloudFront for enterprise deployments
- Google Cloud CDN for cost-effective scaling

## 🔧 Configuration

### MkDocs Configuration

Key configuration files:

- `mkdocs.yml` - Main configuration with i18n plugin
- `mkdocs.en.yml` - English-specific (legacy)
- `mkdocs.ja.yml` - Japanese-specific (legacy)

### Theme Customization

- `overrides/` - Theme customizations
- `overrides/stylesheets/extra.css` - Custom styles
- `overrides/main.html` - Template overrides

### Plugin Configuration

Current plugins:

- `mkdocs-static-i18n` - Multi-language support
- `mkdocs-material` - Material Design theme
- `mkdocs-awesome-pages-plugin` - Enhanced navigation
- `mkdocs-redirects` - URL redirects
- `mkdocs-minify-plugin` - Asset minification
- `mkdocs-git-revision-date-localized-plugin` - Git integration

## 📊 Analytics and Monitoring

### Google Analytics

Add your tracking ID to `mkdocs.yml`:

```yaml
extra:
  analytics:
    provider: google
    property: GA_MEASUREMENT_ID
```

### Performance Monitoring

- Lighthouse CI integration
- Core Web Vitals tracking
- CDN performance metrics

## 🔒 Security

### Content Security Policy

```yaml
extra:
  security:
    csp: "default-src 'self'; script-src 'self' 'unsafe-inline'"
```

### Access Control

For private deployments:

- OAuth2 Proxy integration
- Kubernetes RBAC
- Network policies

## 🐛 Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Check Python version
   python --version  # Should be 3.8+
   
   # Reinstall dependencies
   pip install -r requirements.txt --force-reinstall
   ```

2. **Missing Translations**
   ```bash
   # Check nav_translations in mkdocs.yml
   # Ensure Japanese files exist in docs/ja/
   ```

3. **Plugin Conflicts**
   ```bash
   # Check plugin order in mkdocs.yml
   # i18n should come before awesome-pages
   ```

### Debug Mode

```bash
# Enable verbose logging
mkdocs serve --verbose

# Check configuration
mkdocs config
```

## 📞 Support

- **Documentation Issues**: [GitHub Issues](https://github.com/KoribanDev/hexabase-ai-docs/issues)
- **Hexabase.AI Platform**: [Support Portal](https://support.hexabase.ai)
- **Community**: [Discord](https://discord.gg/hexabase)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Acknowledgments

- [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) for the excellent theme
- [mkdocs-static-i18n](https://github.com/ultrabug/mkdocs-static-i18n) for i18n support
- Contributors and translators

---

Made with ❤️ by the Hexabase.AI Team