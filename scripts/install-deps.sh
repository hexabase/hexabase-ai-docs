#!/bin/bash
set -e

echo "📦 Installing Hexabase.AI Documentation Dependencies"

# Check if requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    echo "📝 Creating requirements.txt..."
    cat > requirements.txt << EOF
mkdocs>=1.6.0
mkdocs-material>=9.6.0
mkdocs-static-i18n>=1.3.0
mkdocs-awesome-pages-plugin>=2.10.0
mkdocs-redirects>=1.2.0
mkdocs-minify-plugin>=0.8.0
mkdocs-git-revision-date-localized-plugin>=1.4.0
EOF
fi

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
pip install -r requirements.txt

# Install Node.js dependencies (optional)
if command -v npm > /dev/null 2>&1; then
    if [ -f "package.json" ]; then
        echo "📦 Installing Node.js dependencies..."
        npm install
    fi
fi

echo "✅ Dependencies installed successfully!"