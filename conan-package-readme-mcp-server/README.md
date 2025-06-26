# Conan Package README MCP Server

[![license](https://img.shields.io/npm/l/conan-package-readme-mcp-server)](https://github.com/elchika-inc/conan-package-readme-mcp-server/blob/main/LICENSE)
[![npm version](https://img.shields.io/npm/v/conan-package-readme-mcp-server)](https://www.npmjs.com/package/conan-package-readme-mcp-server)
[![npm downloads](https://img.shields.io/npm/dm/conan-package-readme-mcp-server)](https://www.npmjs.com/package/conan-package-readme-mcp-server)
[![GitHub stars](https://img.shields.io/github/stars/elchika-inc/conan-package-readme-mcp-server)](https://github.com/elchika-inc/conan-package-readme-mcp-server)

An MCP (Model Context Protocol) server that enables AI assistants to fetch comprehensive information about Conan packages from ConanCenter, including README content, package metadata, and search functionality.

## Features

- **Package README Retrieval**: Fetch formatted README content with usage examples from C++/Conan packages hosted on ConanCenter
- **Package Information**: Get comprehensive package metadata including dependencies, versions, build configurations, and compatibility information
- **Package Search**: Search ConanCenter with filtering by category, license, and compatibility
- **Smart Caching**: Intelligent caching system to optimize API usage and improve response times
- **GitHub Integration**: Seamless integration with GitHub API for enhanced README fetching from package repositories
- **Error Handling**: Robust error handling with automatic retry logic and fallback strategies

## MCP Client Configuration

Add this server to your MCP client configuration:

```json
{
  "mcpServers": {
    "conan-package-readme": {
      "command": "npx",
      "args": ["conan-package-readme-mcp-server"],
      "env": {
        "GITHUB_TOKEN": "your_github_token_here"
      }
    }
  }
}
```

> **Note**: The `GITHUB_TOKEN` is optional but recommended for higher API rate limits when fetching README content from GitHub.

## Available Tools

### get_package_readme

Retrieves comprehensive README content and usage examples for Conan packages.

**Parameters:**
```json
{
  "package_name": "boost",
  "version": "latest",
  "include_examples": true
}
```

- `package_name` (string, required): Conan package name
- `version` (string, optional): Specific package version or "latest" (default: "latest")
- `include_examples` (boolean, optional): Include usage examples and build configuration snippets (default: true)

**Returns:** Formatted README content with installation instructions, usage examples, and build configuration documentation.

### get_package_info

Fetches detailed package metadata, dependencies, and build information from ConanCenter.

**Parameters:**
```json
{
  "package_name": "openssl",
  "include_dependencies": true,
  "include_build_requires": false
}
```

- `package_name` (string, required): Conan package name
- `include_dependencies` (boolean, optional): Include runtime dependencies (default: true)
- `include_build_requires` (boolean, optional): Include build requirements (default: false)

**Returns:** Package metadata including version info, maintainers, license, platform support, and dependency information.

### search_packages

Searches ConanCenter for packages with filtering capabilities.

**Parameters:**
```json
{
  "query": "json parser",
  "limit": 20,
  "category": "json"
}
```

- `query` (string, required): Search terms (package name, description, keywords)
- `limit` (number, optional): Maximum number of results to return (default: 20, max: 100)
- `category` (string, optional): Filter by package category (json, networking, graphics, etc.)

**Returns:** List of matching packages with names, descriptions, supported platforms, and popularity metrics.

## Error Handling

The server handles common error scenarios gracefully:

- **Package not found**: Returns clear error messages with similar package suggestions
- **Rate limiting**: Implements automatic retry with exponential backoff
- **Network timeouts**: Configurable timeout with retry logic
- **Invalid package names**: Validates package name format and provides guidance
- **Version conflicts**: Handles version resolution with fallback to latest stable

## License

MIT