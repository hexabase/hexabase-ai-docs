# セキュリティ実装ディープダイブ

この包括的なガイドでは、Hexabase.AIデプロイメントのセキュリティ実装パターンを詳細に説明し、OAuth2/OIDCフロー、JWT管理、セッションセキュリティ、エンタープライズグレードのセキュリティプラクティスをカバーします。

## OAuth2/OIDC実装

### PKCE付き強化OAuth2フロー

Hexabase.AIは最大のセキュリティのためPKCE（Proof Key for Code Exchange）付きOAuth2を実装：

```go
package auth

import (
    "crypto/rand"
    "crypto/sha256"
    "encoding/base64"
    "fmt"
    "time"
)

type PKCEFlow struct {
    verifier    string
    challenge   string
    method      string
    state       string
    redirectURI string
}

// NewPKCEFlow は暗号学的に安全なパラメータで新しいPKCEフローを作成
func NewPKCEFlow(redirectURI string) (*PKCEFlow, error) {
    verifier, err := generateCodeVerifier(128)
    if err != nil {
        return nil, fmt.Errorf("コードベリファイア生成失敗: %w", err)
    }
    
    challenge := generateCodeChallenge(verifier)
    state, err := generateSecureState()
    if err != nil {
        return nil, fmt.Errorf("ステート生成失敗: %w", err)
    }
    
    return &PKCEFlow{
        verifier:    verifier,
        challenge:   challenge,
        method:      "S256",
        state:       state,
        redirectURI: redirectURI,
    }, nil
}

// generateCodeVerifier は暗号学的にランダムなコードベリファイアを作成
func generateCodeVerifier(length int) (string, error) {
    if length < 43 || length > 128 {
        return "", fmt.Errorf("コードベリファイアの長さは43〜128文字である必要があります")
    }
    
    bytes := make([]byte, length)
    if _, err := rand.Read(bytes); err != nil {
        return "", err
    }
    
    return base64.RawURLEncoding.EncodeToString(bytes)[:length], nil
}

// generateCodeChallenge はベリファイアからSHA256チャレンジを作成
func generateCodeChallenge(verifier string) string {
    hash := sha256.Sum256([]byte(verifier))
    return base64.RawURLEncoding.EncodeToString(hash[:])
}

// generateSecureState は暗号学的に安全なステートパラメータを作成
func generateSecureState() (string, error) {
    bytes := make([]byte, 32)
    if _, err := rand.Read(bytes); err != nil {
        return "", err
    }
    return base64.RawURLEncoding.EncodeToString(bytes), nil
}
```

### マルチプロバイダーOAuth設定

```go
type OAuthProvider struct {
    Name         string            `json:"name"`
    ClientID     string            `json:"client_id"`
    ClientSecret string            `json:"client_secret"`
    AuthURL      string            `json:"auth_url"`
    TokenURL     string            `json:"token_url"`
    UserInfoURL  string            `json:"user_info_url"`
    Scopes       []string          `json:"scopes"`
    ExtraParams  map[string]string `json:"extra_params"`
}

type OAuthManager struct {
    providers map[string]*OAuthProvider
    redis     RedisClient
    config    SecurityConfig
}

func (m *OAuthManager) InitiateOAuthFlow(providerName, redirectURI string) (*AuthorizeURLResponse, error) {
    provider, exists := m.providers[providerName]
    if !exists {
        return nil, ErrProviderNotFound
    }
    
    pkce, err := NewPKCEFlow(redirectURI)
    if err != nil {
        return nil, fmt.Errorf("PKCEフロー作成失敗: %w", err)
    }
    
    // PKCEパラメータをTTLで保存
    if err := m.storePKCEParams(pkce); err != nil {
        return nil, fmt.Errorf("PKCEパラメータ保存失敗: %w", err)
    }
    
    authURL := m.buildAuthorizationURL(provider, pkce)
    
    return &AuthorizeURLResponse{
        URL:   authURL,
        State: pkce.state,
    }, nil
}

func (m *OAuthManager) buildAuthorizationURL(provider *OAuthProvider, pkce *PKCEFlow) string {
    params := url.Values{}
    params.Add("client_id", provider.ClientID)
    params.Add("response_type", "code")
    params.Add("redirect_uri", pkce.redirectURI)
    params.Add("scope", strings.Join(provider.Scopes, " "))
    params.Add("state", pkce.state)
    params.Add("code_challenge", pkce.challenge)
    params.Add("code_challenge_method", pkce.method)
    
    // プロバイダー固有パラメータを追加
    for key, value := range provider.ExtraParams {
        params.Add(key, value)
    }
    
    return fmt.Sprintf("%s?%s", provider.AuthURL, params.Encode())
}
```

## 高度なJWT管理

### 強化JWTクレーム構造

```go
type HexabaseClaims struct {
    jwt.RegisteredClaims
    
    // ユーザー情報
    UserID   string `json:"uid"`
    Email    string `json:"email"`
    Name     string `json:"name"`
    Provider string `json:"provider"`
    
    // 認可コンテキスト
    Organizations []OrganizationClaim `json:"orgs"`
    Workspaces    []WorkspaceClaim    `json:"workspaces"`
    Groups        []string            `json:"groups"`
    Permissions   []Permission        `json:"perms"`
    
    // セキュリティコンテキスト
    TokenType     string `json:"typ"`        // "access" または "refresh"
    SessionID     string `json:"sid"`        // セッション識別子
    DeviceID      string `json:"did"`        // デバイスフィンガープリント
    IPAddress     string `json:"ip"`         // クライアントIPアドレス
    TokenVersion  int    `json:"ver"`        // トークンフォーマットバージョン
    
    // 監査コンテキスト
    LoginTime     int64  `json:"login_at"`   // 初回ログインタイムスタンプ
    LastRefresh   int64  `json:"refresh_at"` // 最後のトークン更新時刻
}

type OrganizationClaim struct {
    ID   string   `json:"id"`
    Role string   `json:"role"`
    Permissions []string `json:"perms"`
}

type WorkspaceClaim struct {
    ID             string   `json:"id"`
    OrganizationID string   `json:"org_id"`
    Role           string   `json:"role"`
    Groups         []string `json:"groups"`
    Permissions    []string `json:"perms"`
}

type Permission struct {
    Resource string `json:"resource"`
    Action   string `json:"action"`
    Scope    string `json:"scope"`
}
```

### トークンセキュリティ実装

```go
type TokenManager struct {
    privateKey    *rsa.PrivateKey
    publicKey     *rsa.PublicKey
    redis         RedisClient
    config        TokenConfig
    revokedTokens *sync.Map // 取り消されたトークンのインメモリキャッシュ
}

func (tm *TokenManager) GenerateTokenPair(user *User, deviceFingerprint string) (*TokenPair, error) {
    sessionID := tm.generateSessionID()
    now := time.Now()
    
    // 強化クレームを作成
    claims := &HexabaseClaims{
        RegisteredClaims: jwt.RegisteredClaims{
            Subject:   user.ID,
            Issuer:    tm.config.Issuer,
            Audience:  []string{tm.config.Audience},
            IssuedAt:  jwt.NewNumericDate(now),
            NotBefore: jwt.NewNumericDate(now),
        },
        UserID:        user.ID,
        Email:         user.Email,
        Name:          user.Name,
        Provider:      user.Provider,
        Organizations: tm.buildOrganizationClaims(user),
        Workspaces:    tm.buildWorkspaceClaims(user),
        Groups:        user.Groups,
        Permissions:   user.Permissions,
        SessionID:     sessionID,
        DeviceID:      deviceFingerprint,
        IPAddress:     user.LastLoginIP,
        TokenVersion:  tm.config.TokenVersion,
        LoginTime:     now.Unix(),
    }
    
    // アクセストークンを生成（15分）
    accessClaims := *claims
    accessClaims.TokenType = "access"
    accessClaims.ExpiresAt = jwt.NewNumericDate(now.Add(15 * time.Minute))
    
    accessToken, err := tm.signToken(&accessClaims)
    if err != nil {
        return nil, fmt.Errorf("アクセストークン署名失敗: %w", err)
    }
    
    // リフレッシュトークンを生成（7日）
    refreshClaims := *claims
    refreshClaims.TokenType = "refresh"
    refreshClaims.ExpiresAt = jwt.NewNumericDate(now.Add(7 * 24 * time.Hour))
    // リフレッシュトークンから機密クレームを削除
    refreshClaims.Permissions = nil
    refreshClaims.Organizations = nil
    refreshClaims.Workspaces = nil
    
    refreshToken, err := tm.signToken(&refreshClaims)
    if err != nil {
        return nil, fmt.Errorf("リフレッシュトークン署名失敗: %w", err)
    }
    
    // セッション情報を保存
    if err := tm.storeSession(sessionID, user, deviceFingerprint); err != nil {
        return nil, fmt.Errorf("セッション保存失敗: %w", err)
    }
    
    return &TokenPair{
        AccessToken:  accessToken,
        RefreshToken: refreshToken,
        TokenType:    "Bearer",
        ExpiresIn:    900, // 15分
        ExpiresAt:    now.Add(15 * time.Minute),
        SessionID:    sessionID,
    }, nil
}

func (tm *TokenManager) ValidateToken(tokenString string) (*HexabaseClaims, error) {
    // 取り消しリストを最初にチェック（高速パス）
    if tm.isTokenRevoked(tokenString) {
        return nil, ErrTokenRevoked
    }
    
    // トークンを解析・検証
    token, err := jwt.ParseWithClaims(tokenString, &HexabaseClaims{}, func(token *jwt.Token) (interface{}, error) {
        if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
            return nil, fmt.Errorf("予期しない署名方法: %v", token.Header["alg"])
        }
        return tm.publicKey, nil
    })
    
    if err != nil {
        return nil, fmt.Errorf("トークン解析失敗: %w", err)
    }
    
    claims, ok := token.Claims.(*HexabaseClaims)
    if !ok || !token.Valid {
        return nil, ErrInvalidToken
    }
    
    // 追加のセキュリティ検証
    if err := tm.validateTokenSecurity(claims); err != nil {
        return nil, err
    }
    
    return claims, nil
}

func (tm *TokenManager) validateTokenSecurity(claims *HexabaseClaims) error {
    // トークンバージョンチェック
    if claims.TokenVersion < tm.config.MinTokenVersion {
        return ErrTokenVersionTooOld
    }
    
    // セッションが存在し、アクティブかを検証
    if !tm.isSessionActive(claims.SessionID) {
        return ErrSessionInactive
    }
    
    // 並行セッション制限をチェック
    if tm.exceedsConcurrentSessionLimit(claims.UserID) {
        return ErrTooManySessions
    }
    
    return nil
}
```

## セッションセキュリティ管理

### セキュアセッション実装

```go
type SessionManager struct {
    redis          RedisClient
    config         SessionConfig
    deviceTracker  DeviceTracker
    threatDetector ThreatDetector
}

type SecureSession struct {
    ID              string    `json:"id"`
    UserID          string    `json:"user_id"`
    DeviceID        string    `json:"device_id"`
    IPAddress       string    `json:"ip_address"`
    UserAgent       string    `json:"user_agent"`
    Provider        string    `json:"provider"`
    CreatedAt       time.Time `json:"created_at"`
    LastActive      time.Time `json:"last_active"`
    ExpiresAt       time.Time `json:"expires_at"`
    RefreshToken    string    `json:"refresh_token"`
    SecurityLevel   string    `json:"security_level"`
    ThreatScore     float64   `json:"threat_score"`
    IsCompromised   bool      `json:"is_compromised"`
    LoginContext    LoginContext `json:"login_context"`
}

type LoginContext struct {
    Location      GeoLocation `json:"location"`
    DeviceInfo    DeviceInfo  `json:"device_info"`
    NetworkInfo   NetworkInfo `json:"network_info"`
    BrowserInfo   BrowserInfo `json:"browser_info"`
    SecurityFlags []string    `json:"security_flags"`
}

func (sm *SessionManager) CreateSession(user *User, request *http.Request) (*SecureSession, error) {
    deviceID := sm.deviceTracker.GenerateDeviceFingerprint(request)
    
    // 脅威分析を実行
    threatScore := sm.threatDetector.AnalyzeRequest(user, request)
    if threatScore > sm.config.MaxThreatScore {
        return nil, ErrSuspiciousActivity
    }
    
    session := &SecureSession{
        ID:            sm.generateSessionID(),
        UserID:        user.ID,
        DeviceID:      deviceID,
        IPAddress:     sm.extractClientIP(request),
        UserAgent:     request.UserAgent(),
        Provider:      user.Provider,
        CreatedAt:     time.Now(),
        LastActive:    time.Now(),
        ExpiresAt:     time.Now().Add(sm.config.SessionTimeout),
        SecurityLevel: sm.determineSecurityLevel(user, request),
        ThreatScore:   threatScore,
        LoginContext:  sm.buildLoginContext(request),
    }
    
    // 適切なTTLでセッションを保存
    if err := sm.storeSession(session); err != nil {
        return nil, fmt.Errorf("セッション保存失敗: %w", err)
    }
    
    // 並行セッション制限をチェック
    if err := sm.enforceConcurrentSessionLimits(user.ID); err != nil {
        return nil, err
    }
    
    return session, nil
}

func (sm *SessionManager) ValidateSession(sessionID, userID string, request *http.Request) error {
    session, err := sm.getSession(sessionID)
    if err != nil {
        return fmt.Errorf("セッションが見つかりません: %w", err)
    }
    
    // 基本検証
    if session.UserID != userID {
        return ErrSessionMismatch
    }
    
    if session.IsCompromised {
        return ErrSessionCompromised
    }
    
    if time.Now().After(session.ExpiresAt) {
        return ErrSessionExpired
    }
    
    // セキュリティ検証
    if err := sm.validateSessionSecurity(session, request); err != nil {
        return err
    }
    
    // 最終アクティブ時刻を更新
    session.LastActive = time.Now()
    session.ExpiresAt = time.Now().Add(sm.config.SessionTimeout)
    
    if err := sm.updateSession(session); err != nil {
        return fmt.Errorf("セッション更新失敗: %w", err)
    }
    
    return nil
}

func (sm *SessionManager) validateSessionSecurity(session *SecureSession, request *http.Request) error {
    // IPアドレス検証（モバイルネットワークの考慮あり）
    currentIP := sm.extractClientIP(request)
    if !sm.isIPAddressAllowed(session.IPAddress, currentIP) {
        sm.flagSuspiciousActivity(session, "ip_address_change")
        return ErrSuspiciousIPChange
    }
    
    // デバイスフィンガープリント検証
    currentDeviceID := sm.deviceTracker.GenerateDeviceFingerprint(request)
    if session.DeviceID != currentDeviceID {
        sm.flagSuspiciousActivity(session, "device_fingerprint_change")
        return ErrSuspiciousDeviceChange
    }
    
    // ユーザーエージェント検証
    if !sm.isUserAgentConsistent(session.UserAgent, request.UserAgent()) {
        sm.flagSuspiciousActivity(session, "user_agent_change")
        return ErrSuspiciousUserAgentChange
    }
    
    return nil
}
```

## レート制限とDDoS保護

### 高度なレート制限実装

```go
type RateLimiter struct {
    redis     RedisClient
    config    RateLimitConfig
    rules     map[string]RateLimit
    whitelist *IPWhitelist
}

type RateLimit struct {
    Requests     int           `json:"requests"`
    Window       time.Duration `json:"window"`
    BurstSize    int           `json:"burst_size"`
    BackoffType  string        `json:"backoff_type"`
    BackoffMultiplier float64  `json:"backoff_multiplier"`
}

type RateLimitContext struct {
    UserID     string
    IPAddress  string
    Endpoint   string
    Method     string
    UserAgent  string
    IsAuthenticated bool
}

func (rl *RateLimiter) CheckRateLimit(ctx context.Context, context RateLimitContext) error {
    // まずホワイトリストをチェック
    if rl.whitelist.IsWhitelisted(context.IPAddress) {
        return nil
    }
    
    // 複数のレート制限戦略を適用
    checks := []func(context.Context, RateLimitContext) error{
        rl.checkPerIPLimit,
        rl.checkPerUserLimit,
        rl.checkPerEndpointLimit,
        rl.checkGlobalLimit,
    }
    
    for _, check := range checks {
        if err := check(ctx, context); err != nil {
            return err
        }
    }
    
    return nil
}

func (rl *RateLimiter) checkPerIPLimit(ctx context.Context, context RateLimitContext) error {
    key := fmt.Sprintf("rate_limit:ip:%s", context.IPAddress)
    limit := rl.rules["per_ip"]
    
    return rl.checkLimit(ctx, key, limit, map[string]interface{}{
        "ip_address": context.IPAddress,
        "endpoint":   context.Endpoint,
    })
}

func (rl *RateLimiter) checkLimit(ctx context.Context, key string, limit RateLimit, metadata map[string]interface{}) error {
    pipeline := rl.redis.TxPipeline()
    
    // スライディングウィンドウカウンター実装
    now := time.Now()
    windowStart := now.Add(-limit.Window)
    
    // 古いエントリを削除
    pipeline.ZRemRangeByScore(ctx, key, "0", fmt.Sprintf("%.0f", float64(windowStart.UnixNano())))
    
    // 現在のリクエストを追加
    pipeline.ZAdd(ctx, key, &redis.Z{
        Score:  float64(now.UnixNano()),
        Member: fmt.Sprintf("%d:%s", now.UnixNano(), generateRequestID()),
    })
    
    // ウィンドウ内のリクエストをカウント
    pipeline.ZCard(ctx, key)
    
    // TTLを設定
    pipeline.Expire(ctx, key, limit.Window*2)
    
    results, err := pipeline.Exec(ctx)
    if err != nil {
        return fmt.Errorf("レート制限チェック失敗: %w", err)
    }
    
    count := results[2].(*redis.IntCmd).Val()
    
    if count > int64(limit.Requests) {
        // レート制限違反をログ
        rl.logViolation(key, count, limit, metadata)
        
        // バックオフ期間を計算
        backoffDuration := rl.calculateBackoff(key, limit)
        
        return &RateLimitExceededError{
            Limit:           limit.Requests,
            Window:          limit.Window,
            Current:         int(count),
            RetryAfter:      backoffDuration,
            BackoffType:     limit.BackoffType,
        }
    }
    
    return nil
}

func (rl *RateLimiter) calculateBackoff(key string, limit RateLimit) time.Duration {
    switch limit.BackoffType {
    case "exponential":
        violations := rl.getViolationCount(key)
        multiplier := math.Pow(limit.BackoffMultiplier, float64(violations))
        return time.Duration(float64(limit.Window) * multiplier)
    case "linear":
        violations := rl.getViolationCount(key)
        return limit.Window * time.Duration(violations+1)
    default:
        return limit.Window
    }
}
```

## ネットワークセキュリティとTLS

### TLS設定

```go
type TLSConfig struct {
    CertFile          string   `yaml:"cert_file"`
    KeyFile           string   `yaml:"key_file"`
    CAFile            string   `yaml:"ca_file"`
    MinVersion        string   `yaml:"min_version"`
    CipherSuites      []string `yaml:"cipher_suites"`
    EnableHSTS        bool     `yaml:"enable_hsts"`
    HSTSMaxAge        int      `yaml:"hsts_max_age"`
    EnableOCSP        bool     `yaml:"enable_ocsp"`
    CertificatePinning bool    `yaml:"certificate_pinning"`
}

func (tc *TLSConfig) GetTLSConfig() (*tls.Config, error) {
    cert, err := tls.LoadX509KeyPair(tc.CertFile, tc.KeyFile)
    if err != nil {
        return nil, fmt.Errorf("キーペア読み込み失敗: %w", err)
    }
    
    config := &tls.Config{
        Certificates: []tls.Certificate{cert},
        MinVersion:   tc.getMinTLSVersion(),
        CipherSuites: tc.getCipherSuites(),
        CurvePreferences: []tls.CurveID{
            tls.CurveP521,
            tls.CurveP384,
            tls.CurveP256,
        },
        PreferServerCipherSuites: true,
    }
    
    // CA証明書が指定されている場合は読み込み
    if tc.CAFile != "" {
        caCert, err := ioutil.ReadFile(tc.CAFile)
        if err != nil {
            return nil, fmt.Errorf("CAファイル読み込み失敗: %w", err)
        }
        
        caCertPool := x509.NewCertPool()
        caCertPool.AppendCertsFromPEM(caCert)
        config.ClientCAs = caCertPool
        config.ClientAuth = tls.RequireAndVerifyClientCert
    }
    
    return config, nil
}

func (tc *TLSConfig) getMinTLSVersion() uint16 {
    switch tc.MinVersion {
    case "1.3":
        return tls.VersionTLS13
    case "1.2":
        return tls.VersionTLS12
    default:
        return tls.VersionTLS13 // デフォルトはTLS 1.3
    }
}
```

### セキュリティヘッダーミドルウェア

```go
func SecurityHeadersMiddleware(config SecurityConfig) gin.HandlerFunc {
    return func(c *gin.Context) {
        // HSTS - HTTP Strict Transport Security
        if config.EnableHSTS {
            c.Header("Strict-Transport-Security", 
                fmt.Sprintf("max-age=%d; includeSubDomains", config.HSTSMaxAge))
        }
        
        // Content Security Policy
        csp := buildContentSecurityPolicy(config.CSPConfig)
        c.Header("Content-Security-Policy", csp)
        
        // X-Frame-Options - クリックジャッキング保護
        c.Header("X-Frame-Options", "DENY")
        
        // X-Content-Type-Options - MIMEタイプスニッフィング保護
        c.Header("X-Content-Type-Options", "nosniff")
        
        // X-XSS-Protection
        c.Header("X-XSS-Protection", "1; mode=block")
        
        // Referrer Policy
        c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
        
        // Permissions Policy
        c.Header("Permissions-Policy", "geolocation=(), microphone=(), camera=()")
        
        // カスタムセキュリティヘッダー
        for key, value := range config.CustomHeaders {
            c.Header(key, value)
        }
        
        c.Next()
    }
}

func buildContentSecurityPolicy(config CSPConfig) string {
    directives := []string{
        fmt.Sprintf("default-src %s", strings.Join(config.DefaultSrc, " ")),
        fmt.Sprintf("script-src %s", strings.Join(config.ScriptSrc, " ")),
        fmt.Sprintf("style-src %s", strings.Join(config.StyleSrc, " ")),
        fmt.Sprintf("img-src %s", strings.Join(config.ImgSrc, " ")),
        fmt.Sprintf("connect-src %s", strings.Join(config.ConnectSrc, " ")),
        fmt.Sprintf("font-src %s", strings.Join(config.FontSrc, " ")),
        fmt.Sprintf("object-src %s", strings.Join(config.ObjectSrc, " ")),
        fmt.Sprintf("media-src %s", strings.Join(config.MediaSrc, " ")),
        fmt.Sprintf("frame-src %s", strings.Join(config.FrameSrc, " ")),
    }
    
    if config.ReportURI != "" {
        directives = append(directives, fmt.Sprintf("report-uri %s", config.ReportURI))
    }
    
    return strings.Join(directives, "; ")
}
```

## 監査ログとコンプライアンス

### 包括的監査ログ

```go
type AuditLogger struct {
    clickhouse ClickHouseClient
    config     AuditConfig
    buffer     chan AuditEvent
}

type AuditEvent struct {
    ID           string                 `json:"id"`
    Timestamp    time.Time              `json:"timestamp"`
    EventType    string                 `json:"event_type"`
    UserID       string                 `json:"user_id"`
    SessionID    string                 `json:"session_id"`
    IPAddress    string                 `json:"ip_address"`
    UserAgent    string                 `json:"user_agent"`
    ResourceType string                 `json:"resource_type"`
    ResourceID   string                 `json:"resource_id"`
    Action       string                 `json:"action"`
    Success      bool                   `json:"success"`
    ErrorCode    string                 `json:"error_code"`
    ErrorMessage string                 `json:"error_message"`
    RequestID    string                 `json:"request_id"`
    Duration     time.Duration          `json:"duration"`
    Metadata     map[string]interface{} `json:"metadata"`
    Severity     string                 `json:"severity"`
    Compliance   []string               `json:"compliance"`
}

func (al *AuditLogger) LogSecurityEvent(event AuditEvent) {
    event.ID = generateAuditID()
    event.Timestamp = time.Now()
    event.Severity = al.determineSeverity(event)
    event.Compliance = al.getComplianceFlags(event)
    
    // バッチ処理用のバッファに追加
    select {
    case al.buffer <- event:
        // イベントが正常にバッファされました
    default:
        // バッファが満杯、重要なエラーをログ
        log.Error("監査ログバッファが満杯、イベントを破棄", 
            "event_id", event.ID, "event_type", event.EventType)
    }
}

func (al *AuditLogger) LogAuthenticationAttempt(userID, provider, ipAddress string, success bool, errorCode string) {
    event := AuditEvent{
        EventType:    "authentication_attempt",
        UserID:       userID,
        IPAddress:    ipAddress,
        Action:       "login",
        Success:      success,
        ErrorCode:    errorCode,
        ResourceType: "auth",
        Metadata: map[string]interface{}{
            "provider": provider,
        },
    }
    
    if !success {
        event.Severity = "HIGH"
        // ブルートフォース検知のため失敗試行を追跡
        al.trackFailedAttempt(userID, ipAddress)
    }
    
    al.LogSecurityEvent(event)
}

func (al *AuditLogger) LogResourceAccess(userID, sessionID, resourceType, resourceID, action string, success bool) {
    event := AuditEvent{
        EventType:    "resource_access",
        UserID:       userID,
        SessionID:    sessionID,
        ResourceType: resourceType,
        ResourceID:   resourceID,
        Action:       action,
        Success:      success,
    }
    
    al.LogSecurityEvent(event)
}

func (al *AuditLogger) LogPermissionChange(adminUserID, targetUserID, permissionType, action string, metadata map[string]interface{}) {
    event := AuditEvent{
        EventType:    "permission_change",
        UserID:       adminUserID,
        ResourceType: "user_permission",
        ResourceID:   targetUserID,
        Action:       action,
        Success:      true,
        Severity:     "MEDIUM",
        Metadata:     metadata,
        Compliance:   []string{"SOC2", "GDPR"},
    }
    
    al.LogSecurityEvent(event)
}
```

## 脅威検知と応答

### 行動分析

```go
type ThreatDetector struct {
    redis       RedisClient
    ml          MLService
    rules       []ThreatRule
    alerting    AlertingService
}

type ThreatRule struct {
    Name        string    `json:"name"`
    Description string    `json:"description"`
    Condition   string    `json:"condition"`
    Severity    string    `json:"severity"`
    Action      string    `json:"action"`
    Threshold   float64   `json:"threshold"`
    TimeWindow  time.Duration `json:"time_window"`
}

func (td *ThreatDetector) AnalyzeUserBehavior(userID string, activity UserActivity) ThreatAssessment {
    // ユーザー行動パターンを収集
    patterns := td.getUserPatterns(userID)
    
    // 異常スコアを計算
    scores := map[string]float64{
        "login_frequency":    td.analyzeLoginFrequency(userID, activity),
        "access_patterns":    td.analyzeAccessPatterns(userID, activity),
        "geo_location":       td.analyzeGeoLocation(userID, activity),
        "device_consistency": td.analyzeDeviceConsistency(userID, activity),
        "time_of_day":       td.analyzeTimePatterns(userID, activity),
    }
    
    // 高度な分析のためのMLモデルを適用
    mlScore := td.ml.PredictThreatScore(patterns, activity)
    
    // スコアを組み合わせ
    totalScore := td.combineScores(scores, mlScore)
    
    assessment := ThreatAssessment{
        UserID:      userID,
        Score:       totalScore,
        Timestamp:   time.Now(),
        Indicators:  scores,
        MLScore:     mlScore,
        RiskLevel:   td.calculateRiskLevel(totalScore),
    }
    
    // 脅威ルールをチェック
    for _, rule := range td.rules {
        if td.evaluateRule(rule, assessment) {
            td.triggerThreatResponse(rule, assessment)
        }
    }
    
    return assessment
}

func (td *ThreatDetector) triggerThreatResponse(rule ThreatRule, assessment ThreatAssessment) {
    switch rule.Action {
    case "alert":
        td.alerting.SendSecurityAlert(assessment, rule)
    case "block_user":
        td.blockUser(assessment.UserID, rule.Name)
    case "require_mfa":
        td.requireMFA(assessment.UserID)
    case "invalidate_sessions":
        td.invalidateUserSessions(assessment.UserID)
    }
}
```

この包括的なセキュリティ実装ガイドは、Hexabase.AIデプロイメント用のエンタープライズグレードのセキュリティパターンを提供します。これらの実装は業界のベストプラクティスに従い、プラットフォームの全層にわたって多層防御セキュリティを提供します。

具体的なセキュリティに関する質問やカスタム実装については、セキュリティチームに相談するか、リポジトリでセキュリティ関連のイシューを作成してください。