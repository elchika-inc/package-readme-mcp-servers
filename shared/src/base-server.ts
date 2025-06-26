import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListPromptsRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';

import { createLogger } from './logger.js';
import { PackageReadmeMcpError } from './errors.js';

export interface ToolDefinition {
  name: string;
  description: string;
  inputSchema: object;
}

export interface ServerConfig {
  name: string;
  version: string;
  silent?: boolean;
}

export abstract class BasePackageServer {
  protected server: Server;
  protected logger = createLogger({ silent: true });
  protected config: ServerConfig;

  constructor(config: ServerConfig) {
    this.config = config;
    this.server = new Server(
      {
        name: config.name,
        version: config.version,
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupEventHandlers();
  }

  protected abstract getToolDefinitions(): Record<string, ToolDefinition>;
  protected abstract handleToolCall(name: string, args: unknown): Promise<unknown>;

  private setupEventHandlers(): void {
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => ({
      resources: [],
    }));

    this.server.setRequestHandler(ListPromptsRequestSchema, async () => ({
      prompts: [],
    }));

    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      const toolDefinitions = this.getToolDefinitions();
      return {
        tools: Object.values(toolDefinitions),
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        const result = await this.handleToolCall(name, args || {});
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      } catch (error) {
        const errorCode = this.mapErrorToMcpErrorCode(error);
        const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';

        throw new McpError(errorCode, errorMessage);
      }
    });
  }

  private mapErrorToMcpErrorCode(error: unknown): ErrorCode {
    if (error instanceof PackageReadmeMcpError) {
      switch (error.code) {
        case 'PACKAGE_NOT_FOUND':
          return ErrorCode.InvalidRequest;
        case 'RATE_LIMIT_EXCEEDED':
          return ErrorCode.InternalError;
        case 'NETWORK_ERROR':
          return ErrorCode.InternalError;
        case 'VALIDATION_ERROR':
          return ErrorCode.InvalidParams;
        default:
          return ErrorCode.InternalError;
      }
    }

    return ErrorCode.InternalError;
  }

  async run(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    this.logger.info(`${this.config.name} running on stdio`);
  }
}