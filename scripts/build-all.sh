#!/bin/bash

# Package README MCP Servers - Build All Script
# This script builds all MCP servers to verify they compile correctly

set -e  # Exit on any error

echo "🏗️  Testing build process for all MCP servers..."
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

# Function to build a single server
build_server() {
    local server_dir=$1
    current_server=$((current_server + 1))
    
    echo "🔨 [$current_server/$total_servers] Building $server_dir..."
    
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
    
    # Install dependencies
    echo "   📥 Installing dependencies..."
    if ! bun install; then
        echo "❌ Error: Failed to install dependencies for $server_dir"
        cd ..
        return 1
    fi
    
    # Clean previous build
    echo "   🧹 Cleaning previous build..."
    bun run clean 2>/dev/null || true  # Ignore error if clean script doesn't exist
    
    # Build
    echo "   🏗️  Building..."
    if ! bun run build; then
        echo "❌ Error: Build failed for $server_dir"
        cd ..
        return 1
    fi
    
    # Check if dist directory was created
    if [ ! -d "dist" ]; then
        echo "❌ Error: dist directory not created for $server_dir"
        cd ..
        return 1
    fi
    
    # Check if main entry point exists
    if [ ! -f "dist/src/index.js" ] && [ ! -f "dist/index.js" ]; then
        echo "❌ Error: Main entry point not found in dist for $server_dir"
        cd ..
        return 1
    fi
    
    # Go back to parent directory
    cd ..
    
    echo "   ✅ Successfully built $server_dir"
    echo ""
    return 0
}

# Main execution
echo "Found $total_servers MCP servers to build"
echo ""

# Track successful and failed builds
declare -a successful_builds=()
declare -a failed_builds=()

# Build each server
for server in "${servers[@]}"; do
    if build_server "$server"; then
        successful_builds+=("$server")
    else
        failed_builds+=("$server")
        echo "❌ Failed to build $server"
        echo ""
    fi
done

# Summary
echo "📊 Build Summary:"
echo "================="
echo "✅ Successful: ${#successful_builds[@]}/$total_servers"
for server in "${successful_builds[@]}"; do
    echo "   ✓ $server"
done

if [ ${#failed_builds[@]} -gt 0 ]; then
    echo ""
    echo "❌ Failed: ${#failed_builds[@]}/$total_servers"
    for server in "${failed_builds[@]}"; do
        echo "   ✗ $server"
    done
    echo ""
    echo "❌ Some builds failed. Please check the errors above."
    exit 1
else
    echo ""
    echo "🎉 All MCP servers built successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Test individual servers: cd [server-dir] && bun run start"
    echo "   2. Run publish script: ./publish-all.sh"
    echo "   3. Test installation after publishing"
fi