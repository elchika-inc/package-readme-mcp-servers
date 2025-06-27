/**
 * Common validation functions for package management operations
 */

import { ErrorCode, McpError } from '@modelcontextprotocol/sdk/types.js';
import { BaseValidator } from './base-validators.js';

// Common parameter interfaces
export interface GetPackageReadmeParams {
  package_name: string;
  version?: string;
  include_examples?: boolean;
}

export interface GetPackageInfoParams {
  package_name: string;
  include_dependencies?: boolean;
  include_dev_dependencies?: boolean;
}

export interface SearchPackagesParams {
  query: string;
  limit?: number;
  quality?: number;
  popularity?: number;
}

export class PackageValidator {
  /**
   * Validate GetPackageReadme parameters
   */
  static validateGetPackageReadmeParams(args: unknown, packageManager: string): GetPackageReadmeParams {
    if (!args || typeof args !== 'object') {
      throw new McpError(ErrorCode.InvalidParams, 'Arguments must be an object');
    }
    
    const params = args as Record<string, unknown>;
    
    return {
      package_name: BaseValidator.validateStringRequired(params.package_name, 'package_name', packageManager),
      version: BaseValidator.validateStringOptional(params.version, 'version', packageManager) || 'latest',
      include_examples: BaseValidator.validateBooleanOptional(params.include_examples, 'include_examples', true, packageManager),
    };
  }

  /**
   * Validate GetPackageInfo parameters
   */
  static validateGetPackageInfoParams(args: unknown, packageManager: string): GetPackageInfoParams {
    if (!args || typeof args !== 'object') {
      throw new McpError(ErrorCode.InvalidParams, 'Arguments must be an object');
    }
    
    const params = args as Record<string, unknown>;
    
    return {
      package_name: BaseValidator.validateStringRequired(params.package_name, 'package_name', packageManager),
      include_dependencies: BaseValidator.validateBooleanOptional(params.include_dependencies, 'include_dependencies', true, packageManager),
      include_dev_dependencies: BaseValidator.validateBooleanOptional(params.include_dev_dependencies, 'include_dev_dependencies', false, packageManager),
    };
  }

  /**
   * Validate SearchPackages parameters
   */
  static validateSearchPackagesParams(args: unknown, packageManager: string): SearchPackagesParams {
    if (!args || typeof args !== 'object') {
      throw new McpError(ErrorCode.InvalidParams, 'Arguments must be an object');
    }
    
    const params = args as Record<string, unknown>;
    
    const result: SearchPackagesParams = {
      query: BaseValidator.validateStringRequired(params.query, 'query', packageManager),
    };

    // Optional limit parameter
    if (params.limit !== undefined) {
      if (typeof params.limit !== 'number' || params.limit < 1 || params.limit > 250) {
        throw new McpError(ErrorCode.InvalidParams, 'limit must be a number between 1 and 250');
      }
      result.limit = params.limit;
    }

    // Optional quality parameter
    if (params.quality !== undefined) {
      if (typeof params.quality !== 'number' || params.quality < 0 || params.quality > 1) {
        throw new McpError(ErrorCode.InvalidParams, 'quality must be a number between 0 and 1');
      }
      result.quality = params.quality;
    }

    // Optional popularity parameter
    if (params.popularity !== undefined) {
      if (typeof params.popularity !== 'number' || params.popularity < 0 || params.popularity > 1) {
        throw new McpError(ErrorCode.InvalidParams, 'popularity must be a number between 0 and 1');
      }
      result.popularity = params.popularity;
    }

    return result;
  }
}