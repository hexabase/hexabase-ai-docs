#!/bin/bash
set -e

echo "🏗️ Building Hexabase.AI Documentation (Multi-language)"

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf site/

# Build English documentation (default)
echo "📚 Building English documentation..."
mkdocs build --clean --config-file mkdocs.yml

# Build Japanese documentation
echo "🇯🇵 Building Japanese documentation..."
mkdocs build --config-file mkdocs.ja.yml --site-dir site/ja

echo "✅ Build complete!"
echo "📁 Static files generated in: ./site/"
echo "🌐 English site: ./site/"
echo "🇯🇵 Japanese site: ./site/ja/"
echo ""
echo "To serve locally:"
echo "  cd site && python -m http.server 8000"
echo "  English: http://localhost:8000"
echo "  Japanese: http://localhost:8000/ja/"