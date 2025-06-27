/**
 * Tool execution service following Single Responsibility Principle
 * Handles tool execution coordination with clear interface
 */

export interface ToolExecutor {
  execute(toolName: string, args: unknown): Promise<unknown>;
}

export interface ToolHandler {
  canHandle(toolName: string): boolean;
  execute(args: unknown): Promise<unknown>;
}

export class SimpleToolExecutor implements ToolExecutor {
  private handlers = new Map<string, ToolHandler>();

  registerHandler(toolName: string, handler: ToolHandler): void {
    this.handlers.set(toolName, handler);
  }

  async execute(toolName: string, args: unknown): Promise<unknown> {
    const handler = this.handlers.get(toolName);
    
    if (!handler) {
      throw new Error(`Unknown tool: ${toolName}`);
    }

    if (!handler.canHandle(toolName)) {
      throw new Error(`Handler cannot process tool: ${toolName}`);
    }

    return await handler.execute(args);
  }
}

/**
 * Base tool handler for package manager tools
 */
export abstract class BaseToolHandler implements ToolHandler {
  constructor(protected toolName: string) {}

  canHandle(toolName: string): boolean {
    return toolName === this.toolName;
  }

  abstract execute(args: unknown): Promise<unknown>;
}