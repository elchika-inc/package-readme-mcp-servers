/**
 * Modern response formatting utility for MCP tools
 */
export class ResponseFormatter {
  /**
   * Format tool execution result as MCP tool response
   */
  static formatToolResponse(result: any) {
    return {
      content: [
        {
          type: 'text' as const,
          text: typeof result === 'string' ? result : JSON.stringify(result, null, 2),
        },
      ],
    };
  }

  /**
   * Format error as MCP tool response
   */
  static formatErrorResponse(error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
    
    return {
      content: [
        {
          type: 'text' as const,
          text: `Error: ${errorMessage}`,
        },
      ],
      isError: true,
    };
  }
}