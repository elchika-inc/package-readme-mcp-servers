# Bun Publish Commands

## All Servers at Once
```bash
./publish-all.sh
```

## Individual Servers
```bash
./publish-individual.sh [server-name]
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

## Manual Commands (if needed)
```bash
cd [server-directory]
bun install
bun run build
bun run bun:publish
```

## Prerequisites
```bash
# Login to npm registry
npm login

# Verify login
npm whoami

# Install bun if not already installed
curl -fsSL https://bun.sh/install | bash
```