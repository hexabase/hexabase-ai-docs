#!/bin/bash
set -e

echo "🚀 Starting Hexabase.AI Documentation Development Server"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Run ./scripts/setup.sh first."
    exit 1
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Check if dependencies are installed
if ! pip show mkdocs-material > /dev/null 2>&1; then
    echo "📦 Installing dependencies..."
    pip install -r requirements.txt
fi

# Check for language parameter
LANG=${1:-"en"}

if [ "$LANG" = "ja" ]; then
    echo "🇯🇵 Starting Japanese development server..."
    echo "📖 Japanese Documentation: http://localhost:8000"
    mkdocs serve --config-file mkdocs.ja.yml --dev-addr 0.0.0.0:8000
elif [ "$LANG" = "en" ]; then
    echo "🇺🇸 Starting English development server..."
    echo "📖 English Documentation: http://localhost:8000"
    mkdocs serve --config-file mkdocs.yml --dev-addr 0.0.0.0:8000
else
    echo "❌ Invalid language '$LANG'. Use 'en' or 'ja'"
    echo "Usage: ./serve.sh [en|ja]"
    echo "  ./serve.sh en  - English documentation"
    echo "  ./serve.sh ja  - Japanese documentation"
    exit 1
fi