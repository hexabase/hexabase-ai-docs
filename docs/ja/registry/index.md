# コンテナレジストリサービス

Hexabase.AI は、Hexabase.AI プロジェクト内でのコンテナイメージの安全な保存、管理、配布を可能にする**プロジェクトスコープ型コンテナレジストリサービス**を提供します。デフォルトプラットフォームとしてHarborを含む複数のレジストリプロバイダーをサポートし、エンタープライズグレードのセキュリティ、スケーラビリティ、CI/CD ワークフローとのシームレスな統合を保証します。

## 概要

コンテナレジストリサービスは**プロジェクトスコープ型**で、各Hexabase.AIプロジェクトが独自の専用コンテナレジストリ空間を持つことができます。このアプローチにより、ワークスペース全体のレジストリと比較して、より良い分離、セキュリティ、リソース管理を提供します。マイクロサービスのデプロイ、CI/CD パイプラインの管理、複数環境にわたるアプリケーションの配布など、様々な用途でコンテナイメージの安全性、アクセシビリティ、プロジェクトレベルでの適切な管理を保証します。

## 主要機能

<div class="grid cards" markdown>

- :material-package:{ .lg .middle } **セキュアイメージストレージ**

  ***

  ロールベースアクセス制御とイメージ署名によるエンタープライズグレードセキュリティ

  [:octicons-arrow-right-24: セキュリティ機能](#セキュリティ機能)

- :material-shield-check:{ .lg .middle } **脆弱性スキャン**

  ***

  詳細な脆弱性レポート付き自動セキュリティスキャン

  [:octicons-arrow-right-24: セキュリティスキャン](#脆弱性スキャン)

- :material-sync:{ .lg .middle } **マルチレジストリレプリケーション**

  ***

  クロスリージョンレプリケーションと災害復旧機能

  [:octicons-arrow-right-24: レプリケーション](#レプリケーション)

- :material-api:{ .lg .middle } **API統合**

  ***

  シームレスなCI/CD統合のためのRESTful APIとWebhookサポート

  [:octicons-arrow-right-24: APIリファレンス](https://api.hexabase.ai/docs#registry)

</div>

## Harbor：デフォルトレジストリプラットフォーム

Hexabase.AI はデフォルトのコンテナレジストリプラットフォームとして **Harbor** を使用し、以下を提供します：

### Harbor のコア機能

- **プロジェクトベース組織**: 細かいアクセス制御付きプロジェクト別イメージ整理
- **ロールベースアクセス制御（RBAC）**: ユーザーとグループの細密な権限設定
- **イメージ脆弱性スキャン**: Trivy と Clair による組み込みセキュリティスキャン
- **コンテントトラスト**: Docker Content Trust と Notary によるイメージ署名
- **ガベージコレクション**: 未使用イメージとレイヤーの自動クリーンアップ
- **監査ログ**: すべてのレジストリ操作の包括的ログ記録

### エンタープライズ拡張機能

- **マルチテナンシーサポート**: ワークスペース毎の分離されたレジストリ空間
- **SSO統合**: アイデンティティプロバイダーとのシームレス統合
- **高可用性**: ロードバランシング付きクラスター展開
- **バックアップと復旧**: ポイントインタイム復旧付き自動バックアップ
- **監視統合**: 組み込みメトリクスとアラート

## レジストリアーキテクチャ

### プロジェクトスコープアーキテクチャ

```
┌─────────────────────────────────────────────────────────┐
│                    Hexabase.AI                          │
│                 コンテナレジストリ                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ワークスペースA│  │ワークスペースB│  │ワークスペースC│     │
│  │             │  │             │  │             │     │
│  │ ┌─プロジェクト1─┐ │ ┌─プロジェクト1─┐ │ ┌─プロジェクト1─┐ │   │
│  │ │ レジストリ  │ │ │ │ レジストリ  │ │ │ │ レジストリ  │ │   │
│  │ └───────────┘ │ │ └───────────┘ │ │ └───────────┘ │   │
│  │ ┌─プロジェクト2─┐ │ ┌─プロジェクト2─┐ │ ┌─プロジェクト2─┐ │   │
│  │ │ レジストリ  │ │ │ │ レジストリ  │ │ │ │ レジストリ  │ │   │
│  │ └───────────┘ │ │ └───────────┘ │ │ └───────────┘ │   │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
├─────────────────────────────────────────────────────────┤
│       レジストリプロバイダー (Harbor, ECR, ACR...)      │
├─────────────────────────────────────────────────────────┤
│    ストレージバックエンド (オブジェクトストレージ + DB)  │
└─────────────────────────────────────────────────────────┘
```

### サービスコンポーネント

- **レジストリコア**: OCI準拠のHarborレジストリエンジン
- **データベース**: メタデータと設定用PostgreSQL
- **Redisキャッシュ**: 高性能キャッシュレイヤー
- **ストレージバックエンド**: コンテナレイヤー用オブジェクトストレージ
- **セキュリティスキャナー**: 統合脆弱性スキャンエンジン
- **レプリケーションコントローラー**: クロスリージョン同期

## 使い始める

### 1. プロジェクトレジストリの作成

各プロジェクトは独自の専用レジストリを持つことができます。まず、プロジェクト用のレジストリを作成します：

```bash
# プロジェクト用レジストリを作成
hb registry create-project \
  --project-id my-project \
  --name "マイプロジェクトレジストリ" \
  --provider harbor \
  --description "アプリケーション用コンテナレジストリ"

# レジストリURL形式（プロジェクトスコープ）
https://<registry-id>.registry.hexabase.ai/<project-id>

# 例
https://harbor-01.registry.hexabase.ai/my-project
```

### 2. 認証

#### Docker CLI の使用

```bash
# プロジェクトレジストリにログイン
docker login harbor-01.registry.hexabase.ai

# Hexabase.AI認証情報を入力
Username: your-username
Password: your-token-or-password
```

#### ロボットアカウントの使用

自動化ワークフロー用にロボットアカウントを作成：

```bash
# プロジェクト用ロボットアカウントを作成
hb registry robot create \
  --name ci-cd-bot \
  --project-id my-project \
  --permissions read,write \
  --description "CI/CD自動化アカウント"

# ロボット認証情報を使用
docker login harbor-01.registry.hexabase.ai \
  -u robot$ci-cd-bot \
  -p <robot-token>
```

### 3. 基本操作

#### イメージのプッシュ

```bash
# イメージにタグ付け（プロジェクトスコープ）
docker tag myapp:latest harbor-01.registry.hexabase.ai/my-project/myapp:latest

# プロジェクトレジストリにプッシュ
docker push harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

#### イメージのプル

```bash
# プロジェクトレジストリからプル
docker pull harbor-01.registry.hexabase.ai/my-project/myapp:latest

# Kubernetesにデプロイ
kubectl create deployment myapp \
  --image=harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

## APIエンドポイント

コンテナレジストリサービスはプロジェクトスコープ型のREST APIエンドポイントを提供します：

### レジストリ管理（管理者レベル）
```bash
# 新しいレジストリインスタンスを登録
POST /api/v1/registries

# 利用可能なレジストリをリスト
GET /api/v1/registries

# レジストリ詳細を取得
GET /api/v1/registries/{id}

# レジストリ設定を更新
PUT /api/v1/registries/{id}

# レジストリを削除
DELETE /api/v1/registries/{id}

# レジストリヘルスをチェック
GET /api/v1/registries/{id}/health
```

### プロジェクトスコープレジストリ操作
```bash
# プロジェクト用レジストリを作成
POST /api/v1/projects/{projectId}/registry

# プロジェクトレジストリ詳細を取得
GET /api/v1/projects/{projectId}/registry

# プロジェクトレジストリを更新
PUT /api/v1/projects/{projectId}/registry

# プロジェクトレジストリを削除
DELETE /api/v1/projects/{projectId}/registry

# プロジェクトストレージ使用量を取得
GET /api/v1/projects/{projectId}/registry/usage

# プロジェクトセキュリティ設定を構成
PUT /api/v1/projects/{projectId}/registry/security

# ストレージクォータを更新
PUT /api/v1/projects/{projectId}/registry/quota
```

### API使用例

#### プロジェクトレジストリの作成
```bash
curl -X POST "https://api.hexabase.ai/api/v1/projects/my-project/registry" \
  -H "Authorization: Bearer $HB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "マイプロジェクトレジストリ",
    "provider": "harbor",
    "visibility": "private",
    "description": "アプリケーション用コンテナレジストリ"
  }'
```

#### プロジェクトレジストリ情報の取得
```bash
curl -X GET "https://api.hexabase.ai/api/v1/projects/my-project/registry" \
  -H "Authorization: Bearer $HB_TOKEN"
```

## プロジェクトレジストリ管理

### プロジェクトレジストリの作成

各Hexabase.AIプロジェクトは独自のコンテナレジストリを持つことができます：

```bash
# プロジェクト用レジストリを作成
hb registry create-project \
  --project-id frontend-app \
  --name "フロントエンドアプリケーションレジストリ" \
  --provider harbor \
  --visibility private \
  --description "フロントエンドマイクロサービス用レジストリ"

# プロジェクトレジストリをリスト
hb registry list-projects --workspace production

# プロジェクトレジストリ詳細を取得
hb registry get-project --project-id frontend-app
```

### プロジェクトレジストリ設定

#### アクセス制御

```yaml
# プロジェクトレジストリRBAC設定
project_id: frontend-app
registry_id: harbor-01
members:
  - user: "alice@company.com"
    role: "ProjectAdmin"
  - user: "bob@company.com"
    role: "Developer"
  - group: "frontend-team"
    role: "Developer"

security_policies:
  vulnerability_scanning: true
  content_trust: required
  prevent_vulnerable_images: true
  auto_scan_on_push: true
  severity_threshold: "high"
```

#### 保持ポリシー

```yaml
# イメージ保持設定
retention_policy:
  rules:
    - priority: 1
      disabled: false
      action: "retain"
      template: "latestPushedK"
      params:
        latestPushedK: 10  # 最新10イメージを保持
      tag_selectors:
        - kind: "doublestar"
          decoration: "matches"
          pattern: "**"
      scope_selectors:
        - repository:
            - kind: "doublestar"
              decoration: "repoMatches"
              pattern: "**"
```

## セキュリティ機能

### 脆弱性スキャン

#### 自動スキャン

- **プッシュ時スキャン**: イメージアップロード時の自動脆弱性スキャン
- **スケジュールスキャン**: 新しい脆弱性に対する既存イメージの定期スキャン
- **マルチスキャナーサポート**: Trivy、Clair、その他スキャナーとの統合

#### 脆弱性レポート

```bash
# プロジェクトイメージの脆弱性レポートを取得
hb registry scan report \
  --project-id my-project \
  --image harbor-01.registry.hexabase.ai/my-project/myapp:latest

# 出力例
脆弱性サマリー:
  高: 2
  中: 5
  低: 12
  不明: 1

重要な脆弱性:
  CVE-2023-12345: libssl でのリモートコード実行
  CVE-2023-67890: ベースイメージでのバッファオーバーフロー
```

#### セキュリティポリシー

```yaml
# セキュリティポリシー設定
security_policy:
  prevent_vulnerable_images:
    enabled: true
    severity_threshold: "high"
  
  content_trust:
    enabled: true
    cosign_verification: true
  
  image_scanning:
    auto_scan: true
    scan_on_push: true
    scanner: "trivy"
```

### コンテントトラストと署名

#### Docker Content Trust

```bash
# コンテントトラストを有効化
export DOCKER_CONTENT_TRUST=1
export DOCKER_CONTENT_TRUST_SERVER=https://harbor-01.registry.hexabase.ai:4443

# 署名付きイメージをプッシュ
docker push harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

#### Cosign統合

```bash
# Cosignでイメージに署名
cosign sign harbor-01.registry.hexabase.ai/my-project/myapp:latest

# 署名を検証
cosign verify harbor-01.registry.hexabase.ai/my-project/myapp:latest
```

## レプリケーション

### クロスリージョンレプリケーション

災害復旧とグローバル配布のためのレプリケーション設定：

```bash
# レプリケーションエンドポイントを作成
hb registry replication endpoint create \
  --name disaster-recovery \
  --url https://dr-harbor.registry.hexabase.ai \
  --project-id my-project

# レプリケーションルールを作成
hb registry replication rule create \
  --name project-to-dr \
  --source-project my-project \
  --destination-endpoint disaster-recovery \
  --filter-pattern "my-project/**" \
  --trigger manual
```

#### レプリケーション設定

```yaml
# レプリケーションルール設定
replication_rule:
  name: "prod-to-dr"
  description: "本番環境から災害復旧へのレプリケーション"
  source_registry:
    type: "harbor"
    url: "https://prod-workspace.registry.hexabase.ai"
  destination_registry:
    type: "harbor"
    url: "https://dr-workspace.registry.hexabase.ai"
  filters:
    - type: "repository"
      value: "production/**"
    - type: "tag"
      value: "v*"
  trigger:
    type: "scheduled"
    schedule: "0 2 * * *"  # 毎日午前2時
  settings:
    override: false
    deletion: false
```

## CI/CD統合

### GitHub Actions

```yaml
# .github/workflows/build-and-push.yml
name: レジストリへのビルドとプッシュ

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Hexabaseレジストリにログイン
        uses: docker/login-action@v2
        with:
          registry: harbor-01.registry.hexabase.ai
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
      
      - name: ビルドとプッシュ
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            harbor-01.registry.hexabase.ai/my-project/myapp:latest
            harbor-01.registry.hexabase.ai/my-project/myapp:${{ github.sha }}
      
      - name: イメージスキャン
        run: |
          hb registry scan start \
            --project-id my-project \
            --image harbor-01.registry.hexabase.ai/my-project/myapp:${{ github.sha }} \
            --wait
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - build
  - scan
  - deploy

variables:
  REGISTRY: "harbor-01.registry.hexabase.ai"
  PROJECT_ID: "my-project"
  IMAGE_NAME: "$REGISTRY/$PROJECT_ID/myapp"

build:
  stage: build
  script:
    - docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD $REGISTRY
    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHA .
    - docker push $IMAGE_NAME:$CI_COMMIT_SHA

security_scan:
  stage: scan
  script:
    - hb registry scan start --project-id $PROJECT_ID --image $IMAGE_NAME:$CI_COMMIT_SHA --wait
    - hb registry scan report --project-id $PROJECT_ID --image $IMAGE_NAME:$CI_COMMIT_SHA --format json > scan-results.json
  artifacts:
    reports:
      vulnerability: scan-results.json
```

## 監視と分析

### レジストリメトリクス

レジストリのパフォーマンスと使用状況を監視：

```bash
# プロジェクトレジストリ統計を取得
hb registry stats --project-id my-project

# 出力例
レジストリ統計:
  総リポジトリ数: 156
  総イメージ数: 1,247
  使用ストレージ: 2.3 TB
  プル数 (24時間): 15,847
  プッシュ数 (24時間): 234
  アクティブユーザー: 45
```

### 一般的なメトリクス

- **ストレージ使用量**: プロジェクト別ストレージ消費量の追跡
- **プル/プッシュ率**: レジストリトラフィックと使用パターンの監視
- **脆弱性トレンド**: 時間経過に伴うセキュリティ改善の追跡
- **ユーザー活動**: アクセスパターンと使用状況の監視
- **レプリケーション状態**: クロスリージョン同期ヘルスの監視

### アラートと通知

```yaml
# アラート設定
alerts:
  - name: "high_storage_usage"
    condition: "storage_usage > 80%"
    notification:
      - webhook: "https://hooks.slack.com/services/..."
      - email: "ops-team@company.com"
  
  - name: "vulnerability_detected"
    condition: "new_critical_vulnerability == true"
    notification:
      - webhook: "https://hooks.teams.microsoft.com/..."
```

## ベストプラクティス

### イメージ管理

1. **セマンティックバージョニングの使用**: セマンティックバージョン（v1.2.3）でイメージにタグ付け
2. **不変タグ**: 既存タグの上書きを避ける
3. **マルチステージビルド**: イメージサイズとセキュリティの最適化
4. **ベースイメージ更新**: セキュリティパッチのためのベースイメージ定期更新

### セキュリティベストプラクティス

1. **定期スキャン**: 自動脆弱性スキャンの有効化
2. **最小イメージ**: distroless または最小ベースイメージの使用
3. **イメージ署名**: コンテントトラストとイメージ署名の実装
4. **アクセス制御**: 最小権限の原則に従う
5. **秘密管理**: イメージに秘密を含めない

### パフォーマンス最適化

1. **レイヤーキャッシュ**: レイヤー再利用のためのDockerfile最適化
2. **レジストリ場所**: より高速なプルのためのリージョナルレジストリ使用
3. **クリーンアップポリシー**: ストレージ管理のための保持ポリシー実装
4. **並列プル**: 同時レイヤーダウンロードの設定

## 将来のロードマップ

### 代替レジストリサポート

Harbor がデフォルトプラットフォームとして機能する一方で、追加のレジストリプラットフォームのサポートを計画しています：

#### 短期（Q1-Q2）
- **AWS ECR統合**: Amazon Elastic Container Registry のネイティブサポート
- **Azure ACR サポート**: Azure Container Registry との統合
- **Google GCR/Artifact Registry**: Google Cloud レジストリサービスのサポート

#### 中期（Q3-Q4）
- **GitLab Container Registry**: GitLab レジストリとの直接統合
- **JFrog Artifactory**: エンタープライズアーティファクト管理統合
- **Nexus Repository**: エンタープライズ顧客向け Sonatype Nexus サポート

#### 長期（来年）
- **マルチレジストリフェデレーション**: 複数レジストリプロバイダーの統一ビュー
- **レジストリメッシュ**: 分散レジストリアーキテクチャ
- **AI駆動最適化**: インテリジェントイメージ最適化と推奨
- **OCI アーティファクト**: コンテナイメージ以外のOCIアーティファクトタイプの完全サポート

### 強化機能

- **高度なキャッシュ**: イメージ用グローバルコンテンツ配信ネットワーク
- **ビルドキャッシュ**: より高速なCI/CDのためのレジストリベースビルドキャッシュ
- **イメージプロモーション**: 自動イメージプロモーションパイプライン
- **コンプライアンススキャン**: 強化されたコンプライアンスとポリシー執行

## ヘルプの取得

### ドキュメントとサポート

```bash
# レジストリコマンドのヘルプを取得
hb registry help

# プロジェクトレジストリ状態をチェック
hb registry status --project-id my-project

# プロジェクトレジストリログを表示
hb registry logs --follow --project-id my-project
```

### 一般的な問題のトラブルシューティング

#### 認証問題
```bash
# Docker認証情報をクリア
docker logout harbor-01.registry.hexabase.ai

# 再認証
docker login harbor-01.registry.hexabase.ai

# 接続をテスト
docker pull harbor-01.registry.hexabase.ai/my-project/hello-world
```

#### ネットワーク問題
```bash
# レジストリ接続をテスト
curl -v https://harbor-01.registry.hexabase.ai/v2/

# DNS解決をチェック
nslookup harbor-01.registry.hexabase.ai
```

## 関連ドキュメント

- [アプリケーションデプロイメント](../applications/index.md) - デプロイメントでのレジストリイメージ使用
- [CI/CDパイプライン](../../cicd/index.md) - レジストリとのパイプライン統合 (English)
- [AIオペレーション](../aiops/index.md) - AI駆動の運用管理
- [RBAC設定](../rbac/index.md) - レジストリアクセス権限の管理
- [APIリファレンス](https://api.hexabase.ai/docs#registry) - 完全なAPIドキュメント