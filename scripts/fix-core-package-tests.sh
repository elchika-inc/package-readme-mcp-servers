#!/bin/bash

# Fix core package tests specifically
set -e

echo "🔧 Fixing package-readme-core-mcp-server tests..."

cd package-readme-core-mcp-server

# Update all test files to use vitest and dist imports
find tests -name "*.test.ts" -type f | while read -r file; do
    echo "   📝 Fixing $file..."
    
    # Replace bun:test imports with vitest
    sed -i '' 's/import.*bun:test.*/import { expect, test, describe } from "vitest";/' "$file"
    
    # Replace src imports with dist/src imports
    sed -i '' 's|require('\''\.\.\/\.\.\/src\/|require('\''../../dist/src/|g' "$file"
    
    echo "   ✅ Fixed $file"
done

echo "✅ All core package tests fixed!"

cd ..