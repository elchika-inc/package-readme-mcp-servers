export enum LogLevel {
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3,
}

export interface LoggerOptions {
  level?: LogLevel | string;
  silent?: boolean;
}

export class Logger {
  private logLevel: LogLevel;
  private silent: boolean;

  constructor(options: LoggerOptions = {}) {
    if (typeof options.level === 'string') {
      this.logLevel = LogLevel[options.level.toUpperCase() as keyof typeof LogLevel] ?? LogLevel.INFO;
    } else {
      this.logLevel = options.level ?? LogLevel.INFO;
    }
    this.silent = options.silent ?? false;
  }

  private log(level: LogLevel, message: string, data?: unknown): void {
    if (this.silent || level > this.logLevel) {
      return;
    }

    const timestamp = new Date().toISOString();
    const levelName = LogLevel[level];
    const logMessage = `[${timestamp}] ${levelName}: ${message}`;

    switch (level) {
      case LogLevel.ERROR:
        data ? console.error(logMessage, data) : console.error(logMessage);
        break;
      case LogLevel.WARN:
        data ? console.warn(logMessage, data) : console.warn(logMessage);
        break;
      case LogLevel.INFO:
        data ? console.info(logMessage, data) : console.info(logMessage);
        break;
      case LogLevel.DEBUG:
        data ? console.debug(logMessage, data) : console.debug(logMessage);
        break;
    }
  }

  error(message: string, data?: unknown): void {
    this.log(LogLevel.ERROR, message, data);
  }

  warn(message: string, data?: unknown): void {
    this.log(LogLevel.WARN, message, data);
  }

  info(message: string, data?: unknown): void {
    this.log(LogLevel.INFO, message, data);
  }

  debug(message: string, data?: unknown): void {
    this.log(LogLevel.DEBUG, message, data);
  }

  setLevel(level: LogLevel | string): void {
    if (typeof level === 'string') {
      this.logLevel = LogLevel[level.toUpperCase() as keyof typeof LogLevel] ?? LogLevel.INFO;
    } else {
      this.logLevel = level;
    }
  }

  setSilent(silent: boolean): void {
    this.silent = silent;
  }
}

export const createLogger = (options?: LoggerOptions): Logger => new Logger(options);

export const logger = createLogger({ silent: true });