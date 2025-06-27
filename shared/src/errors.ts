import { PackageManagerErrorCode } from './types/common.js';

export class PackageReadmeMcpError extends Error {
  public readonly code: PackageManagerErrorCode;
  public readonly statusCode?: number;
  public readonly details?: unknown;
  public readonly packageManager?: string;

  constructor(message: string, code: PackageManagerErrorCode, statusCode?: number, cause?: unknown, packageManager?: string) {
    super(message);
    this.name = 'PackageReadmeMcpError';
    this.code = code;
    this.statusCode = statusCode;
    this.details = cause;
    this.packageManager = packageManager;
    
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, PackageReadmeMcpError);
    }
  }
}

export class PackageNotFoundError extends PackageReadmeMcpError {
  constructor(packageName: string, packageManager?: string) {
    const context = packageManager || 'registry';
    const message = `Package '${packageName}' not found in ${context}`;
    super(message, 'PACKAGE_NOT_FOUND', 404, { packageName }, packageManager);
    this.name = 'PackageNotFoundError';
  }
}

export class RateLimitError extends PackageReadmeMcpError {
  constructor(retryAfter?: number, packageManager?: string) {
    const context = packageManager || 'registry';
    const message = retryAfter 
      ? `Rate limit exceeded in ${context}. Retry after ${retryAfter} seconds`
      : `Rate limit exceeded in ${context}`;
    super(message, 'RATE_LIMIT_EXCEEDED', 429, { retryAfter }, packageManager);
    this.name = 'RateLimitError';
  }
}

export class NetworkError extends PackageReadmeMcpError {
  constructor(message: string, cause?: unknown, packageManager?: string) {
    super(`Network error: ${message}`, 'NETWORK_ERROR', undefined, cause, packageManager);
    this.name = 'NetworkError';
  }
}

export class VersionNotFoundError extends PackageReadmeMcpError {
  constructor(packageName: string, version: string, packageManager?: string) {
    const message = `Version '${version}' not found for package '${packageName}'`;
    super(message, 'VERSION_NOT_FOUND', 404, { packageName, version }, packageManager);
    this.name = 'VersionNotFoundError';
  }
}

export class InvalidPackageNameError extends PackageReadmeMcpError {
  constructor(packageName: string, packageManager?: string) {
    const message = `Invalid package name: '${packageName}'`;
    super(message, 'INVALID_PACKAGE_NAME', 400, { packageName }, packageManager);
    this.name = 'InvalidPackageNameError';
  }
}

export class InvalidVersionError extends PackageReadmeMcpError {
  constructor(version: string, packageManager?: string) {
    const message = `Invalid version: '${version}'`;
    super(message, 'INVALID_VERSION', 400, { version }, packageManager);
    this.name = 'InvalidVersionError';
  }
}

export class ValidationError extends PackageReadmeMcpError {
  constructor(fieldName: string, value: unknown, expectedType: string, packageManager?: string) {
    const message = `Validation failed for field '${fieldName}': expected ${expectedType}, got ${typeof value}`;
    super(message, 'VALIDATION_ERROR', 400, { fieldName, value, expectedType }, packageManager);
    this.name = 'ValidationError';
  }
}

export class RegistryError extends PackageReadmeMcpError {
  constructor(message: string, statusCode?: number, packageManager?: string) {
    super(`Registry error: ${message}`, 'REGISTRY_ERROR', statusCode, { originalMessage: message }, packageManager);
    this.name = 'RegistryError';
  }
}

export class TimeoutError extends PackageReadmeMcpError {
  constructor(timeoutMs: number, packageManager?: string) {
    const message = `Request timed out after ${timeoutMs}ms`;
    super(message, 'TIMEOUT_ERROR', 408, { timeoutMs }, packageManager);
    this.name = 'TimeoutError';
  }
}