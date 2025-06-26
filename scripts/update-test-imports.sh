#!/bin/bash

# Package README MCP Servers - Update Test Imports Script
# This script updates test files to use vitest and correct import paths

set -e  # Exit on any error

echo "🔧 Updating test imports for all MCP servers..."
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
)

# Counter for tracking progress
total_servers=${#servers[@]}
current_server=0

# Function to update test files for a single server
update_tests() {
    local server_dir=$1
    local server_num=$2
    
    echo "🔧 [$server_num/$total_servers] Updating test imports for $server_dir..."
    
    # Check if directory exists
    if [ ! -d "$server_dir" ]; then
        echo "❌ Error: Directory $server_dir not found"
        return 1
    fi
    
    # Enter the server directory
    cd "$server_dir"
    
    # Check if tests directory exists
    if [ ! -d "tests" ]; then
        echo "   ⚠️  Warning: tests directory not found"
        cd ..
        return 0
    fi
    
    # Update all test files
    find tests -name "*.test.ts" -type f | while read -r test_file; do
        echo "   📝 Updating $test_file"
        
        # 1. Replace bun:test imports with vitest
        sed -i.bak 's/from "bun:test"/from "vitest"/g' "$test_file"
        
        # 2. Update require paths to point to dist directory (if not already done)
        sed -i.bak 's|require('\''../src/|require('\''../dist/src/|g' "$test_file"
        sed -i.bak 's|require('\''../../src/|require('\''../../dist/src/|g' "$test_file"
        sed -i.bak 's|require('\''../../../src/|require('\''../../../dist/src/|g' "$test_file"
        
        # 3. Fix any import paths for ES modules
        sed -i.bak 's|from "../src/|from "../dist/src/|g' "$test_file"
        sed -i.bak 's|from "../../src/|from "../../dist/src/|g' "$test_file"
        sed -i.bak 's|from "../../../src/|from "../../../dist/src/|g' "$test_file"
        
        # Remove backup file
        rm -f "$test_file.bak"
    done
    
    echo "   ✅ Test files updated"
    
    # Go back to parent directory
    cd ..
    
    echo ""
    return 0
}

# Function to run updates
run_updates() {
    echo "📝 Running test import updates..."
    echo ""
    
    # Track successful and failed updates
    declare -a successful_updates=()
    declare -a failed_updates=()
    
    # Update each server
    for server in "${servers[@]}"; do
        current_server=$((current_server + 1))
        
        if update_tests "$server" "$current_server"; then
            successful_updates+=("$server")
        else
            failed_updates+=("$server")
            echo "❌ Update failed for $server"
            echo ""
        fi
    done
    
    # Summary
    echo "📊 Update Summary:"
    echo "================="
    echo "✅ Updated: ${#successful_updates[@]}/$total_servers"
    for server in "${successful_updates[@]}"; do
        echo "   ✓ $server"
    done
    
    if [ ${#failed_updates[@]} -gt 0 ]; then
        echo ""
        echo "❌ Failed: ${#failed_updates[@]}/$total_servers"
        for server in "${failed_updates[@]}"; do
            echo "   ✗ $server"
        done
        echo ""
        echo "❌ Some updates failed. Please check the errors above."
        return 1
    else
        echo ""
        echo "🎉 All test imports updated successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Build all servers: ./scripts/build-all.sh"
        echo "   2. Run test suite: ./scripts/test-all.sh"
        echo "   3. Fix any remaining test issues"
        return 0
    fi
}

# Main execution
echo "Found $total_servers MCP servers to update"
echo ""

# Run updates
run_updates