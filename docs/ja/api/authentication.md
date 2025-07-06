# 認証

Hexabase KaaSは、API アクセス用のJWTトークンを持つOAuth2/OIDCを認証に使用します。

## 概要

認証フローは以下のステップに従います：

1. ユーザーがOAuthプロバイダーでログインを開始
2. ユーザーがプロバイダーのログインページにリダイレクト
3. 認証成功後、認可コードと共にユーザーがリダイレクトバック
4. コードがHexabase KaaS JWTトークンと交換
5. JWTトークンがすべての後続APIリクエストで使用

## サポートプロバイダー

### Google

- **プロバイダーID**: `google`
- **必要なスコープ**: `openid`, `email`, `profile`
- **設定**: OAuth 2.0クライアント認証情報が必要

### GitHub

- **プロバイダーID**: `github`
- **必要なスコープ**: `user:email`, `read:org`
- **設定**: OAuth Appの認証情報が必要

### Microsoft Azure AD

- **プロバイダーID**: `azure`
- **必要なスコープ**: `openid`, `email`, `profile`
- **設定**: Azure ADでのアプリ登録が必要

### カスタムOIDCプロバイダー

- **プロバイダーID**: カスタム識別子
- **必要なクレーム**: `sub`, `email`, `name`
- **設定**: OIDCディスカバリーエンドポイントが必要

## 認証フロー

### 認可コードフロー（Webアプリケーション）

これはWebアプリケーションに推奨されるフローです。

#### 1. ログイン開始

ユーザーを以下にリダイレクト：
```
https://api.hexabase.ai/auth/login/google?redirect_uri=https://app.hexabase.ai/auth/callback
```

#### 2. コールバック処理

認証後、ユーザーは以下にリダイレクトされます：
```
https://app.hexabase.ai/auth/callback?code=AUTHORIZATION_CODE&state=STATE
```

#### 3. コードをトークンと交換

```http
POST /auth/callback/google
Content-Type: application/json

{
  "code": "AUTHORIZATION_CODE",
  "redirect_uri": "https://app.hexabase.ai/auth/callback"
}
```

レスポンス：
```json
{
  "data": {
    "access_token": "eyJhbGciOiJSUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJSUzI1NiIs...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "name": "John Doe"
    }
  }
}
```

## トークン管理

### アクセストークン

アクセストークンは短期間有効（通常15分）で、API呼び出しに使用されます。

```http
GET /api/v1/workspaces
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

### リフレッシュトークン

リフレッシュトークンは長期間有効（通常7日間）で、新しいアクセストークンを取得するために使用されます。

```http
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJSUzI1NiIs..."
}
```

### トークンの取り消し

```http
POST /auth/revoke
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...

{
  "token": "eyJhbGciOiJSUzI1NiIs..."
}
```

## APIキー認証

長期実行スクリプトとサービス間通信には、APIキーを使用できます。

### APIキーの作成

```bash
# HKS CLIを使用
hks auth create-key --name "CI/CD Pipeline" --scope workspace:read,write

# 出力:
# API Key: hks_live_sk_1234567890abcdef
# Key ID: key_abc123
```

### APIキーの使用

```http
GET /api/v1/workspaces
Authorization: Bearer hks_live_sk_1234567890abcdef
```

### APIキーのスコープ

| スコープ | 説明 |
|---------|------|
| `workspace:read` | ワークスペース情報の読み取り |
| `workspace:write` | ワークスペース設定の変更 |
| `project:read` | プロジェクト情報の読み取り |
| `project:write` | プロジェクトリソースの管理 |
| `admin:read` | 管理者レベルの読み取りアクセス |
| `admin:write` | 管理者レベルの書き込みアクセス |

## サービスアカウント

自動化されたワークフローには、サービスアカウントを使用できます。

### サービスアカウントの作成

```bash
# Webダッシュボードまたは
hks auth create-service-account --name "Deploy Bot" \
  --scopes workspace:write,project:write
```

### サービスアカウントトークン

```json
{
  "token": "hks_svc_1234567890abcdef",
  "expires_at": "2024-12-31T23:59:59Z",
  "scopes": ["workspace:write", "project:write"]
}
```

## セキュリティベストプラクティス

### トークンストレージ

- **セキュアストレージ**: トークンを安全な場所に保存
- **暗号化**: 保存時はトークンを暗号化
- **有効期限**: トークンの有効期限を定期的に確認

### ネットワークセキュリティ

- **HTTPS**: すべてのAPIコールでHTTPS使用
- **CORS**: 適切なCORS設定
- **IP制限**: 必要に応じてIPアドレス制限

### 監査とログ

```json
{
  "timestamp": "2024-07-06T12:00:00Z",
  "event": "authentication_success",
  "user_id": "user_123",
  "provider": "google",
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "workspace_id": "ws_456"
}
```

## エラーハンドリング

### 認証エラー

```json
{
  "error": {
    "code": "AUTHENTICATION_FAILED",
    "message": "Invalid or expired token",
    "details": {
      "token_expired": true,
      "expired_at": "2024-07-06T11:00:00Z"
    }
  }
}
```

### 認可エラー

```json
{
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "Token does not have required permissions",
    "details": {
      "required_scope": "workspace:write",
      "provided_scopes": ["workspace:read"]
    }
  }
}
```

## SDKでの認証

### JavaScript/TypeScript

```javascript
import { HexabaseClient } from '@hexabase/sdk';

// OAuthフロー
const client = new HexabaseClient({
  baseURL: 'https://api.hexabase.ai',
  auth: {
    type: 'oauth',
    provider: 'google',
    clientId: 'your-client-id',
    redirectUri: 'https://app.example.com/callback'
  }
});

// APIキー
const client = new HexabaseClient({
  baseURL: 'https://api.hexabase.ai',
  auth: {
    type: 'api-key',
    key: 'hks_live_sk_1234567890abcdef'
  }
});
```

### Python

```python
from hexabase import Client, OAuthConfig, APIKeyConfig

# OAuthフロー
oauth_config = OAuthConfig(
    provider='google',
    client_id='your-client-id',
    redirect_uri='https://app.example.com/callback'
)
client = Client(auth=oauth_config)

# APIキー
api_key_config = APIKeyConfig(key='hks_live_sk_1234567890abcdef')
client = Client(auth=api_key_config)
```

## トラブルシューティング

### よくある問題

1. **Invalid redirect_uri**: リダイレクトURIがプロバイダー設定と一致しない
2. **Token expired**: アクセストークンの有効期限切れ
3. **Insufficient scope**: 必要な権限が不足
4. **Rate limiting**: 認証試行回数の制限

### デバッグのヒント

- リクエスト/レスポンスヘッダーを確認
- トークンペイロードをデコード（jwt.io使用）
- サーバーログで詳細エラーを確認
- ネットワークタイムアウト設定を確認