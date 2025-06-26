#!/bin/bash

# Package README MCP Servers - Individual Publish Script
# Usage: ./publish-individual.sh [server-name]

set -e  # Exit on any error

# Function to show usage
show_usage() {
    echo "Usage: $0 [server-name]"
    echo ""
    echo "Available servers:"
    echo "  cargo-package-readme-mcp-server"
    echo "  cocoapods-package-readme-mcp-server"
    echo "  composer-package-readme-mcp-server"
    echo "  conan-package-readme-mcp-server"
    echo "  cpan-package-readme-mcp-server"
    echo "  cran-package-readme-mcp-server"
    echo "  docker-hub-readme-mcp-server"
    echo "  gem-package-readme-mcp-server"
    echo "  helm-package-readme-mcp-server"
    echo "  maven-package-readme-mcp-server"
    echo "  npm-package-readme-mcp-server"
    echo "  nuget-package-readme-mcp-server"
    echo "  pip-package-readme-mcp-server"
    echo "  swift-package-readme-mcp-server"
    echo "  vcpkg-package-readme-mcp-server"
    echo "  package-readme-core-mcp-server"
    echo ""
    echo "Example: $0 npm-package-readme-mcp-server"
}

# Check if server name is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: No server name provided"
    echo ""
    show_usage
    exit 1
fi

server_dir=$1

# Validate server name
declare -a valid_servers=(
    "cargo-package-readme-mcp-server"
    "cocoapods-package-readme-mcp-server"
    "composer-package-readme-mcp-server"
    "conan-package-readme-mcp-server"
    "cpan-package-readme-mcp-server"
    "cran-package-readme-mcp-server"
    "docker-hub-readme-mcp-server"
    "gem-package-readme-mcp-server"
    "helm-package-readme-mcp-server"
    "maven-package-readme-mcp-server"
    "npm-package-readme-mcp-server"
    "nuget-package-readme-mcp-server"
    "pip-package-readme-mcp-server"
    "swift-package-readme-mcp-server"
    "vcpkg-package-readme-mcp-server"
    "package-readme-core-mcp-server"
)

# Check if provided server name is valid
if [[ ! " ${valid_servers[@]} " =~ " ${server_dir} " ]]; then
    echo "❌ Error: Invalid server name '$server_dir'"
    echo ""
    show_usage
    exit 1
fi

echo "🚀 Publishing $server_dir..."
echo ""

# Check if directory exists
if [ ! -d "$server_dir" ]; then
    echo "❌ Error: Directory $server_dir not found"
    exit 1
fi

# Enter the server directory
cd "$server_dir"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found in $server_dir"
    exit 1
fi

# Show package info
echo "📋 Package Information:"
echo "   Name: $(node -p "require('./package.json').name")"
echo "   Version: $(node -p "require('./package.json').version")"
echo "   Description: $(node -p "require('./package.json').description")"
echo ""

# Confirm before proceeding
read -p "Do you want to proceed with publishing this server? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Publication cancelled"
    exit 1
fi

echo ""
echo "🔄 Starting publication process..."
echo ""

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📥 Installing dependencies..."
    bun install
    echo ""
fi

# Clean and build
echo "🏗️  Building..."
bun run clean 2>/dev/null || true  # Ignore error if clean script doesn't exist
bun run build
echo ""

# Show what will be published
echo "📦 Files to be published:"
bun pack --dry-run
echo ""

# Final confirmation
read -p "Proceed with npm publish? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Publication cancelled"
    exit 1
fi

# Publish to npm
echo "🚀 Publishing to npm..."
bun run bun:publish

echo ""
echo "🎉 Successfully published $server_dir!"
echo ""
echo "📝 Next steps:"
echo "   1. Verify package is available: https://www.npmjs.com/package/@elchika-inc/$server_dir"
echo "   2. Test installation: bunx @elchika-inc/$server_dir"
echo "   3. Test in MCP client configuration"