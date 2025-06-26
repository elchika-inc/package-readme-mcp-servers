export class PackageReadmeMcpError extends Error {
  public readonly code: string;
  public readonly statusCode?: number;
  public readonly details?: unknown;

  constructor(message: string, code: string, statusCode?: number, cause?: unknown) {
    super(message);
    this.name = 'PackageReadmeMcpError';
    this.code = code;
    this.statusCode = statusCode;
    this.details = cause;
    
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, PackageReadmeMcpError);
    }
  }
}

export class PackageNotFoundError extends PackageReadmeMcpError {
  constructor(context: string, packageName?: string) {
    const message = packageName 
      ? `Package '${packageName}' not found in ${context}`
      : `Package not found in ${context}`;
    super(message, 'PACKAGE_NOT_FOUND', 404);
    this.name = 'PackageNotFoundError';
  }
}

export class RateLimitError extends PackageReadmeMcpError {
  constructor(context: string, retryAfter?: number) {
    const message = retryAfter 
      ? `Rate limit exceeded in ${context}. Retry after ${retryAfter} seconds`
      : `Rate limit exceeded in ${context}`;
    super(message, 'RATE_LIMIT_EXCEEDED', 429, { retryAfter });
    this.name = 'RateLimitError';
  }
}

export class NetworkError extends PackageReadmeMcpError {
  constructor(message: string, cause?: unknown) {
    super(message, 'NETWORK_ERROR', undefined, cause);
    this.name = 'NetworkError';
  }
}