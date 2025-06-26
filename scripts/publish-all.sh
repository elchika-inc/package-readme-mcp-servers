#!/bin/bash

# Package README MCP Servers - Publish All Script
# This script builds and publishes all MCP servers to npm

set -e  # Exit on any error

echo "🚀 Starting publication of all MCP servers..."
echo ""

# Array of all MCP server directories
declare -a servers=(
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

# Counter for tracking progress
total_servers=${#servers[@]}
current_server=0

# Function to publish a single server
publish_server() {
    local server_dir=$1
    current_server=$((current_server + 1))
    
    echo "📦 [$current_server/$total_servers] Publishing $server_dir..."
    
    # Check if directory exists
    if [ ! -d "$server_dir" ]; then
        echo "❌ Error: Directory $server_dir not found"
        return 1
    fi
    
    # Enter the server directory
    cd "$server_dir"
    
    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        echo "❌ Error: package.json not found in $server_dir"
        cd ..
        return 1
    fi
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "   📥 Installing dependencies..."
        bun install
    fi
    
    # Clean and build
    echo "   🏗️  Building..."
    bun run clean 2>/dev/null || true  # Ignore error if clean script doesn't exist
    bun run build
    
    # Publish to npm
    echo "   🚀 Publishing to npm..."
    bun run bun:publish
    
    # Go back to parent directory
    cd ..
    
    echo "   ✅ Successfully published $server_dir"
    echo ""
}

# Main execution
echo "Found $total_servers MCP servers to publish"
echo ""

# Confirm before proceeding
read -p "Do you want to proceed with publishing all servers? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Publication cancelled"
    exit 1
fi

echo ""
echo "🔄 Starting publication process..."
echo ""

# Track successful and failed publications
declare -a successful_servers=()
declare -a failed_servers=()

# Publish each server
for server in "${servers[@]}"; do
    if publish_server "$server"; then
        successful_servers+=("$server")
    else
        failed_servers+=("$server")
        echo "❌ Failed to publish $server"
        echo ""
    fi
done

# Summary
echo "📊 Publication Summary:"
echo "======================"
echo "✅ Successful: ${#successful_servers[@]}/$total_servers"
for server in "${successful_servers[@]}"; do
    echo "   ✓ $server"
done

if [ ${#failed_servers[@]} -gt 0 ]; then
    echo ""
    echo "❌ Failed: ${#failed_servers[@]}/$total_servers"
    for server in "${failed_servers[@]}"; do
        echo "   ✗ $server"
    done
    echo ""
    echo "❌ Some publications failed. Please check the errors above."
    exit 1
else
    echo ""
    echo "🎉 All MCP servers published successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Verify packages are available on npmjs.com"
    echo "   2. Test installation: bunx @elchika-inc/[package-name]"
    echo "   3. Update documentation if needed"
fi