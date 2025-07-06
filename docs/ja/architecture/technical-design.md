# Hexabase KaaS コントロールプレーン実装仕様（コンパクト版）

## 1. システム概要

Hexabase KaaSは、K3sとvClusterを基盤とするマルチテナントKubernetes as a Serviceプラットフォームです。この仕様では、Goで実装されるコントロールプレーンの設計ガイドラインを定義します。

### 主な責務
- **APIサービス**: Next.js UI用RESTful API
- **認証・認可**: 外部IdP統合とJWTセッション管理
- **OIDCプロバイダー**: 各vClusterへのkubectlアクセス用トークン発行
- **vCluster管理**: 完全なライフサイクル管理
- **請求処理**: Stripe統合による購読管理
- **非同期処理**: NATSベースのタスク処理

## 2. アーキテクチャ

### コンポーネント構造
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Next.js UI │────▶│  APIサーバー │────▶│ PostgreSQL  │
└─────────────┘     └──────┬──────┘     └─────────────┘
                           │
                    ┌──────┴──────┐
                    │             │
              ┌─────▼─────┐ ┌────▼────┐
              │   NATS    │ │  Redis  │
              └─────┬─────┘ └─────────┘
                    │
              ┌─────▼─────┐
              │ ワーカー   │
              └───────────┘
```

### 外部統合
- **Host K3s**: vClusterのホスト環境
- **vCluster**: テナントごとのKubernetes環境
- **外部IdP**: Google/GitHub OIDC認証
- **Stripe**: 請求と決済処理

## 3. データベース設計

### 主要テーブル
| テーブル | 用途 |
|---------|------|
| users | ユーザーアカウント（外部IdPリンク） |
| organizations | 請求・管理単位 |
| plans | 購読プラン定義 |
| workspaces | vClusterインスタンス |
| projects | ネームスペース（HNC階層サポート） |
| groups | ワークスペースユーザーグループ |
| roles | カスタム/プリセットロール |
| role_assignments | グループからロールへのマッピング |

### 階層構造
- **Organization** → **Workspace** → **Project**
- **Group**（階層） → **Role Assignment**

## 4. API設計

### エンドポイント構造
```
/auth
  POST   /login/{provider}     # 外部IdP認証開始
  GET    /callback/{provider}  # 認証コールバック
  POST   /logout              # ログアウト
  GET    /me                  # 現在のユーザー情報

/api/v1/organizations
  POST   /                    # 組織作成
  GET    /{orgId}            # 組織詳細
  POST   /{orgId}/users      # ユーザー招待
  
/api/v1/organizations/{orgId}/workspaces
  POST   /                    # ワークスペース作成（非同期）
  GET    /{wsId}             # ワークスペース詳細
  GET    /{wsId}/kubeconfig  # kubeconfig生成

/api/v1/workspaces/{wsId}
  /groups                    # グループ管理
  /projects                  # プロジェクト（ネームスペース）管理
  /clusterroleassignments   # ClusterRole割り当て

/api/v1/projects/{projectId}
  /roles                     # カスタムロール管理
  /roleassignments          # ロール割り当て

/webhooks/stripe            # Stripeウェブフック受信
```

### 設計原則
- RESTful原則（リソース指向URL）
- JSONリクエスト/レスポンス形式
- バージョニング（/api/v1/）
- 冪等性保証
- 標準HTTPステータスコード

## 5. OIDCプロバイダー実装

### トークン構造
```json
{
  "iss": "https://auth.hexabase.ai",
  "sub": "user-uuid",
  "aud": ["workspace-123"],
  "exp": 1634567890,
  "iat": 1634564290,
  "groups": ["WSAdmins", "WorkspaceMembers"],
  "workspace_id": "ws-123"
}
```

### キー管理
- RSA 2048ビットキー
- 定期的なキーローテーション
- JWKS (.well-known/jwks.json) エンドポイント
- HA対応のキー同期

## 6. vCluster管理

### ライフサイクル管理
```go
type VClusterManager interface {
    Create(ctx context.Context, req CreateRequest) (*Workspace, error)
    Configure(ctx context.Context, wsID string, config Config) error
    Delete(ctx context.Context, wsID string) error
    GetStatus(ctx context.Context, wsID string) (*Status, error)
}
```

### 設定管理
- **リソースクォータ**: プランベースの制限
- **OIDC統合**: 自動設定
- **HNCセットアップ**: 階層ネームスペース
- **専用ノード**: Node SelectorとTaints

## 7. 非同期処理

### タスクタイプ
```go
type TaskType string

const (
    TaskCreateWorkspace TaskType = "create_workspace"
    TaskDeleteWorkspace TaskType = "delete_workspace"
    TaskSyncBilling     TaskType = "sync_billing"
    TaskBackupData      TaskType = "backup_data"
)
```

### ワーカーパターン
- **並行処理**: Goroutine pool
- **エラーハンドリング**: 指数バックオフ再試行
- **進捗追跡**: データベース状態更新
- **タイムアウト**: 長時間実行防止

## 8. セキュリティ実装

### 認証フロー
1. **外部IdP**: OAuth2/OIDC
2. **セッション**: Redis保存
3. **APIアクセス**: JWTトークン
4. **監査**: 全操作ログ

### 認可メカニズム
```go
func (a *Authorizer) CanAccess(user User, resource Resource, action Action) bool {
    // グループ階層解決
    groups := a.resolveGroups(user.Groups)
    
    // ロール権限チェック
    for _, group := range groups {
        if a.hasPermission(group, resource, action) {
            return true
        }
    }
    return false
}
```

## 9. 監視・ログ

### メトリクス
- **API応答時間**: Prometheus
- **データベース接続**: PostgreSQL統計
- **タスクキュー**: NATS統計
- **vClusterヘルス**: Kubernetes API

### ログ構造
```json
{
  "timestamp": "2024-07-06T12:00:00Z",
  "level": "INFO",
  "service": "api-server",
  "user_id": "user-123",
  "workspace_id": "ws-456",
  "action": "create_project",
  "resource": "projects/proj-789",
  "result": "success",
  "duration_ms": 150
}
```

## 10. パフォーマンス最適化

### データベース
- **接続プール**: pgxpool使用
- **インデックス**: クエリパフォーマンス
- **読み取り専用レプリカ**: 読み取り負荷分散

### キャッシュ戦略
- **セッション**: Redis
- **JWKS**: メモリキャッシュ
- **設定**: 階層キャッシュ
- **APIレスポンス**: 条件付きキャッシュ

### 並行処理
```go
// ワーカープール実装
type WorkerPool struct {
    workerCount int
    taskQueue   chan Task
    wg          sync.WaitGroup
}

func (p *WorkerPool) Start() {
    for i := 0; i < p.workerCount; i++ {
        go p.worker()
    }
}
```

## 11. テスト戦略

### テストピラミッド
- **ユニットテスト**: 85%カバレッジ
- **統合テスト**: データベース・外部API
- **E2Eテスト**: 重要ユーザーフロー

### テスト実装
```go
func TestCreateWorkspace(t *testing.T) {
    // テストデータベース
    db := setupTestDB(t)
    defer db.Close()
    
    // モックvClusterクライアント
    vcluster := &MockVClusterClient{}
    
    // サービス初期化
    svc := NewWorkspaceService(db, vcluster)
    
    // テスト実行
    ws, err := svc.Create(ctx, createReq)
    assert.NoError(t, err)
    assert.Equal(t, "active", ws.Status)
}
```

## 12. デプロイメント

### コンテナ化
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o hexabase-api ./cmd/api

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/hexabase-api /hexabase-api
CMD ["/hexabase-api"]
```

### Kubernetes設定
- **Deployment**: ローリング更新
- **Service**: ClusterIP
- **Ingress**: TLS終端
- **ConfigMap**: 環境設定
- **Secret**: 機密情報

この技術設計仕様により、スケーラブルで保守可能なHexabase KaaSコントロールプレーンの実装が可能になります。