export interface CacheEntry<T> {
  data: T;
  timestamp: number;
  ttl: number;
}

export interface CacheOptions {
  ttl?: number;
  maxSize?: number;
}

export interface CacheStats {
  size: number;
  memoryUsage: number;
  hitRate: number;
}

export const CACHE_CONSTANTS = {
  DEFAULT_TTL_MS: 3600 * 1000,
  DEFAULT_MAX_SIZE_BYTES: 104857600,
  CLEANUP_INTERVAL_MS: 5 * 60 * 1000,
};

export class MemoryCache {
  private cache = new Map<string, CacheEntry<unknown>>();
  private readonly defaultTtl: number;
  private readonly maxSize: number;
  private readonly cleanupInterval: NodeJS.Timeout;

  constructor(options: CacheOptions = {}) {
    this.defaultTtl = options.ttl || CACHE_CONSTANTS.DEFAULT_TTL_MS;
    this.maxSize = options.maxSize || CACHE_CONSTANTS.DEFAULT_MAX_SIZE_BYTES;
    
    this.cleanupInterval = setInterval(() => {
      this.cleanup();
    }, CACHE_CONSTANTS.CLEANUP_INTERVAL_MS);
  }

  set<T>(key: string, value: T, ttl?: number): void {
    const actualTtl = ttl || this.defaultTtl;
    const timestamp = Date.now();
    
    const entry: CacheEntry<T> = {
      data: value,
      timestamp,
      ttl: actualTtl,
    };

    if (this.wouldExceedMaxSize(key, entry)) {
      this.evictLeastRecentlyUsed();
    }

    this.cache.set(key, entry);
  }

  get<T>(key: string): T | null {
    const entry = this.cache.get(key) as CacheEntry<T> | undefined;
    
    if (!entry) {
      return null;
    }

    const now = Date.now();
    if (now - entry.timestamp > entry.ttl) {
      this.cache.delete(key);
      return null;
    }

    entry.timestamp = now;
    return entry.data;
  }

  delete(key: string): boolean {
    return this.cache.delete(key);
  }

  clear(): void {
    this.cache.clear();
  }

  has(key: string): boolean {
    const entry = this.cache.get(key);
    if (!entry) {
      return false;
    }

    const now = Date.now();
    if (now - entry.timestamp > entry.ttl) {
      this.cache.delete(key);
      return false;
    }

    return true;
  }

  size(): number {
    return this.cache.size;
  }

  getStats(): CacheStats {
    const memoryUsage = this.estimateMemoryUsage();
    return {
      size: this.cache.size,
      memoryUsage,
      hitRate: 0,
    };
  }

  private cleanup(): void {
    const now = Date.now();
    for (const [key, entry] of this.cache.entries()) {
      if (now - entry.timestamp > entry.ttl) {
        this.cache.delete(key);
      }
    }
  }

  private wouldExceedMaxSize<T>(key: string, entry: CacheEntry<T>): boolean {
    const currentSize = this.estimateMemoryUsage();
    const entrySize = this.estimateEntrySize(key, entry);
    return currentSize + entrySize > this.maxSize;
  }

  private evictLeastRecentlyUsed(): void {
    let oldestKey: string | null = null;
    let oldestTimestamp = Date.now();

    for (const [key, entry] of this.cache.entries()) {
      if (entry.timestamp < oldestTimestamp) {
        oldestTimestamp = entry.timestamp;
        oldestKey = key;
      }
    }

    if (oldestKey) {
      this.cache.delete(oldestKey);
    }
  }

  private estimateMemoryUsage(): number {
    let totalSize = 0;
    
    for (const [key, entry] of this.cache.entries()) {
      totalSize += this.estimateEntrySize(key, entry);
    }

    return totalSize;
  }

  private estimateEntrySize<T>(key: string, entry: CacheEntry<T>): number {
    const keySize = key.length * 2;
    const dataSize = JSON.stringify(entry.data).length * 2;
    const metadataSize = 24;
    
    return keySize + dataSize + metadataSize;
  }

  destroy(): void {
    clearInterval(this.cleanupInterval);
    this.cache.clear();
  }
}

export const createCacheKey = {
  packageInfo: (packageName: string, version: string): string => 
    `pkg_info:${packageName}:${version}`,
  
  packageReadme: (packageName: string, version: string): string => 
    `pkg_readme:${packageName}:${version}`,
  
  searchResults: (query: string, limit: number, ...params: string[]): string => {
    const queryHash = Buffer.from(query).toString('base64');
    const allParams = [queryHash, limit.toString(), ...params];
    return `search:${allParams.join(':')}`;
  },
  
  downloadStats: (packageName: string, period?: string): string => {
    const date = new Date().toISOString().split('T')[0];
    return period ? `stats:${packageName}:${period}:${date}` : `stats:${packageName}:${date}`;
  },
};