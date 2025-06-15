#!/bin/bash
set -e

echo "🚀 Setting up Hexabase.AI Documentation"

# Check Python version
python_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
required_version="3.8"

if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" = "$required_version" ]; then 
    echo "✅ Python $python_version detected"
else
    echo "❌ Python 3.8+ required. Found: $python_version"
    exit 1
fi

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️ Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📚 Installing dependencies..."
pip install mkdocs-material
pip install mkdocs-static-i18n
pip install mkdocs-awesome-pages-plugin
pip install mkdocs-redirects
pip install mkdocs-minify-plugin
pip install mkdocs-git-revision-date-localized-plugin

# Create requirements.txt
echo "📝 Creating requirements.txt..."
pip freeze > requirements.txt

# Make scripts executable
echo "🔐 Making scripts executable..."
chmod +x scripts/*.sh

# Test build
echo "🏗️ Testing build..."
mkdocs build --clean

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Activate virtual environment: source venv/bin/activate"
echo "  2. Start development server: ./scripts/dev.sh"
echo "  3. Open browser: http://localhost:8000"
echo ""
echo "Happy documenting! 📖"