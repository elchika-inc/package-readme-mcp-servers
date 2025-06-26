#!/bin/bash

# Package README MCP Servers - Fix package.json Script
# This script fixes malformed package.json files created by the migration script

set -e  # Exit on any error

echo "🔧 Fixing package.json files for all MCP servers..."
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

# Function to fix a single server's package.json
fix_server() {
    local server_dir=$1
    local server_num=$2
    
    echo "🔧 [$server_num/$total_servers] Fixing $server_dir..."
    
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
    
    # Fix common JSON syntax errors in package.json
    # 1. Remove double commas
    sed -i.bak 's/,,/,/g' package.json
    
    # 2. Fix malformed vitest entries
    sed -i.bak 's/"vitest": "\^2\.0\.0",\n    "@vitest\/ui": "\^2\.0\.0",,/"vitest": "^2.0.0",\n    "@vitest\/ui": "^2.0.0",/' package.json
    
    # 3. Remove trailing commas before closing braces
    sed -i.bak 's/,\s*}/}/g' package.json
    
    # 4. Fix any malformed jest to vitest replacements
    sed -i.bak 's/"jest": "\[^"\]\*"/"vitest": "^2.0.0",\n    "@vitest\/ui": "^2.0.0"/' package.json
    
    # Test if package.json is valid JSON
    if ! node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" 2>/dev/null; then
        echo "   ⚠️  Warning: package.json still has syntax errors, attempting manual fix..."
        
        # Create a clean package.json with proper vitest dependencies
        cp package.json package.json.broken
        
        # Use node to parse and fix the JSON
        node -e "
        const fs = require('fs');
        try {
          let content = fs.readFileSync('package.json', 'utf8');
          
          // Remove double commas
          content = content.replace(/,,/g, ',');
          
          // Fix trailing commas
          content = content.replace(/,(\s*[}\]])/g, '\$1');
          
          // Parse and reformat
          const pkg = JSON.parse(content);
          
          // Ensure vitest is properly configured
          if (pkg.devDependencies) {
            // Remove jest if it exists
            delete pkg.devDependencies.jest;
            
            // Add vitest dependencies
            pkg.devDependencies.vitest = '^2.0.0';
            pkg.devDependencies['@vitest/ui'] = '^2.0.0';
          }
          
          // Update test script
          if (pkg.scripts && pkg.scripts.test) {
            pkg.scripts.test = 'vitest run';
          }
          
          fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
          console.log('Fixed package.json');
        } catch (error) {
          console.error('Failed to fix package.json:', error.message);
          process.exit(1);
        }
        " || {
            echo "   ❌ Error: Could not fix package.json syntax"
            cd ..
            return 1
        }
    fi
    
    # Remove backup file
    rm -f package.json.bak
    
    echo "   ✅ Fixed package.json"
    
    # Go back to parent directory
    cd ..
    
    echo "   ✅ Completed fixing $server_dir"
    echo ""
    return 0
}

# Function to run fixes
run_fixes() {
    echo "📝 Running package.json fixes..."
    echo ""
    
    # Track successful and failed fixes
    declare -a successful_fixes=()
    declare -a failed_fixes=()
    
    # Fix each server
    for server in "${servers[@]}"; do
        current_server=$((current_server + 1))
        
        if fix_server "$server" "$current_server"; then
            successful_fixes+=("$server")
        else
            failed_fixes+=("$server")
            echo "❌ Fix failed for $server"
            echo ""
        fi
    done
    
    # Summary
    echo "📊 Fix Summary:"
    echo "=============="
    echo "✅ Fixed: ${#successful_fixes[@]}/$total_servers"
    for server in "${successful_fixes[@]}"; do
        echo "   ✓ $server"
    done
    
    if [ ${#failed_fixes[@]} -gt 0 ]; then
        echo ""
        echo "❌ Failed: ${#failed_fixes[@]}/$total_servers"
        for server in "${failed_fixes[@]}"; do
            echo "   ✗ $server"
        done
        echo ""
        echo "❌ Some fixes failed. Please check the errors above."
        return 1
    else
        echo ""
        echo "🎉 All package.json files fixed successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Run dependency installation for each server"
        echo "   2. Test the builds and test suites"
        echo "   3. Commit the changes when ready"
        return 0
    fi
}

# Main execution
echo "Found $total_servers MCP servers to fix"
echo ""

# Check if node is available
if ! command -v node &> /dev/null; then
    echo "❌ Error: node is not installed or not in PATH"
    echo "Please install Node.js"
    exit 1
fi

# Run fixes
run_fixes