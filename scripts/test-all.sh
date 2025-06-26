#!/bin/bash

# Package README MCP Servers - Test All Script
# This script runs tests for all MCP servers to verify functionality

set -e  # Exit on any error

echo "🧪 Running tests for all MCP servers..."
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

# Test execution mode (can be changed to "parallel" for faster execution)
EXECUTION_MODE=${1:-"sequential"}

# Function to test a single server
test_server() {
    local server_dir=$1
    local server_num=$2
    
    echo "🧪 [$server_num/$total_servers] Testing $server_dir..."
    
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
    
    # Check if tests directory exists
    if [ ! -d "tests" ]; then
        echo "❌ Error: tests directory not found in $server_dir"
        cd ..
        return 1
    fi
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "   📥 Installing dependencies..."
        if ! bun install --silent; then
            echo "❌ Error: Failed to install dependencies for $server_dir"
            cd ..
            return 1
        fi
    fi
    
    # Build first (tests may depend on compiled JS)
    echo "   🏗️  Building..."
    if ! bun run build > /dev/null 2>&1; then
        echo "❌ Error: Build failed for $server_dir"
        cd ..
        return 1
    fi
    
    # Run tests
    echo "   🧪 Running tests..."
    if ! bun test 2>/dev/null; then
        echo "❌ Error: Tests failed for $server_dir"
        cd ..
        return 1
    fi
    
    # Go back to parent directory
    cd ..
    
    echo "   ✅ All tests passed for $server_dir"
    echo ""
    return 0
}

# Function to run tests in parallel
run_tests_parallel() {
    echo "🚀 Running tests in parallel mode..."
    echo ""
    
    # Array to store background process PIDs
    declare -a pids=()
    declare -a results=()
    
    # Start all test processes in background
    for i in "${!servers[@]}"; do
        server="${servers[$i]}"
        server_num=$((i + 1))
        
        (
            test_result=$(test_server "$server" "$server_num" 2>&1)
            exit_code=$?
            echo "$server:$exit_code:$test_result"
        ) &
        
        pids+=($!)
    done
    
    # Wait for all processes and collect results
    for i in "${!pids[@]}"; do
        wait ${pids[$i]}
        result_line=$(jobs -p | grep -v ${pids[$i]} || echo "")
    done
    
    # Note: Parallel execution makes output harder to read
    # Results will be mixed, but faster execution
    echo "🏁 Parallel execution completed"
}

# Function to run tests sequentially
run_tests_sequential() {
    echo "📝 Running tests in sequential mode..."
    echo ""
    
    # Track successful and failed tests
    declare -a successful_tests=()
    declare -a failed_tests=()
    
    # Test each server
    for server in "${servers[@]}"; do
        current_server=$((current_server + 1))
        
        if test_server "$server" "$current_server"; then
            successful_tests+=("$server")
        else
            failed_tests+=("$server")
            echo "❌ Tests failed for $server"
            echo ""
        fi
    done
    
    # Summary
    echo "📊 Test Summary:"
    echo "==============="
    echo "✅ Passed: ${#successful_tests[@]}/$total_servers"
    for server in "${successful_tests[@]}"; do
        echo "   ✓ $server"
    done
    
    if [ ${#failed_tests[@]} -gt 0 ]; then
        echo ""
        echo "❌ Failed: ${#failed_tests[@]}/$total_servers"
        for server in "${failed_tests[@]}"; do
            echo "   ✗ $server"
        done
        echo ""
        echo "❌ Some tests failed. Please check the errors above."
        return 1
    else
        echo ""
        echo "🎉 All tests passed successfully!"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Review any test warnings or notices"
        echo "   2. Consider running integration tests"
        echo "   3. Proceed with publishing if ready: ./publish-all.sh"
        return 0
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [mode]"
    echo ""
    echo "Modes:"
    echo "  sequential  - Run tests one by one (default, better output)"
    echo "  parallel    - Run tests in parallel (faster, mixed output)"
    echo ""
    echo "Examples:"
    echo "  $0                # Run in sequential mode"
    echo "  $0 sequential     # Run in sequential mode"
    echo "  $0 parallel       # Run in parallel mode"
}

# Validate execution mode
if [[ "$EXECUTION_MODE" != "sequential" && "$EXECUTION_MODE" != "parallel" ]]; then
    echo "❌ Error: Invalid execution mode '$EXECUTION_MODE'"
    echo ""
    show_usage
    exit 1
fi

# Main execution
echo "Found $total_servers MCP servers to test"
echo "Execution mode: $EXECUTION_MODE"
echo ""

# Check if bun is available
if ! command -v bun &> /dev/null; then
    echo "❌ Error: bun is not installed or not in PATH"
    echo "Please install bun: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# Run tests based on execution mode
if [ "$EXECUTION_MODE" = "parallel" ]; then
    run_tests_parallel
else
    run_tests_sequential
fi