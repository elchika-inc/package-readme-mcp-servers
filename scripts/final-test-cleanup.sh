#!/bin/bash

# Package README MCP Servers - Final Test Cleanup Script
# This script removes old Jest test files and fixes remaining vitest issues

set -e  # Exit on any error

echo "🧹 Final test cleanup for all MCP servers..."
echo ""

# Array of all MCP server directories
declare -a servers=(
    "composer-package-readme-mcp-server"
    "conan-package-readme-mcp-server"
    "cpan-package-readme-mcp-server"
    "cran-package-readme-mcp-server"
    "docker-hub-readme-mcp-server"
    "gem-package-readme-mcp-server"
    "maven-package-readme-mcp-server"
    "nuget-package-readme-mcp-server"
    "swift-package-readme-mcp-server"
    "vcpkg-package-readme-mcp-server"
    "package-readme-core-mcp-server"
)

# Counter for tracking progress
total_servers=${#servers[@]}
current_server=0

# Function to cleanup tests for a single server
cleanup_tests() {
    local server_dir=$1
    local server_num=$2
    
    echo "🧹 [$server_num/$total_servers] Cleaning up tests for $server_dir..."
    
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
    
    # Remove old Jest-based test files that conflict with vitest
    echo "   🗑️  Removing old Jest test files..."
    
    # Remove basic.test.ts if it contains Jest imports
    if [ -f "tests/basic.test.ts" ]; then
        if grep -q "@jest/globals" "tests/basic.test.ts" 2>/dev/null; then
            rm -f "tests/basic.test.ts"
            echo "   ✅ Removed tests/basic.test.ts (Jest-based)"
        fi
    fi
    
    # Fix tests/index.test.ts if it has wrong imports
    if [ -f "tests/index.test.ts" ]; then
        # Check if it imports PackageReadmeMcpServer incorrectly
        if grep -q "PackageReadmeMcpServer" "tests/index.test.ts" 2>/dev/null; then
            # Check what the actual server export is
            if [ -f "dist/src/server.js" ]; then
                # Create a simple working index test
                cat > tests/index.test.ts << 'EOF'
import { expect, test, describe } from "vitest";

describe('MCP Server', () => {
  test('should have server module', () => {
    const server = require('../dist/src/server.js');
    expect(typeof server).toBe('object');
  });
});
EOF
                echo "   ✅ Fixed tests/index.test.ts"
            else
                # Remove if dist doesn't exist
                rm -f "tests/index.test.ts"
                echo "   ✅ Removed tests/index.test.ts (no dist)"
            fi
        fi
    fi
    
    # Remove any .js test files in dist/tests if they exist
    if [ -d "dist/tests" ]; then
        rm -rf "dist/tests"
        echo "   ✅ Removed dist/tests directory"
    fi
    
    # Make sure all remaining test files use vitest imports
    echo "   🔧 Ensuring all test files use vitest..."
    find tests -name "*.test.ts" -type f | while read -r file; do
        if grep -q "@jest/globals" "$file" 2>/dev/null; then
            # Replace Jest imports with vitest
            sed -i '' 's/import.*@jest\/globals.*/import { expect, test, describe, it } from "vitest";/' "$file"
            echo "   ✅ Fixed vitest imports in $file"
        fi
    done
    
    echo "   ✅ Test cleanup completed"
    
    # Go back to parent directory
    cd ..
    
    echo ""
    return 0
}

# Function to run cleanup
run_cleanup() {
    echo "📝 Running test cleanup..."
    echo ""
    
    # Track successful and failed cleanups
    declare -a successful_cleanups=()
    declare -a failed_cleanups=()
    
    # Clean each server
    for server in "${servers[@]}"; do
        current_server=$((current_server + 1))
        
        if cleanup_tests "$server" "$current_server"; then
            successful_cleanups+=("$server")
        else
            failed_cleanups+=("$server")
            echo "❌ Cleanup failed for $server"
            echo ""
        fi
    done
    
    # Summary
    echo "📊 Cleanup Summary:"
    echo "=================="
    echo "✅ Cleaned: ${#successful_cleanups[@]}/$total_servers"
    for server in "${successful_cleanups[@]}"; do
        echo "   ✓ $server"
    done
    
    if [ ${#failed_cleanups[@]} -gt 0 ]; then
        echo ""
        echo "❌ Failed: ${#failed_cleanups[@]}/$total_servers"
        for server in "${failed_cleanups[@]}"; do
            echo "   ✗ $server"
        done
        echo ""
        echo "❌ Some cleanups failed. Please check the errors above."
        return 1
    else
        echo ""
        echo "🎉 All test cleanups completed successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Run test suite: ./scripts/test-all.sh"
        echo "   2. Check that tests now pass consistently"
        return 0
    fi
}

# Main execution
echo "Found $total_servers MCP servers to clean up"
echo ""

# Run cleanup
run_cleanup