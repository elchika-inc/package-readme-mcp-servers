#!/bin/bash

# Package README MCP Servers - Individual Test Script
# Usage: ./test-individual.sh [server-name] [options]

set -e  # Exit on any error

# Function to show usage
show_usage() {
    echo "Usage: $0 [server-name] [options]"
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
    echo "Options:"
    echo "  --watch, -w     Watch mode (re-run tests on file changes)"
    echo "  --verbose, -v   Verbose output"
    echo "  --help, -h      Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 npm-package-readme-mcp-server"
    echo "  $0 cargo-package-readme-mcp-server --watch"
    echo "  $0 pip-package-readme-mcp-server --verbose"
}

# Parse command line arguments
server_dir=""
watch_mode=false
verbose=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --watch|-w)
            watch_mode=true
            shift
            ;;
        --verbose|-v)
            verbose=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        -*)
            echo "❌ Error: Unknown option $1"
            echo ""
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$server_dir" ]; then
                server_dir=$1
            else
                echo "❌ Error: Multiple server names provided"
                echo ""
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if server name is provided
if [ -z "$server_dir" ]; then
    echo "❌ Error: No server name provided"
    echo ""
    show_usage
    exit 1
fi

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

echo "🧪 Testing $server_dir..."
if [ "$watch_mode" = true ]; then
    echo "👀 Watch mode enabled"
fi
if [ "$verbose" = true ]; then
    echo "📝 Verbose mode enabled"
fi
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

# Check if tests directory exists
if [ ! -d "tests" ]; then
    echo "❌ Error: tests directory not found in $server_dir"
    echo "💡 Try running the build-all.sh script first to ensure tests are created"
    exit 1
fi

# Show package info
echo "📋 Package Information:"
echo "   Name: $(node -p "require('./package.json').name")"
echo "   Version: $(node -p "require('./package.json').version")"
echo "   Description: $(node -p "require('./package.json').description")"
echo ""

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📥 Installing dependencies..."
    bun install
    echo ""
fi

# Build first (tests may depend on compiled JS)
echo "🏗️  Building..."
bun run build
echo ""

# Show test files
echo "📁 Test files found:"
find tests -name "*.test.ts" -type f | sort | while read file; do
    echo "   📄 $file"
done
echo ""

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
    echo "==================="
    
    if [ "$verbose" = true ]; then
        bun test --verbose
    else
        bun test
    fi
    
    local exit_code=$?
    echo ""
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ All tests passed!"
        echo ""
        echo "📊 Test Statistics:"
        echo "   📁 Test files: $(find tests -name "*.test.ts" -type f | wc -l)"
        echo "   📦 Package: $(node -p "require('./package.json').name")"
        echo "   🏷️  Version: $(node -p "require('./package.json').version")"
        return 0
    else
        echo "❌ Tests failed!"
        echo ""
        echo "💡 Debugging tips:"
        echo "   1. Check individual test files in the tests/ directory"
        echo "   2. Run with --verbose flag for more details"
        echo "   3. Ensure build completed successfully"
        echo "   4. Check that all dependencies are installed"
        return 1
    fi
}

# Run tests based on mode
if [ "$watch_mode" = true ]; then
    echo "👀 Starting watch mode..."
    echo "   Press Ctrl+C to stop"
    echo ""
    
    # Note: bun test --watch is not yet stable, so we implement basic file watching
    echo "⚠️  Note: Watch mode uses basic file monitoring"
    echo "   Tests will re-run when TypeScript files change"
    echo ""
    
    # Run tests initially
    run_tests
    
    # Simple file watching loop
    last_modified=$(find src tests -name "*.ts" -exec stat -f "%m" {} \; 2>/dev/null | sort -n | tail -1)
    
    while true; do
        sleep 2
        current_modified=$(find src tests -name "*.ts" -exec stat -f "%m" {} \; 2>/dev/null | sort -n | tail -1)
        
        if [ "$current_modified" != "$last_modified" ]; then
            echo ""
            echo "🔄 Files changed, re-running tests..."
            echo "======================================"
            
            # Rebuild and test
            if bun run build > /dev/null 2>&1; then
                run_tests
            else
                echo "❌ Build failed, skipping tests"
            fi
            
            last_modified=$current_modified
        fi
    done
else
    # Run tests once
    run_tests
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "🎉 Testing completed successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Review test coverage if needed"
        echo "   2. Test other servers: ./test-all.sh"
        echo "   3. Proceed with development or publishing"
    fi
    
    exit $exit_code
fi