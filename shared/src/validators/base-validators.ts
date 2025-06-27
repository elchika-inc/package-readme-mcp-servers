/**
 * Base validation functions shared across all package managers
 */

import { ValidationError } from '../errors.js';

export class BaseValidator {
  /**
   * Validate that a value is a non-empty string
   */
  static validateStringRequired(value: unknown, fieldName: string, packageManager?: string): string {
    if (!value || typeof value !== 'string') {
      throw new ValidationError(fieldName, value, 'non-empty string', packageManager);
    }
    
    if (value.trim().length === 0) {
      throw new ValidationError(fieldName, value, 'non-empty string', packageManager);
    }
    
    return value.trim();
  }

  /**
   * Validate that a value is an optional string
   */
  static validateStringOptional(value: unknown, fieldName: string, packageManager?: string): string | undefined {
    if (value === undefined || value === null) {
      return undefined;
    }
    
    if (typeof value !== 'string') {
      throw new ValidationError(fieldName, value, 'string or undefined', packageManager);
    }
    
    return value.trim() || undefined;
  }

  /**
   * Validate that a value is a boolean
   */
  static validateBooleanOptional(value: unknown, fieldName: string, defaultValue: boolean, packageManager?: string): boolean {
    if (value === undefined || value === null) {
      return defaultValue;
    }
    
    if (typeof value !== 'boolean') {
      throw new ValidationError(fieldName, value, 'boolean', packageManager);
    }
    
    return value;
  }

  /**
   * Validate numeric limit with min/max constraints
   */
  static validateLimit(value: unknown, fieldName: string, min: number, max: number, defaultValue: number, packageManager?: string): number {
    if (value === undefined || value === null) {
      return defaultValue;
    }
    
    if (typeof value !== 'number' || !Number.isInteger(value)) {
      throw new ValidationError(fieldName, value, 'integer', packageManager);
    }
    
    if (value < min || value > max) {
      throw new ValidationError(fieldName, value, `integer between ${min} and ${max}`, packageManager);
    }
    
    return value;
  }

  /**
   * Validate score (0-1 range)
   */
  static validateScore(value: unknown, fieldName: string, packageManager?: string): number | undefined {
    if (value === undefined || value === null) {
      return undefined;
    }
    
    if (typeof value !== 'number') {
      throw new ValidationError(fieldName, value, 'number', packageManager);
    }
    
    if (value < 0 || value > 1) {
      throw new ValidationError(fieldName, value, 'number between 0 and 1', packageManager);
    }
    
    return value;
  }

  /**
   * Validate semantic version string
   */
  static validateSemver(version: string, fieldName: string, packageManager?: string): string {
    // Basic semver pattern (simplified)
    const semverPattern = /^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/;
    
    if (!semverPattern.test(version) && version !== 'latest') {
      throw new ValidationError(fieldName, version, 'valid semantic version or "latest"', packageManager);
    }
    
    return version;
  }

  /**
   * Validate search query
   */
  static validateSearchQuery(query: string, packageManager?: string): string {
    const trimmed = this.validateStringRequired(query, 'query', packageManager);
    
    if (trimmed.length < 2) {
      throw new ValidationError('query', query, 'string with at least 2 characters', packageManager);
    }
    
    if (trimmed.length > 100) {
      throw new ValidationError('query', query, 'string with at most 100 characters', packageManager);
    }
    
    return trimmed;
  }

  /**
   * Validate URL string
   */
  static validateUrlOptional(value: unknown, fieldName: string, packageManager?: string): string | undefined {
    if (value === undefined || value === null) {
      return undefined;
    }
    
    const url = this.validateStringOptional(value, fieldName, packageManager);
    if (!url) {
      return undefined;
    }
    
    try {
      new URL(url);
      return url;
    } catch {
      throw new ValidationError(fieldName, value, 'valid URL', packageManager);
    }
  }
}

/**
 * Abstract base class for package name validation
 * Each package manager should extend this with specific rules
 */
export abstract class PackageNameValidator {
  protected packageManager: string;
  
  constructor(packageManager: string) {
    this.packageManager = packageManager;
  }
  
  /**
   * Validate package name according to package manager specific rules
   */
  abstract validatePackageNameFormat(name: string): void;
  
  /**
   * Main validation method that combines common and specific validation
   */
  validatePackageName(name: string): string {
    const trimmed = BaseValidator.validateStringRequired(name, 'package_name', this.packageManager);
    this.validatePackageNameFormat(trimmed);
    return trimmed;
  }
}

/**
 * Abstract base class for version validation
 * Each package manager should extend this with specific rules
 */
export abstract class VersionValidator {
  protected packageManager: string;
  
  constructor(packageManager: string) {
    this.packageManager = packageManager;
  }
  
  /**
   * Validate version according to package manager specific rules
   */
  abstract validateVersionFormat(version: string): void;
  
  /**
   * Main validation method that combines common and specific validation
   */
  validateVersion(version?: string): string {
    if (!version) {
      return 'latest';
    }
    
    const trimmed = BaseValidator.validateStringRequired(version, 'version', this.packageManager);
    
    if (trimmed === 'latest') {
      return trimmed;
    }
    
    this.validateVersionFormat(trimmed);
    return trimmed;
  }
}