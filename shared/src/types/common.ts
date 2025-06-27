/**
 * Common types shared across all package managers
 */

export interface BaseUsageExample {
  title: string;
  description: string;
  code: string;
  language?: string;
}

export interface BaseAuthorInfo {
  name: string;
  email?: string;
  url?: string;
}

export interface BasePackageInfo {
  name: string;
  version: string;
  description?: string;
  homepage?: string;
  repository?: string;
  license?: string;
  authors?: BaseAuthorInfo[];
  keywords?: string[];
  publishedAt?: string;
}

export interface BaseGetPackageReadmeParams {
  package_name: string;
  version?: string;
  include_examples?: boolean;
}

export interface BaseGetPackageInfoParams {
  package_name: string;
  include_dependencies?: boolean;
  include_dev_dependencies?: boolean;
}

export interface BaseSearchPackagesParams {
  query: string;
  limit?: number;
  quality?: number;
  popularity?: number;
}

export interface BaseCacheEntry<T> {
  data: T;
  timestamp: number;
  ttl: number;
}

export interface BaseCacheOptions {
  ttl?: number;
  maxSize?: number;
}

export interface BasePackageReadmeResult {
  package_name: string;
  version: string;
  readme: string;
  usage_examples?: BaseUsageExample[];
  homepage?: string;
  repository?: string;
  license?: string;
  documentation_url?: string;
}

export interface BasePackageInfoResult extends BasePackageInfo {
  dependencies?: Record<string, string>;
  dev_dependencies?: Record<string, string>;
  peer_dependencies?: Record<string, string>;
}

export interface BaseSearchResult {
  packages: Array<{
    name: string;
    version: string;
    description?: string;
    quality_score?: number;
    popularity_score?: number;
    last_updated?: string;
  }>;
  total_count: number;
}

// Package manager specific error codes
export type PackageManagerErrorCode = 
  | 'PACKAGE_NOT_FOUND'
  | 'VERSION_NOT_FOUND'
  | 'INVALID_PACKAGE_NAME'
  | 'INVALID_VERSION'
  | 'INVALID_SEARCH_QUERY'
  | 'INVALID_LIMIT'
  | 'INVALID_SCORE'
  | 'RATE_LIMIT_EXCEEDED'
  | 'NETWORK_ERROR'
  | 'VALIDATION_ERROR'
  | 'REGISTRY_ERROR'
  | 'TIMEOUT_ERROR'
  | 'UNEXPECTED_ERROR'
  | 'UNKNOWN_ERROR'
  | 'HTTP_ERROR';