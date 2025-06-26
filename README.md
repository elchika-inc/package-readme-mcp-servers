# Package README MCP Servers

多様なパッケージ管理ツールに対応したMCP（Model Context Protocol）サーバー群の開発者向けプロジェクトです。15の主要パッケージレジストリからREADMEファイルと使用例を取得するためのMCPサーバー実装を提供します。

## アーキテクチャ概要

本プロジェクトは、多様なパッケージ管理システムに対応したMCPサーバー群を提供します。各パッケージマネージャーに特化した個別サーバーと、これらを統合するCore Orchestratorから構成されています。

### サポート対象パッケージマネージャー

| パッケージマネージャー | 言語・プラットフォーム | レジストリ |
| --------------------- | --------------------- | --------- |
| npm | Node.js / JavaScript | npm Registry |
| composer | PHP | Packagist |
| pip | Python | PyPI |
| cargo | Rust | crates.io |
| maven | Java | Maven Central |
| nuget | .NET | NuGet Gallery |
| gem | Ruby | RubyGems.org |
| cocoapods | iOS/macOS | CocoaPods Specs |
| conan | C/C++ | Conan Center |
| cpan | Perl | CPAN |
| cran | R | CRAN |
| docker-hub | Docker | Docker Hub |
| helm | Kubernetes | Artifact Hub |
| swift | Swift | Swift Package Index |
| vcpkg | C/C++ | vcpkg Registry |

## 開発環境セットアップ

### 必要な環境

- **Node.js**: 18.0.0以上
- **npm**: 8.0.0以上
- **TypeScript**: 5.0以上（自動インストール）
- **Git**: バージョン管理用

### クイックスタート

```bash
# リポジトリのクローン
git clone <repository-url>
cd package-readme-mcp-servers

# 自動セットアップスクリプトの実行
./scripts/setup-workspace.sh

# 開発サーバーの起動
npm run start:core
```

### 手動セットアップ

```bash
# 依存関係のインストール
npm install

# 全パッケージのビルド
npm run build

# テストの実行
npm test

# リンターの実行
npm run lint
```

## プロジェクト構造

```
package-readme-mcp-servers/
├── package.json                           # ルートパッケージ設定
├── tsconfig.json                          # TypeScript共通設定
├── .eslintrc.json                         # ESLint共通設定
├── jest.config.js                         # Jest共通設定
├── scripts/                               # 開発・ビルドスクリプト
│   ├── setup-workspace.sh                 # 環境セットアップ
│   ├── build-all.sh                       # 並列ビルド
│   └── test-all.sh                        # 並列テスト
├── docs/                                  # 開発者向けドキュメント
│   ├── API.md                             # API仕様書
│   ├── ARCHITECTURE.md                    # アーキテクチャ設計
│   └── CONTRIBUTING.md                    # コントリビューションガイド
├── package-readme-core-mcp-server/        # Core Orchestrator
│   ├── src/
│   │   ├── index.ts                       # メインエントリーポイント
│   │   ├── orchestrator.ts                # パッケージマネージャー検出・統合ロジック
│   │   ├── registry-detector.ts           # レジストリ自動検出
│   │   └── parallel-searcher.ts           # 並列検索エンジン
│   ├── tests/                             # テストスイート
│   └── package.json                       # パッケージ固有設定
├── npm-package-readme-mcp-server/         # npm専用サーバー
│   ├── src/
│   │   ├── index.ts
│   │   ├── npm-client.ts                  # npm API クライアント
│   │   ├── readme-fetcher.ts              # README取得ロジック
│   │   └── package-parser.ts              # パッケージ情報解析
│   └── tests/
└── [他の14個のパッケージマネージャーサーバー]/
```

## 技術仕様

### Core Orchestrator

Core Orchestratorは、以下の機能を提供する統合サーバーです：

```typescript
// パッケージマネージャー自動検出とREADME取得
interface SmartPackageReadmeArgs {
  packageName: string;
  preferredManager?: string;
  includeUsageExamples?: boolean;
}

// 複数レジストリ並列検索
interface SmartPackageSearchArgs {
  query: string;
  maxResults?: number;
  includePrerelease?: boolean;
  registries?: string[];
}

// パッケージ詳細情報取得
interface SmartPackageInfoArgs {
  packageName: string;
  includeDepends?: boolean;
  includeMaintainers?: boolean;
}
```

### 個別MCPサーバー

各パッケージマネージャー専用サーバーは、統一されたインターフェースを実装：

```typescript
interface PackageServerInterface {
  // README取得
  get_package_readme(packageName: string): Promise<PackageReadme>;
  
  // パッケージ情報取得
  get_package_info(packageName: string): Promise<PackageInfo>;
  
  // パッケージ検索
  search_packages(query: string, options?: SearchOptions): Promise<SearchResult[]>;
}
```

## 開発ワークフロー

### 新機能開発

1. **ブランチ作成**
   ```bash
   git checkout -b feature/new-package-manager
   ```

2. **パッケージ作成**
   ```bash
   # 新しいパッケージマネージャーサーバーのセットアップ
   cp -r npm-package-readme-mcp-server new-package-manager-mcp-server
   cd new-package-manager-mcp-server
   
   # package.jsonの更新
   npm pkg set name="new-package-manager-mcp-server"
   npm pkg set description="New Package Manager MCP Server"
   ```

3. **実装**
   ```bash
   # TypeScriptで実装
   vim src/index.ts
   vim src/new-package-client.ts
   vim src/readme-fetcher.ts
   ```

4. **テスト**
   ```bash
   # ユニットテスト
   npm test --workspace=new-package-manager-mcp-server
   
   # 統合テスト
   npm run test:integration
   ```

5. **ビルド・検証**
   ```bash
   # 個別ビルド
   npm run build --workspace=new-package-manager-mcp-server
   
   # 全体ビルド
   npm run build
   
   # リンター
   npm run lint
   ```

### デバッグ・トラブルシューティング

#### 開発サーバーの起動

```bash
# Core Orchestratorをデバッグモードで起動
DEBUG=* npm run start:core

# 特定のサーバーをデバッグモードで起動
DEBUG=npm-* npm run start:npm
LOG_LEVEL=debug npm run start:pip
```

#### よくある問題と解決方法

1. **TypeScript コンパイルエラー**
   ```bash
   # TypeScriptキャッシュクリア
   npx tsc --build --clean
   npm run build
   ```

2. **依存関係の競合**
   ```bash
   # node_modules完全削除・再インストール
   npm run clean:node_modules
   npm install
   ```

3. **テスト失敗**
   ```bash
   # 詳細ログ付きテスト実行
   npm test -- --verbose --no-cache
   ```

4. **API制限エラー**
   ```bash
   # GitHub Token設定
   export GITHUB_TOKEN="your-token-here"
   
   # レート制限確認
   curl -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/rate_limit
   ```

## テスト戦略

### テスト種別

1. **ユニットテスト**: 個別関数・クラスのテスト
2. **統合テスト**: MCPプロトコル通信のテスト
3. **エンドツーエンドテスト**: 実際のレジストリとの通信テスト
4. **パフォーマンステスト**: レスポンス時間・メモリ使用量

### テスト実行

```bash
# 全テスト実行
npm test

# カバレッジ付きテスト
npm run test:coverage

# 特定パッケージのテスト
npm test --workspace=npm-package-readme-mcp-server

# ウォッチモード
npm test -- --watch

# 並列テスト実行
npm run test:parallel
```

### モック・スタブ

```typescript
// APIクライアントのモック例
jest.mock('./npm-client', () => ({
  getNpmPackageInfo: jest.fn().mockResolvedValue({
    name: 'test-package',
    version: '1.0.0',
    description: 'Test package'
  })
}));
```

## パフォーマンス最適化

### ビルド最適化

```bash
# 並列ビルド（推奨）
npm run build:parallel
./scripts/build-all.sh

# 増分ビルド
npm run build:incremental

# 本番ビルド（最適化有効）
NODE_ENV=production npm run build
```

### 実行時最適化

- **並列API呼び出し**: Promise.allを使用した並列処理
- **レスポンスキャッシュ**: メモリ内キャッシュによる重複リクエスト削減
- **接続プーリング**: HTTP接続の再利用
- **レート制限対応**: 指数バックオフによるリトライ機構

### メモリ使用量監視

```bash
# メモリプロファイリング
node --inspect dist/index.js

# ヒープダンプ生成
node --heapsnapshot-signal=SIGUSR2 dist/index.js
```

## セキュリティ考慮事項

### API認証

- **GitHub Token**: public_repo権限のみ必要
- **レジストリ認証**: 各レジストリの認証トークン対応
- **環境変数管理**: 機密情報の適切な管理

### セキュリティ対策

```typescript
// 入力値検証
function validatePackageName(name: string): boolean {
  const packageNameRegex = /^[a-zA-Z0-9._@/-]+$/;
  return packageNameRegex.test(name) && name.length <= 214;
}

// サニタイゼーション
function sanitizeUserInput(input: string): string {
  return input.replace(/[<>"'&]/g, '');
}
```

### 脆弱性対策

```bash
# 依存関係の脆弱性チェック
npm audit
npm audit fix

# セキュリティ更新
npm update
```

## CI/CD パイプライン

### GitHub Actions設定

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20]
    
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm test
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build
        run: npm run build
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### 品質ゲート

- **コードカバレッジ**: 最低80%
- **TypeScript**: strict mode必須
- **ESLint**: エラー0個必須
- **セキュリティ**: npm audit でHigh/Critical脆弱性0個
- **パフォーマンス**: APIレスポンス時間 < 5秒

### リリースプロセス

1. **バージョン更新**
   ```bash
   # セマンティックバージョニング
   npm version patch  # バグフィックス
   npm version minor  # 新機能追加
   npm version major  # 破壊的変更
   ```

2. **リリースノート生成**
   ```bash
   npm run changelog
   ```

3. **パッケージ公開**
   ```bash
   npm run publish:all
   ```

## 拡張性・カスタマイズ

### 新しいパッケージマネージャーの追加

1. **テンプレートからの生成**
   ```bash
   npm run create-package-server -- --name=<new-manager>
   ```

2. **必要な実装**
   - APIクライアント実装
   - README取得ロジック
   - パッケージ情報解析
   - 検索機能実装

3. **設定ファイル更新**
   - `package.json` workspaces配列
   - `tsconfig.json` references配列
   - `jest.config.js` projects配列

### プラグインシステム

```typescript
// カスタムフィルタープラグイン例
interface PackageFilter {
  name: string;
  filter(packages: PackageInfo[]): PackageInfo[];
}

class SecurityFilter implements PackageFilter {
  name = 'security-filter';
  
  filter(packages: PackageInfo[]): PackageInfo[] {
    return packages.filter(pkg => 
      !pkg.vulnerabilities?.some(v => v.severity === 'critical')
    );
  }
}
```

## 監視・ロギング

### ログ設定

```typescript
// 構造化ログ出力
import { createLogger, format, transports } from 'winston';

const logger = createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: format.combine(
    format.timestamp(),
    format.errors({ stack: true }),
    format.json()
  ),
  transports: [
    new transports.Console(),
    new transports.File({ filename: 'error.log', level: 'error' }),
    new transports.File({ filename: 'combined.log' })
  ]
});
```

### メトリクス収集

```typescript
// Prometheusメトリクス例
import prometheus from 'prom-client';

const requestDuration = new prometheus.Histogram({
  name: 'mcp_request_duration_seconds',
  help: 'Duration of MCP requests in seconds',
  labelNames: ['method', 'package_manager', 'status']
});

const packageRequests = new prometheus.Counter({
  name: 'mcp_package_requests_total',
  help: 'Total number of package requests',
  labelNames: ['package_manager', 'operation']
});
```

## コントリビューション

### 開発への参加方法

1. **Issue確認**: [GitHub Issues](https://github.com/your-org/package-readme-mcp-servers/issues)
2. **Fork & Clone**: リポジトリをフォークしてローカルにクローン
3. **ブランチ作成**: feature/fix ブランチを作成
4. **実装**: コーディング規約に従って実装
5. **テスト**: 全テストが通ることを確認
6. **Pull Request**: 詳細な説明とともにPR作成

### コーディング規約

- **TypeScript**: strict mode使用
- **命名規則**: camelCase（変数・関数）、PascalCase（クラス・インターフェース）
- **ファイル構造**: 機能別ディレクトリ分割
- **コメント**: JSDoc形式でAPI仕様を記述
- **エラーハンドリング**: 適切な例外処理とログ出力

```typescript
/**
 * パッケージのREADME情報を取得します
 * @param packageName - 取得対象のパッケージ名
 * @param options - オプション設定
 * @returns README情報とメタデータ
 * @throws {PackageNotFoundError} パッケージが見つからない場合
 */
async function getPackageReadme(
  packageName: string,
  options?: ReadmeOptions
): Promise<PackageReadme> {
  // 実装
}
```

### 課題・TODO

- [ ] GraphQL API対応
- [ ] WebSocket通信サポート
- [ ] リアルタイム依存関係解析
- [ ] パッケージセキュリティスコア算出
- [ ] 機械学習によるパッケージ推薦
- [ ] ブラウザ拡張機能開発
- [ ] VSCode拡張機能開発
- [ ] Docker化対応
- [ ] Kubernetes deployment設定
- [ ]監視ダッシュボード構築

### 参考資料

- [MCP Protocol Specification](https://modelcontextprotocol.io/specification/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started)
- [npm Workspaces](https://docs.npmjs.com/cli/v7/using-npm/workspaces)
- [ESLint Configuration](https://eslint.org/docs/user-guide/configuring/)
- [Semantic Versioning](https://semver.org/)

## ライセンス

MIT License - 詳細は[LICENSE](./LICENSE)ファイルを参照してください。

## サポート・連絡先

- **Issue報告**: [GitHub Issues](https://github.com/your-org/package-readme-mcp-servers/issues)
- **Discussion**: [GitHub Discussions](https://github.com/your-org/package-readme-mcp-servers/discussions)
- **Email**: developers@your-org.com
- **Discord**: [開発者コミュニティ](https://discord.gg/your-community)