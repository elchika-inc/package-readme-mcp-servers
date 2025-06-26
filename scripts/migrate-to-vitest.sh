#!/bin/bash

# Package README MCP Servers - Migrate to Vitest Script
# This script migrates all MCP servers from bun test to vitest

set -e  # Exit on any error

echo "🔧 Migrating all MCP servers to vitest..."
echo ""

# Array of all MCP server directories (excluding shared-base and core which may have different setups)
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

# Function to migrate a single server
migrate_server() {
    local server_dir=$1
    local server_num=$2
    
    echo "🔧 [$server_num/$total_servers] Migrating $server_dir..."
    
    # Check if directory exists
    if [ ! -d "$server_dir" ]; then
        echo "❌ Error: Directory $server_dir not found"
        return 1
    fi
    
    # Enter the server directory
    cd "$server_dir"
    
    # 1. Update package.json to replace jest with vitest
    if [ -f "package.json" ]; then
        # Replace jest with vitest in devDependencies
        sed -i.bak 's/"jest": "[^"]*"/"vitest": "^2.0.0",\n    "@vitest\/ui": "^2.0.0",/' package.json
        
        # Update test script to use vitest
        sed -i.bak 's/"test": "bun test"/"test": "vitest run"/' package.json
        
        # Remove backup file
        rm -f package.json.bak
        
        echo "   ✅ Updated package.json"
    else
        echo "   ❌ Error: package.json not found"
        cd ..
        return 1
    fi
    
    # 2. Create vitest.config.ts
    cat > vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    include: ['tests/**/*.{test,spec}.{js,ts}'],
    exclude: ['node_modules', 'dist'],
  },
});
EOF
    echo "   ✅ Created vitest.config.ts"
    
    # 3. Update test files to use vitest instead of bun:test
    if [ -d "tests" ]; then
        find tests -name "*.test.ts" -type f | while read -r test_file; do
            # Replace bun:test imports with vitest
            sed -i.bak 's/from "bun:test"/from "vitest"/' "$test_file"
            
            # Update require paths to point to dist directory
            sed -i.bak 's|require('\''../src/|require('\''../dist/src/|g' "$test_file"
            sed -i.bak 's|require('\''../../src/|require('\''../../dist/src/|g' "$test_file"
            
            # Remove backup file
            rm -f "$test_file.bak"
        done
        echo "   ✅ Updated test files"
    else
        echo "   ⚠️  Warning: tests directory not found"
    fi
    
    # 4. Install vitest dependencies
    if ! bun install > /dev/null 2>&1; then
        echo "   ❌ Error: Failed to install dependencies"
        cd ..
        return 1
    fi
    echo "   ✅ Installed vitest dependencies"
    
    # Go back to parent directory
    cd ..
    
    echo "   ✅ Migration completed for $server_dir"
    echo ""
    return 0
}

# Function to run migrations
run_migrations() {
    echo "📝 Running migrations..."
    echo ""
    
    # Track successful and failed migrations
    declare -a successful_migrations=()
    declare -a failed_migrations=()
    
    # Migrate each server
    for server in "${servers[@]}"; do
        current_server=$((current_server + 1))
        
        if migrate_server "$server" "$current_server"; then
            successful_migrations+=("$server")
        else
            failed_migrations+=("$server")
            echo "❌ Migration failed for $server"
            echo ""
        fi
    done
    
    # Summary
    echo "📊 Migration Summary:"
    echo "==================="
    echo "✅ Completed: ${#successful_migrations[@]}/$total_servers"
    for server in "${successful_migrations[@]}"; do
        echo "   ✓ $server"
    done
    
    if [ ${#failed_migrations[@]} -gt 0 ]; then
        echo ""
        echo "❌ Failed: ${#failed_migrations[@]}/$total_servers"
        for server in "${failed_migrations[@]}"; do
            echo "   ✗ $server"
        done
        echo ""
        echo "❌ Some migrations failed. Please check the errors above."
        return 1
    else
        echo ""
        echo "🎉 All migrations completed successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Run tests for each server: ./scripts/test-all.sh"
        echo "   2. Fix any remaining test issues"
        echo "   3. Commit the changes when ready"
        return 0
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0"
    echo ""
    echo "This script migrates all MCP servers from bun test to vitest"
    echo ""
    echo "What it does:"
    echo "  1. Updates package.json to replace jest with vitest"
    echo "  2. Creates vitest.config.ts configuration"
    echo "  3. Updates test files to use vitest imports"
    echo "  4. Updates require paths to use dist directory"
    echo "  5. Installs vitest dependencies"
}

# Check if help was requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Main execution
echo "Found $total_servers MCP servers to migrate"
echo ""

# Check if bun is available
if ! command -v bun &> /dev/null; then
    echo "❌ Error: bun is not installed or not in PATH"
    echo "Please install bun: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# Run migrations
run_migrations