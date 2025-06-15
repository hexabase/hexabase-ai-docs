#!/bin/bash
set -e

echo "🧹 Cleaning Hexabase.AI Documentation Build Artifacts"

# Remove build artifacts
echo "🗑️ Removing build artifacts..."
rm -rf site/
rm -rf .mkdocs_cache/

# Remove Python cache
echo "🐍 Removing Python cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

# Remove Node.js artifacts (if present)
if [ -d "node_modules" ]; then
    echo "📦 Removing Node.js artifacts..."
    rm -rf node_modules/
fi

echo "✅ Cleanup complete!"