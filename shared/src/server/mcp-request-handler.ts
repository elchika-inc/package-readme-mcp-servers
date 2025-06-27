/**
 * MCP request handler following Single Responsibility Principle
 * Handles MCP protocol requests/responses only
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListPromptsRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';

import { ToolExecutor } from '../execution/tool-executor.js';
import { ResponseFormatter } from '../response-formatter.js';
import { createLogger } from '../logger.js';

export interface ToolDefinition {
  name: string;
  description: string;
  inputSchema: object;
}

export class MCPRequestHandler {
  private logger = createLogger({ silent: true });

  constructor(
    private server: Server,
    private toolExecutor: ToolExecutor,
    private toolDefinitions: Record<string, ToolDefinition>
  ) {
    this.setupHandlers();
  }

  private setupHandlers(): void {
    // Handle resources list (empty for now)
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => ({
      resources: [],
    }));

    // Handle prompts list (empty for now)  
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => ({
      prompts: [],
    }));

    // Handle tools list
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: Object.values(this.toolDefinitions),
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        const result = await this.toolExecutor.execute(name, args || {});
        return ResponseFormatter.formatToolResponse(result);
      } catch (error) {
        this.logger.error(`Tool execution failed: ${name}`, { error: String(error), args });
        return ResponseFormatter.formatErrorResponse(error);
      }
    });
  }
}