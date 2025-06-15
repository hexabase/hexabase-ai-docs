#!/bin/bash
set -e

echo "🚀 Deploying Hexabase.AI Documentation"

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Build documentation
echo "🏗️ Building documentation..."
mkdocs build --clean

# Deploy to GitHub Pages
echo "📤 Deploying to GitHub Pages..."
mkdocs gh-deploy --force

echo "✅ Deployment complete!"
echo "🌐 Documentation available at: https://koribandev.github.io/hexabase-ai-docs/"