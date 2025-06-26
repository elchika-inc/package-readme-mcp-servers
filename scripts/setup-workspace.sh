#!/bin/bash

set -e

echo "🚀 Setting up Package README MCP Servers monorepo..."

# Install root dependencies
echo "📦 Installing root dependencies..."
npm install

# Install workspace dependencies
echo "📦 Installing workspace dependencies..."
npm install --workspaces

# Build all projects
echo "🔨 Building all projects..."
npm run build

# Run tests
echo "🧪 Running tests..."
npm run test

echo "✅ Monorepo setup complete!"
echo ""
echo "Available commands:"
echo "  npm run build           - Build all packages"
echo "  npm run test            - Run all tests"
echo "  npm run lint            - Lint all packages"
echo "  npm run start:core      - Start core orchestrator"
echo "  npm run start:npm       - Start npm server"
echo "  npm run start:pip       - Start pip server"
echo "  ... (see package.json for all start commands)"