#!/bin/bash
set -e

echo "🚀 Starting Multi-language Development Environment"

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

# Function to cleanup background processes
cleanup() {
    echo "🛑 Stopping development servers..."
    kill $(jobs -p) 2>/dev/null || true
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGINT SIGTERM

echo "🏗️ Building multi-language site first..."
./scripts/build.sh

echo ""
echo "🌐 Starting HTTP server for built site..."
echo "📖 English Documentation: http://localhost:7900"
echo "🇯🇵 Japanese Documentation: http://localhost:7900/ja/"
echo ""
echo "Press Ctrl+C to stop the server"

# Start HTTP server from the site directory
cd site && python -m http.server 7900