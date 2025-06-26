#!/bin/bash

# Package README MCP Servers - Install All Dependencies Script
# This script installs dependencies for all MCP servers

set -e  # Exit on any error

echo "📦 Installing dependencies for all MCP servers..."
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
    "shared-base"
)

# Counter for tracking progress
total_servers=${#servers[@]}
current_server=0

# Function to install dependencies for a single server
install_deps() {
    local server_dir=$1
    local server_num=$2
    
    echo "📦 [$server_num/$total_servers] Installing dependencies for $server_dir..."
    
    # Check if directory exists
    if [ ! -d "$server_dir" ]; then
        echo "❌ Error: Directory $server_dir not found"
        return 1
    fi
    
    # Enter the server directory
    cd "$server_dir"
    
    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        echo "   ❌ Error: package.json not found"
        cd ..
        return 1
    fi
    
    # Install dependencies
    if ! bun install > /dev/null 2>&1; then
        echo "   ❌ Error: Failed to install dependencies"
        cd ..
        return 1
    fi
    
    echo "   ✅ Dependencies installed successfully"
    
    # Go back to parent directory
    cd ..
    
    echo ""
    return 0
}

# Function to run installations
run_installations() {
    echo "📦 Running dependency installations..."
    echo ""
    
    # Track successful and failed installations
    declare -a successful_installs=()
    declare -a failed_installs=()
    
    # Install for each server
    for server in "${servers[@]}"; do
        current_server=$((current_server + 1))
        
        if install_deps "$server" "$current_server"; then
            successful_installs+=("$server")
        else
            failed_installs+=("$server")
            echo "❌ Installation failed for $server"
            echo ""
        fi
    done
    
    # Summary
    echo "📊 Installation Summary:"
    echo "======================"
    echo "✅ Successful: ${#successful_installs[@]}/$total_servers"
    for server in "${successful_installs[@]}"; do
        echo "   ✓ $server"
    done
    
    if [ ${#failed_installs[@]} -gt 0 ]; then
        echo ""
        echo "❌ Failed: ${#failed_installs[@]}/$total_servers"
        for server in "${failed_installs[@]}"; do
            echo "   ✗ $server"
        done
        echo ""
        echo "❌ Some installations failed. Please check the errors above."
        return 1
    else
        echo ""
        echo "🎉 All dependencies installed successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Run build tests: ./scripts/build-all.sh"
        echo "   2. Run test suite: ./scripts/test-all.sh"
        echo "   3. Commit the changes when ready"
        return 0
    fi
}

# Main execution
echo "Found $total_servers packages to install dependencies for"
echo ""

# Check if bun is available
if ! command -v bun &> /dev/null; then
    echo "❌ Error: bun is not installed or not in PATH"
    echo "Please install bun: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# Run installations
run_installations