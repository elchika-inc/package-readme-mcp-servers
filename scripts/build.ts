#!/usr/bin/env tsx

import { spawn } from 'child_process';
import concurrently from 'concurrently';

const workspaces = [
  'cargo-package-readme-mcp-server',
  'cocoapods-package-readme-mcp-server',
  'composer-package-readme-mcp-server',
  'conan-package-readme-mcp-server',
  'cpan-package-readme-mcp-server',
  'cran-package-readme-mcp-server',
  'docker-hub-readme-mcp-server',
  'gem-package-readme-mcp-server',
  'helm-package-readme-mcp-server',
  'maven-package-readme-mcp-server',
  'npm-package-readme-mcp-server',
  'nuget-package-readme-mcp-server',
  'package-readme-core-mcp-server',
  'pip-package-readme-mcp-server',
  'swift-package-readme-mcp-server',
  'vcpkg-package-readme-mcp-server'
];

async function buildAllWorkspaces() {
  console.log('Building all workspaces in parallel...');
  
  const commands = workspaces.map(workspace => ({
    command: `npm run build --workspace=${workspace}`,
    name: workspace.replace('-package-readme-mcp-server', '').replace('-readme-mcp-server', ''),
    prefixColor: 'auto' as const
  }));

  try {
    const { result } = concurrently(commands, {
      prefix: 'name',
      killOthers: ['failure'],
      restartTries: 0,
      successCondition: 'all',
    });

    await result;
    console.log('\n✅ All workspaces built successfully!');
  } catch (error) {
    console.error('\n❌ Build failed');
    process.exit(1);
  }
}

buildAllWorkspaces();