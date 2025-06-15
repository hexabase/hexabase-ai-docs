# LLM Integration

Hexabase.AI provides flexible Large Language Model (LLM) integration to power its AI-driven features, supporting both self-hosted open-source models and external commercial LLM APIs.

## Overview

The platform's LLM integration is designed to give organizations complete control over their AI infrastructure while maintaining flexibility to use the best models for their specific needs.

## Supported LLM Options

### 1. Self-Hosted Open Source Models

Run LLMs directly within your infrastructure for maximum privacy and control.

**Supported Models:**
- **Llama 2/3**: Meta's open-source foundation models
- **Mistral**: High-performance open models
- **CodeLlama**: Specialized for code generation
- **Custom Models**: Support for GGUF format models

**Benefits:**
- Complete data privacy - no data leaves your infrastructure
- No per-token costs
- Full control over model selection and updates
- Compliance with strict data residency requirements

### 2. Commercial LLM APIs

Integrate with leading commercial LLM providers for access to state-of-the-art models.

**Supported Providers:**
- **OpenAI** (GPT-4, GPT-3.5)
- **Anthropic** (Claude)
- **Google** (PaLM, Gemini)
- **Azure OpenAI Service**

**Benefits:**
- Access to cutting-edge models
- No infrastructure management
- Automatic model updates
- Higher performance for complex tasks

## Configuration Levels

### Organization-Level Configuration

Set default LLM preferences for your entire organization:

```yaml
llm_config:
  provider: "ollama"  # or "openai", "anthropic", etc.
  model: "llama3:8b"
  temperature: 0.7
  max_tokens: 4096
```

### Workspace-Level Configuration

Override organization defaults for specific workspaces:

```yaml
workspaces:
  production:
    llm_override:
      provider: "openai"
      model: "gpt-4"
      # More conservative settings for production
      temperature: 0.3
  development:
    llm_override:
      provider: "ollama"
      model: "codellama:13b"
```

## Technical Architecture

### Self-Hosted Model Deployment

```
┌─────────────────────┐
│   GPU/CPU Nodes     │
│ (node-role=llm)     │
├─────────────────────┤
│  Ollama DaemonSet   │
│  - Model Management │
│  - Inference Engine │
└─────────────────────┘
          ↓
┌─────────────────────┐
│   AIOps Service     │
│  - Request Router   │
│  - Context Manager  │
│  - Response Cache   │
└─────────────────────┘
```

### API Integration Architecture

```
┌─────────────────────┐
│   AIOps Service     │
├─────────────────────┤
│  LLM Gateway        │
│  - API Management   │
│  - Rate Limiting    │
│  - Cost Tracking    │
└─────────────────────┘
          ↓
┌─────────────────────┐
│  External LLM APIs  │
│  - OpenAI          │
│  - Anthropic       │
│  - Google          │
└─────────────────────┘
```

## Security and Privacy

### Data Protection

1. **Encryption**: All LLM communications encrypted in transit
2. **Sanitization**: Automatic removal of sensitive data before processing
3. **Audit Logs**: Complete audit trail of all LLM interactions
4. **Access Control**: RBAC-based access to LLM features

### Compliance Features

- **Data Residency**: Keep all data within your infrastructure
- **GDPR Compliance**: Right to deletion and data portability
- **HIPAA Ready**: Healthcare-compliant configurations available
- **SOC 2**: Audit-ready logging and controls

## Performance Optimization

### Caching Strategy

- Response caching for common queries
- Embedding cache for semantic search
- Model warm-up for faster first responses

### Resource Management

- **GPU Allocation**: Dedicated GPU nodes for model inference
- **Auto-scaling**: Dynamic scaling based on request load
- **Queue Management**: Priority queuing for critical requests

## Use Cases by Model Type

### When to Use Self-Hosted Models

- Sensitive data processing
- Predictable costs at scale
- Specific compliance requirements
- Custom model fine-tuning needs

### When to Use Commercial APIs

- Need for latest model capabilities
- Variable or low-volume usage
- Rapid prototyping
- Complex reasoning tasks

## Configuration Examples

### Basic Self-Hosted Setup

```bash
# Enable LLM features
hks llm enable --provider ollama

# Install a model
hks llm install llama3:8b

# Configure organization defaults
hks org set-llm --model llama3:8b --temperature 0.7
```

### Commercial API Setup

```bash
# Configure OpenAI integration
hks llm enable --provider openai

# Set API credentials (stored securely)
hks secret create openai-api-key --from-literal=key=sk-...

# Configure model preferences
hks workspace set-llm --model gpt-4 --max-tokens 8192
```

## Monitoring and Observability

### Metrics Tracked

- Request latency and throughput
- Token usage and costs
- Model performance metrics
- Error rates and types

### Dashboards Available

- LLM usage overview
- Cost analysis (for API models)
- Performance trends
- User interaction patterns

## Best Practices

1. **Start with Self-Hosted**: Begin with open-source models for testing
2. **Monitor Costs**: Track API usage to control expenses
3. **Optimize Prompts**: Well-crafted prompts improve results and reduce costs
4. **Cache Strategically**: Use caching for repetitive queries
5. **Regular Reviews**: Periodically review model performance and costs

## Troubleshooting

### Common Issues

1. **Slow Responses**: Check GPU allocation and model size
2. **API Errors**: Verify credentials and rate limits
3. **Quality Issues**: Adjust temperature and prompt engineering
4. **Cost Overruns**: Review usage patterns and implement limits

### Getting Help

- Check AIOps logs: `hks logs -n hexabase-aiops`
- Review model metrics in dashboards
- Contact support with correlation IDs