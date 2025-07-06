# Hexabase KaaS: OAuth セキュリティ実装仕様

## 目次

1. [概要](#1-概要)
2. [セキュリティアーキテクチャ](#2-セキュリティアーキテクチャ)
3. [OAuth2/OIDC実装](#3-oauth2oidc実装)
4. [JWTトークン管理](#4-jwtトークン管理)
5. [セッション管理](#5-セッション管理)
6. [セキュリティミドルウェア](#6-セキュリティミドルウェア)
7. [レート制限とDDoS保護](#7-レート制限とddos保護)
8. [監査ログ](#8-監査ログ)
9. [テスト戦略](#9-テスト戦略)
10. [セキュリティベストプラクティス](#10-セキュリティベストプラクティス)
11. [AIOpsセキュリティサンドボックスモデル](#11-aiopsセキュリティサンドボックスモデル)

## 1. 概要

Hexabase KaaSプラットフォームは、強化されたセキュリティ機能を備えた包括的なOAuth2/OIDCベースの認証システムを実装しています。この仕様書では、セキュアなマルチテナントKubernetesプラットフォームを維持するためのセキュリティアーキテクチャ、実装詳細、およびベストプラクティスを文書化しています。

### 1.1 セキュリティ目標

- **ゼロトラストアーキテクチャ**: 暗黙の信頼なし；すべてのリクエストが認証・認可される
- **多層防御**: 複数のセキュリティ制御レイヤー
- **最小権限**: ユーザーとサービスは必要最小限の権限のみ
- **監査証跡**: すべてのセキュリティ関連イベントの完全ログ
- **コンプライアンス**: OWASP Top 10、OAuth 2.0 RFC 6749、OIDC標準

### 1.2 脅威モデル

対処する主要な脅威：

- **トークン盗取**: JWTハイジャック、セッション固定
- **中間者攻撃**: TLS強制、HSTS
- **クロスサイト攻撃**: CSRF、XSS、クリックジャッキング
- **ブルートフォース**: レート制限、アカウントロックアウト
- **セッションハイジャック**: IP/デバイス検証、同時セッション制限

## 2. セキュリティアーキテクチャ

### 2.1 コンポーネント概要

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  フロントエンドUI │────▶│   APIゲートウェイ  │────▶│   認証サービス    │
│   (Next.js)     │     │   (セキュリティ)   │     │   (OAuth/JWT)   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  セッションストア │     │   レート制限器    │     │   監査ログ       │
│    (Redis)      │     │    (Redis)      │     │  (PostgreSQL)   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 2.2 セキュリティレイヤー

1. **ネットワークレイヤー**

   - TLS 1.3最小
   - HSTS強制
   - 重要エンドポイントの証明書ピニング

2. **アプリケーションレイヤー**

   - OAuth2/OIDC認証
   - JWTトークン検証
   - RBAC認可

3. **セッションレイヤー**

   - セキュアセッション管理
   - デバイスフィンガープリンティング
   - 同時セッション制御

4. **データレイヤー**
   - 保存時暗号化
   - セキュアキー管理
   - データベースアクセス制御

## 3. OAuth2/OIDC実装

### 3.1 サポートプロバイダー

```go
type OAuthProvider struct {
    ClientID     string
    ClientSecret string
    RedirectURL  string
    Scopes       []string
    AuthURL      string
    TokenURL     string
    UserInfoURL  string
}

// 設定済みプロバイダー
providers := map[string]OAuthProvider{
    "google": {...},
    "github": {...},
    "gitlab": {...},
}
```

### 3.2 PKCEを使用したOAuthフロー

実装では、セキュリティ強化のためPKCE（Proof Key for Code Exchange）をサポートしています：

```go
// 1. コード検証子とチャレンジ生成
verifier := GenerateCodeVerifier()  // 128文字 base64url
challenge := GenerateCodeChallenge(verifier)  // SHA256(verifier)

// 2. 認可リクエスト
authURL := provider.AuthCodeURL(state,
    oauth2.SetAuthURLParam("code_challenge", challenge),
    oauth2.SetAuthURLParam("code_challenge_method", "S256"),
)

// 3. 検証子を使用したトークン交換
token := provider.Exchange(ctx, code,
    oauth2.SetAuthURLParam("code_verifier", verifier),
)
```

### 3.3 Stateパラメータ検証

暗号学的にセキュアなstateパラメータを使用したCSRF保護：

```go
// State生成とストレージ
state := GenerateSecureState()  // 32バイトランダム
redis.SetWithTTL("oauth_state:"+state, "valid", 10*time.Minute)

// State検証と消費
func ValidateAndConsumeState(state string) error {
    _, err := redis.GetDel("oauth_state:"+state)
    return err  // Stateは一度のみ使用可能
}
```

## 4. JWTトークン管理

### 4.1 トークン構造

Hexabaseで使用されるJWTトークンの標準構造：

```json
{
  "header": {
    "alg": "RS256",
    "typ": "JWT",
    "kid": "key-id-2024"
  },
  "payload": {
    "iss": "https://auth.hexabase.ai",
    "sub": "user-uuid",
    "aud": ["hexabase-api", "workspace-123"],
    "exp": 1634567890,
    "iat": 1634564290,
    "nbf": 1634564290,
    "jti": "token-uuid",
    "scope": "read write",
    "groups": ["WSAdmins", "WorkspaceMembers"],
    "workspace_id": "ws-123",
    "org_id": "org-456"
  }
}
```

### 4.2 トークンライフサイクル

- **アクセストークン**: 15分の有効期限
- **リフレッシュトークン**: 7日間の有効期限（回転）
- **IDトークン**: 認証のみ、短期間有効

### 4.3 トークン取り消し

```go
// トークンブラックリスト機能
func RevokeToken(tokenID string, expiry time.Time) error {
    return redis.SetWithTTL("revoked:"+tokenID, "true", 
        time.Until(expiry))
}

func IsTokenRevoked(tokenID string) bool {
    return redis.Exists("revoked:"+tokenID)
}
```

## 5. セッション管理

### 5.1 セッションストレージ

```go
type Session struct {
    UserID        string    `json:"user_id"`
    WorkspaceID   string    `json:"workspace_id"`
    DeviceInfo    string    `json:"device_info"`
    IPAddress     string    `json:"ip_address"`
    LastActivity  time.Time `json:"last_activity"`
    RefreshToken  string    `json:"refresh_token"`
    CSRFToken     string    `json:"csrf_token"`
}
```

### 5.2 セッションセキュリティ

- **HTTPSのみ**: セキュアフラグ付きクッキー
- **SameSite**: CSRF攻撃防止
- **HttpOnly**: XSS攻撃防止
- **デバイスバインディング**: フィンガープリンティング

## 6. セキュリティミドルウェア

### 6.1 認証ミドルウェア

```go
func AuthMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        token := extractToken(r)
        if token == "" {
            http.Error(w, "Unauthorized", 401)
            return
        }
        
        claims, err := validateJWT(token)
        if err != nil {
            http.Error(w, "Invalid token", 401)
            return
        }
        
        ctx := context.WithValue(r.Context(), "user", claims)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
```

### 6.2 RBAC認可

```go
func RBACMiddleware(required Permission) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        user := getUserFromContext(r.Context())
        if !user.HasPermission(required) {
            http.Error(w, "Forbidden", 403)
            return
        }
        next.ServeHTTP(w, r)
    })
}
```

## 7. レート制限とDDoS保護

### 7.1 階層化レート制限

```go
type RateLimiter struct {
    // グローバル制限（全ユーザー）
    Global *rate.Limiter
    
    // ユーザー別制限
    PerUser map[string]*rate.Limiter
    
    // IP別制限
    PerIP map[string]*rate.Limiter
    
    // エンドポイント別制限
    PerEndpoint map[string]*rate.Limiter
}
```

### 7.2 適応的レート制限

- **通常時**: 1000 req/hour/user
- **認証失敗後**: 10 req/hour/IP（指数バックオフ）
- **スパイク検出**: 動的制限調整

## 8. 監査ログ

### 8.1 ログ構造

```json
{
  "timestamp": "2024-07-06T12:00:00Z",
  "event_type": "authentication",
  "action": "login_success",
  "user_id": "user-123",
  "workspace_id": "ws-456",
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "resource": "/api/v1/projects",
  "result": "success",
  "metadata": {
    "mfa_used": true,
    "device_trusted": false
  }
}
```

### 8.2 重要イベント

- 認証イベント（成功/失敗）
- 権限変更
- リソース作成/変更/削除
- 管理者操作
- セキュリティポリシー変更

## 9. テスト戦略

### 9.1 セキュリティテスト

- **ペネトレーションテスト**: 外部セキュリティ監査
- **脆弱性スキャン**: 自動化されたセキュリティチェック
- **SAST/DAST**: 静的・動的アプリケーションセキュリティテスト

### 9.2 認証テスト

```go
func TestOAuthFlow(t *testing.T) {
    // PKCEフローテスト
    verifier := GenerateCodeVerifier()
    challenge := GenerateCodeChallenge(verifier)
    
    // 認証URLテスト
    authURL := BuildAuthURL(challenge)
    assert.Contains(t, authURL, "code_challenge")
    
    // トークン交換テスト
    token := ExchangeCodeForToken(authCode, verifier)
    assert.NotEmpty(t, token.AccessToken)
}
```

## 10. セキュリティベストプラクティス

### 10.1 開発者ガイドライン

- **シークレット管理**: 環境変数/vaultを使用
- **入力検証**: すべての入力を検証・サニタイズ
- **エラーハンドリング**: 機密情報の漏洩防止
- **依存関係**: 定期的なセキュリティ更新

### 10.2 運用セキュリティ

- **定期監査**: アクセス権限とログの確認
- **インシデント対応**: セキュリティ侵害対応手順
- **バックアップ**: 暗号化されたバックアップ戦略
- **災害復旧**: セキュリティを考慮した復旧計画

## 11. AIOpsセキュリティサンドボックスモデル

### 11.1 分離アーキテクチャ

AIOpsシステムは、セキュリティ侵害のリスクを最小化するため、独立したサンドボックス環境で実行されます。

```
┌─────────────────────────────────────────┐
│            AIOpsサンドボックス             │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │  AIエージェント│  │  プライベートLLM   │   │
│  │             │  │   (Ollama)      │   │
│  └─────────────┘  └─────────────────┘   │
│  ┌─────────────────────────────────────┐ │
│  │        リソース制限                   │ │
│  │  CPU: 2コア, RAM: 4GB, ネットワーク制限 │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 11.2 セキュリティ制御

- **ネットワーク分離**: VPCとファイアウォールルール
- **リソース制限**: CPU、メモリ、ストレージクォータ
- **権限制限**: 最小必要権限のみ
- **監査ログ**: すべてのAI操作をログ記録
- **タイムアウト**: 長時間実行の防止

この包括的なセキュリティアーキテクチャにより、Hexabase KaaSプラットフォームは、企業レベルのセキュリティ要件を満たしながら、使いやすいマルチテナントKubernetes環境を提供します。