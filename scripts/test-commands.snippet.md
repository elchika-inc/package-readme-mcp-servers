# Test Commands for MCP Servers

## All Servers at Once

### Sequential Mode (Default)
```bash
./test-all.sh
# or
./test-all.sh sequential
```

### Parallel Mode (Faster)
```bash
./test-all.sh parallel
```

## Individual Server Testing

### Basic Test
```bash
./test-individual.sh [server-name]

# Examples:
./test-individual.sh npm-package-readme-mcp-server
./test-individual.sh cargo-package-readme-mcp-server
./test-individual.sh package-readme-core-mcp-server
```

### Test with Options
```bash
# Verbose output
./test-individual.sh npm-package-readme-mcp-server --verbose

# Watch mode (re-run on file changes)
./test-individual.sh npm-package-readme-mcp-server --watch

# Help
./test-individual.sh --help
```

## Available Server Names
- cargo-package-readme-mcp-server
- cocoapods-package-readme-mcp-server  
- composer-package-readme-mcp-server
- conan-package-readme-mcp-server
- cpan-package-readme-mcp-server
- cran-package-readme-mcp-server
- docker-hub-readme-mcp-server
- gem-package-readme-mcp-server
- helm-package-readme-mcp-server
- maven-package-readme-mcp-server
- npm-package-readme-mcp-server
- nuget-package-readme-mcp-server
- pip-package-readme-mcp-server
- swift-package-readme-mcp-server
- vcpkg-package-readme-mcp-server
- package-readme-core-mcp-server

## Manual Testing (per directory)
```bash
cd [server-directory]
bun install
bun run build
bun test
```

## Test Development Workflow
```bash
# 1. Test specific server during development
./test-individual.sh npm-package-readme-mcp-server --watch

# 2. Test all servers before commit
./test-all.sh

# 3. Build and test before publishing
./build-all.sh && ./test-all.sh && ./publish-all.sh
```

## Test Structure
Each server has the following test files:
```
tests/
├── index.test.ts                     # Main server tests
├── tools/                           # Tool-specific tests
│   ├── get-package-readme.test.ts
│   ├── get-package-info.test.ts
│   └── search-packages.test.ts
└── utils/                           # Utility tests (future)
```

## Prerequisites
```bash
# Ensure bun is installed
bun --version

# All dependencies should be installed
bun install  # (run in each server directory or use build-all.sh)
```