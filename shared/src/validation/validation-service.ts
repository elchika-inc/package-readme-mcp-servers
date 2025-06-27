/**
 * Validation service following Single Responsibility Principle
 * Handles parameter validation with clear interface
 */

import { BaseValidator } from '../validators/base-validators.js';
import { BaseGetPackageReadmeParams, BaseGetPackageInfoParams, BaseSearchPackagesParams } from '../types/common.js';

export interface ValidationService {
  validateReadmeParams(args: unknown): BaseGetPackageReadmeParams;
  validateInfoParams(args: unknown): BaseGetPackageInfoParams;
  validateSearchParams(args: unknown): BaseSearchPackagesParams;
}

export class StandardValidationService implements ValidationService {
  constructor(private packageManager: string) {}

  validateReadmeParams(args: unknown): BaseGetPackageReadmeParams {
    if (!args || typeof args !== 'object') {
      throw new Error('Arguments must be an object');
    }

    const params = args as Record<string, unknown>;
    
    return {
      package_name: BaseValidator.validateStringRequired(params.package_name, 'package_name', this.packageManager),
      version: BaseValidator.validateStringOptional(params.version, 'version', this.packageManager) || 'latest',
      include_examples: BaseValidator.validateBooleanOptional(params.include_examples, 'include_examples', true, this.packageManager),
    };
  }

  validateInfoParams(args: unknown): BaseGetPackageInfoParams {
    if (!args || typeof args !== 'object') {
      throw new Error('Arguments must be an object');
    }

    const params = args as Record<string, unknown>;
    
    return {
      package_name: BaseValidator.validateStringRequired(params.package_name, 'package_name', this.packageManager),
      include_dependencies: BaseValidator.validateBooleanOptional(params.include_dependencies, 'include_dependencies', true, this.packageManager),
      include_dev_dependencies: BaseValidator.validateBooleanOptional(params.include_dev_dependencies, 'include_dev_dependencies', false, this.packageManager),
    };
  }

  validateSearchParams(args: unknown): BaseSearchPackagesParams {
    if (!args || typeof args !== 'object') {
      throw new Error('Arguments must be an object');
    }

    const params = args as Record<string, unknown>;
    
    return {
      query: BaseValidator.validateSearchQuery(
        BaseValidator.validateStringRequired(params.query, 'query', this.packageManager),
        this.packageManager
      ),
      limit: BaseValidator.validateLimit(params.limit, 'limit', 1, 250, 20, this.packageManager),
      quality: BaseValidator.validateScore(params.quality, 'quality', this.packageManager),
      popularity: BaseValidator.validateScore(params.popularity, 'popularity', this.packageManager),
    };
  }
}