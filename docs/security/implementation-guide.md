# Security Implementation Deep Dive

This comprehensive guide provides detailed implementation patterns for securing Hexabase.AI deployments, covering OAuth2/OIDC flows, JWT management, session security, and enterprise-grade security practices.

## OAuth2/OIDC Implementation

### Enhanced OAuth2 Flow with PKCE

Hexabase.AI implements OAuth2 with PKCE (Proof Key for Code Exchange) for maximum security:

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

// NewPKCEFlow creates a new PKCE flow with cryptographically secure parameters
func NewPKCEFlow(redirectURI string) (*PKCEFlow, error) {
    verifier, err := generateCodeVerifier(128)
    if err != nil {
        return nil, fmt.Errorf("failed to generate code verifier: %w", err)
    }
    
    challenge := generateCodeChallenge(verifier)
    state, err := generateSecureState()
    if err != nil {
        return nil, fmt.Errorf("failed to generate state: %w", err)
    }
    
    return &PKCEFlow{
        verifier:    verifier,
        challenge:   challenge,
        method:      "S256",
        state:       state,
        redirectURI: redirectURI,
    }, nil
}

// generateCodeVerifier creates a cryptographically random code verifier
func generateCodeVerifier(length int) (string, error) {
    if length < 43 || length > 128 {
        return "", fmt.Errorf("code verifier length must be between 43 and 128 characters")
    }
    
    bytes := make([]byte, length)
    if _, err := rand.Read(bytes); err != nil {
        return "", err
    }
    
    return base64.RawURLEncoding.EncodeToString(bytes)[:length], nil
}

// generateCodeChallenge creates SHA256 challenge from verifier
func generateCodeChallenge(verifier string) string {
    hash := sha256.Sum256([]byte(verifier))
    return base64.RawURLEncoding.EncodeToString(hash[:])
}

// generateSecureState creates a cryptographically secure state parameter
func generateSecureState() (string, error) {
    bytes := make([]byte, 32)
    if _, err := rand.Read(bytes); err != nil {
        return "", err
    }
    return base64.RawURLEncoding.EncodeToString(bytes), nil
}
```

### Multi-Provider OAuth Configuration

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
        return nil, fmt.Errorf("failed to create PKCE flow: %w", err)
    }
    
    // Store PKCE parameters with TTL
    if err := m.storePKCEParams(pkce); err != nil {
        return nil, fmt.Errorf("failed to store PKCE params: %w", err)
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
    
    // Add provider-specific parameters
    for key, value := range provider.ExtraParams {
        params.Add(key, value)
    }
    
    return fmt.Sprintf("%s?%s", provider.AuthURL, params.Encode())
}
```

## Advanced JWT Management

### Enhanced JWT Claims Structure

```go
type HexabaseClaims struct {
    jwt.RegisteredClaims
    
    // User Information
    UserID   string `json:"uid"`
    Email    string `json:"email"`
    Name     string `json:"name"`
    Provider string `json:"provider"`
    
    // Authorization Context
    Organizations []OrganizationClaim `json:"orgs"`
    Workspaces    []WorkspaceClaim    `json:"workspaces"`
    Groups        []string            `json:"groups"`
    Permissions   []Permission        `json:"perms"`
    
    // Security Context
    TokenType     string `json:"typ"`        // "access" or "refresh"
    SessionID     string `json:"sid"`        // Session identifier
    DeviceID      string `json:"did"`        // Device fingerprint
    IPAddress     string `json:"ip"`         // Client IP address
    TokenVersion  int    `json:"ver"`        // Token format version
    
    // Audit Context
    LoginTime     int64  `json:"login_at"`   // Initial login timestamp
    LastRefresh   int64  `json:"refresh_at"` // Last token refresh
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

### Token Security Implementation

```go
type TokenManager struct {
    privateKey    *rsa.PrivateKey
    publicKey     *rsa.PublicKey
    redis         RedisClient
    config        TokenConfig
    revokedTokens *sync.Map // In-memory cache for revoked tokens
}

func (tm *TokenManager) GenerateTokenPair(user *User, deviceFingerprint string) (*TokenPair, error) {
    sessionID := tm.generateSessionID()
    now := time.Now()
    
    // Create enhanced claims
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
    
    // Generate access token (15 minutes)
    accessClaims := *claims
    accessClaims.TokenType = "access"
    accessClaims.ExpiresAt = jwt.NewNumericDate(now.Add(15 * time.Minute))
    
    accessToken, err := tm.signToken(&accessClaims)
    if err != nil {
        return nil, fmt.Errorf("failed to sign access token: %w", err)
    }
    
    // Generate refresh token (7 days)
    refreshClaims := *claims
    refreshClaims.TokenType = "refresh"
    refreshClaims.ExpiresAt = jwt.NewNumericDate(now.Add(7 * 24 * time.Hour))
    // Remove sensitive claims from refresh token
    refreshClaims.Permissions = nil
    refreshClaims.Organizations = nil
    refreshClaims.Workspaces = nil
    
    refreshToken, err := tm.signToken(&refreshClaims)
    if err != nil {
        return nil, fmt.Errorf("failed to sign refresh token: %w", err)
    }
    
    // Store session information
    if err := tm.storeSession(sessionID, user, deviceFingerprint); err != nil {
        return nil, fmt.Errorf("failed to store session: %w", err)
    }
    
    return &TokenPair{
        AccessToken:  accessToken,
        RefreshToken: refreshToken,
        TokenType:    "Bearer",
        ExpiresIn:    900, // 15 minutes
        ExpiresAt:    now.Add(15 * time.Minute),
        SessionID:    sessionID,
    }, nil
}

func (tm *TokenManager) ValidateToken(tokenString string) (*HexabaseClaims, error) {
    // Check revocation list first (fast path)
    if tm.isTokenRevoked(tokenString) {
        return nil, ErrTokenRevoked
    }
    
    // Parse and validate token
    token, err := jwt.ParseWithClaims(tokenString, &HexabaseClaims{}, func(token *jwt.Token) (interface{}, error) {
        if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
            return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
        }
        return tm.publicKey, nil
    })
    
    if err != nil {
        return nil, fmt.Errorf("failed to parse token: %w", err)
    }
    
    claims, ok := token.Claims.(*HexabaseClaims)
    if !ok || !token.Valid {
        return nil, ErrInvalidToken
    }
    
    // Additional security validations
    if err := tm.validateTokenSecurity(claims); err != nil {
        return nil, err
    }
    
    return claims, nil
}

func (tm *TokenManager) validateTokenSecurity(claims *HexabaseClaims) error {
    // Check token version
    if claims.TokenVersion < tm.config.MinTokenVersion {
        return ErrTokenVersionTooOld
    }
    
    // Validate session exists and is active
    if !tm.isSessionActive(claims.SessionID) {
        return ErrSessionInactive
    }
    
    // Check for concurrent session limits
    if tm.exceedsConcurrentSessionLimit(claims.UserID) {
        return ErrTooManySessions
    }
    
    return nil
}
```

## Session Security Management

### Secure Session Implementation

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
    
    // Perform threat analysis
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
    
    // Store session with appropriate TTL
    if err := sm.storeSession(session); err != nil {
        return nil, fmt.Errorf("failed to store session: %w", err)
    }
    
    // Check concurrent session limits
    if err := sm.enforceConcurrentSessionLimits(user.ID); err != nil {
        return nil, err
    }
    
    return session, nil
}

func (sm *SessionManager) ValidateSession(sessionID, userID string, request *http.Request) error {
    session, err := sm.getSession(sessionID)
    if err != nil {
        return fmt.Errorf("session not found: %w", err)
    }
    
    // Basic validations
    if session.UserID != userID {
        return ErrSessionMismatch
    }
    
    if session.IsCompromised {
        return ErrSessionCompromised
    }
    
    if time.Now().After(session.ExpiresAt) {
        return ErrSessionExpired
    }
    
    // Security validations
    if err := sm.validateSessionSecurity(session, request); err != nil {
        return err
    }
    
    // Update last active time
    session.LastActive = time.Now()
    session.ExpiresAt = time.Now().Add(sm.config.SessionTimeout)
    
    if err := sm.updateSession(session); err != nil {
        return fmt.Errorf("failed to update session: %w", err)
    }
    
    return nil
}

func (sm *SessionManager) validateSessionSecurity(session *SecureSession, request *http.Request) error {
    // IP address validation (with allowances for mobile networks)
    currentIP := sm.extractClientIP(request)
    if !sm.isIPAddressAllowed(session.IPAddress, currentIP) {
        sm.flagSuspiciousActivity(session, "ip_address_change")
        return ErrSuspiciousIPChange
    }
    
    // Device fingerprint validation
    currentDeviceID := sm.deviceTracker.GenerateDeviceFingerprint(request)
    if session.DeviceID != currentDeviceID {
        sm.flagSuspiciousActivity(session, "device_fingerprint_change")
        return ErrSuspiciousDeviceChange
    }
    
    // User agent validation
    if !sm.isUserAgentConsistent(session.UserAgent, request.UserAgent()) {
        sm.flagSuspiciousActivity(session, "user_agent_change")
        return ErrSuspiciousUserAgentChange
    }
    
    return nil
}
```

## Rate Limiting and DDoS Protection

### Advanced Rate Limiting Implementation

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
    // Check whitelist first
    if rl.whitelist.IsWhitelisted(context.IPAddress) {
        return nil
    }
    
    // Apply multiple rate limiting strategies
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
    
    // Sliding window counter implementation
    now := time.Now()
    windowStart := now.Add(-limit.Window)
    
    // Remove old entries
    pipeline.ZRemRangeByScore(ctx, key, "0", fmt.Sprintf("%.0f", float64(windowStart.UnixNano())))
    
    // Add current request
    pipeline.ZAdd(ctx, key, &redis.Z{
        Score:  float64(now.UnixNano()),
        Member: fmt.Sprintf("%d:%s", now.UnixNano(), generateRequestID()),
    })
    
    // Count requests in window
    pipeline.ZCard(ctx, key)
    
    // Set TTL
    pipeline.Expire(ctx, key, limit.Window*2)
    
    results, err := pipeline.Exec(ctx)
    if err != nil {
        return fmt.Errorf("rate limit check failed: %w", err)
    }
    
    count := results[2].(*redis.IntCmd).Val()
    
    if count > int64(limit.Requests) {
        // Log rate limit violation
        rl.logViolation(key, count, limit, metadata)
        
        // Calculate backoff duration
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

## Network Security and TLS

### TLS Configuration

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
        return nil, fmt.Errorf("failed to load key pair: %w", err)
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
    
    // Load CA certificates if specified
    if tc.CAFile != "" {
        caCert, err := ioutil.ReadFile(tc.CAFile)
        if err != nil {
            return nil, fmt.Errorf("failed to read CA file: %w", err)
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
        return tls.VersionTLS13 // Default to TLS 1.3
    }
}
```

### Security Headers Middleware

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
        
        // X-Frame-Options - Clickjacking protection
        c.Header("X-Frame-Options", "DENY")
        
        // X-Content-Type-Options - MIME type sniffing protection
        c.Header("X-Content-Type-Options", "nosniff")
        
        // X-XSS-Protection
        c.Header("X-XSS-Protection", "1; mode=block")
        
        // Referrer Policy
        c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
        
        // Permissions Policy
        c.Header("Permissions-Policy", "geolocation=(), microphone=(), camera=()")
        
        // Custom security headers
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

## Audit Logging and Compliance

### Comprehensive Audit Logging

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
    
    // Add to buffer for batch processing
    select {
    case al.buffer <- event:
        // Event buffered successfully
    default:
        // Buffer full, log critical error
        log.Error("audit log buffer full, dropping event", 
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
        // Track failed attempts for brute force detection
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

## Threat Detection and Response

### Behavioral Analysis

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
    // Collect user behavior patterns
    patterns := td.getUserPatterns(userID)
    
    // Calculate anomaly scores
    scores := map[string]float64{
        "login_frequency":    td.analyzeLoginFrequency(userID, activity),
        "access_patterns":    td.analyzeAccessPatterns(userID, activity),
        "geo_location":       td.analyzeGeoLocation(userID, activity),
        "device_consistency": td.analyzeDeviceConsistency(userID, activity),
        "time_of_day":       td.analyzeTimePatterns(userID, activity),
    }
    
    // Apply ML model for advanced analysis
    mlScore := td.ml.PredictThreatScore(patterns, activity)
    
    // Combine scores
    totalScore := td.combineScores(scores, mlScore)
    
    assessment := ThreatAssessment{
        UserID:      userID,
        Score:       totalScore,
        Timestamp:   time.Now(),
        Indicators:  scores,
        MLScore:     mlScore,
        RiskLevel:   td.calculateRiskLevel(totalScore),
    }
    
    // Check threat rules
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

This comprehensive security implementation guide provides enterprise-grade security patterns for Hexabase.AI deployments. These implementations follow industry best practices and provide defense-in-depth security across all layers of the platform.

For specific security questions or custom implementations, refer to the security team or create a security-focused issue in the repository.