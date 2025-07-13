# ロードバランシング

ロードバランシングは、Hexabase.AI でアプリケーションの複数のインスタンス間でトラフィックを分散するために重要です。このガイドでは、さまざまなロードバランシング戦略と設定について説明します。

## 概要

Hexabase.AI は複数レベルのロードバランシングを提供します：

- **サービスレベルロードバランシング**（レイヤー4）
- **Ingress レベルロードバランシング**（レイヤー7）
- **グローバルロードバランシング**（マルチリージョン）
- **サービスメッシュロードバランシング**（高度なトラフィック管理）

## サービスロードバランシング

### ClusterIP サービス

クラスター内での基本的なロードバランシング：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
  sessionAffinity: None # デフォルトでラウンドロビン
```

### セッションアフィニティ

スティッキーセッションを維持：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600 # 1時間
```

### ヘッドレスサービス

クライアントサイドロードバランシング用：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-headless
spec:
  clusterIP: None
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

## Ingress ロードバランシング

### NGINX Ingress

NGINX ベースのロードバランシングを設定：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/load-balance: "round_robin"
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-service
                port:
                  number: 80
```

### ロードバランシングアルゴリズム

NGINX で利用可能なアルゴリズム：

```yaml
annotations:
  # ラウンドロビン（デフォルト）
  nginx.ingress.kubernetes.io/load-balance: "round_robin"

  # 最小接続数
  nginx.ingress.kubernetes.io/load-balance: "least_conn"

  # IP ハッシュ
  nginx.ingress.kubernetes.io/load-balance: "ip_hash"

  # 一貫性ハッシュ
  nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
```

### 高度な NGINX 設定

```yaml
annotations:
  # 接続制限
  nginx.ingress.kubernetes.io/limit-connections: "10"
  nginx.ingress.kubernetes.io/limit-rps: "100"

  # タイムアウト
  nginx.ingress.kubernetes.io/proxy-connect-timeout: "5"
  nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
  nginx.ingress.kubernetes.io/proxy-read-timeout: "60"

  # リトライ
  nginx.ingress.kubernetes.io/proxy-next-upstream: "error timeout"
  nginx.ingress.kubernetes.io/proxy-next-upstream-tries: "3"
```

## サービスメッシュロードバランシング

### Istio 設定

Istio を使用した高度なトラフィック管理：

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp-destination
spec:
  host: myapp-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        http2MaxRequests: 100
        maxRequestsPerConnection: 2
    loadBalancer:
      simple: LEAST_REQUEST # または ROUND_ROBIN, RANDOM, PASSTHROUGH
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
```

### サーキットブレーカー

サーキットブレーカーを実装：

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp-circuit-breaker
spec:
  host: myapp-service
  trafficPolicy:
    outlierDetection:
      consecutive5xxErrors: 5
      consecutiveGatewayErrors: 5
      interval: 10s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
      minHealthPercent: 30
      splitExternalLocalOriginErrors: true
```

### リトライ設定

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-retry
spec:
  hosts:
    - myapp-service
  http:
    - timeout: 30s
      retries:
        attempts: 3
        perTryTimeout: 10s
        retryOn: gateway-error,connect-failure,refused-stream
        retryRemoteLocalities: true
```

## グローバルロードバランシング

### マルチリージョンセットアップ

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: global-ingress
  annotations:
    external-dns.alpha.kubernetes.io/hostname: myapp.global.example.com
    external-dns.alpha.kubernetes.io/ttl: "60"
spec:
  rules:
    - host: myapp.global.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-service
                port:
                  number: 80
```

### 地理的ロードバランシング

HKS グローバルロードバランサーを使用：

```yaml
apiVersion: hks.io/v1
kind: GlobalLoadBalancer
metadata:
  name: myapp-global
spec:
  selector:
    app: myapp
  regions:
    - name: us-east-1
      weight: 40
      healthCheck:
        path: /health
        interval: 10s
    - name: eu-west-1
      weight: 30
    - name: ap-southeast-1
      weight: 30
  routing:
    policy: geographic # または weighted, latency, failover
    stickyRegion: true
```

## ヘルスチェック

### サービスヘルスチェック

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
  healthCheckNodePort: 30000
```

### Ingress ヘルスチェック

```yaml
annotations:
  nginx.ingress.kubernetes.io/health-check-path: "/health"
  nginx.ingress.kubernetes.io/health-check-interval: "10"
  nginx.ingress.kubernetes.io/health-check-timeout: "5"
  nginx.ingress.kubernetes.io/health-check-max-fails: "3"
```

## ロードバランサータイプ

### ネットワークロードバランサー（レイヤー4）

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-nlb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

### アプリケーションロードバランサー（レイヤー7）

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-alb
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-service
                port:
                  number: 80
```

## トラフィック配信

### 重み付きルーティング

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-weighted
spec:
  hosts:
    - myapp-service
  http:
    - match:
        - headers:
            version:
              exact: v2
      route:
        - destination:
            host: myapp-service
            subset: v2
          weight: 20
        - destination:
            host: myapp-service
            subset: v1
          weight: 80
```

### A/B テスト

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-ab-test
spec:
  hosts:
    - myapp-service
  http:
    - match:
        - headers:
            user-group:
              exact: beta
      route:
        - destination:
            host: myapp-service
            subset: v2
    - route:
        - destination:
            host: myapp-service
            subset: v1
```

### カナリアデプロイメント

```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: myapp-canary
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  service:
    port: 80
    targetPort: 8080
  analysis:
    interval: 1m
    threshold: 10
    maxWeight: 50
    stepWeight: 10
    metrics:
      - name: request-success-rate
        thresholdRange:
          min: 99
        interval: 1m
```

## パフォーマンス最適化

### コネクションプーリング

```yaml
trafficPolicy:
  connectionPool:
    tcp:
      maxConnections: 100
      connectTimeout: 30s
      tcpKeepalive:
        time: 7200
        interval: 75
        probes: 10
    http:
      http1MaxPendingRequests: 100
      http2MaxRequests: 100
      maxRequestsPerConnection: 2
      h2UpgradePolicy: UPGRADE
```

### Keep-Alive 設定

```yaml
annotations:
  nginx.ingress.kubernetes.io/upstream-keepalive-connections: "32"
  nginx.ingress.kubernetes.io/upstream-keepalive-timeout: "60"
  nginx.ingress.kubernetes.io/upstream-keepalive-requests: "100"
```

## 監視とメトリクス

### Prometheus メトリクス

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
    prometheus.io/port: "9090"
spec:
  selector:
    app: myapp
  ports:
    - name: http
      port: 80
      targetPort: 8080
    - name: metrics
      port: 9090
      targetPort: 9090
```

### ロードバランサーメトリクス

主要メトリクスを監視：

- バックエンドあたりのリクエスト率
- レスポンス時間分布
- エラー率
- コネクションプール使用率
- サーキットブレーカーステータス

```bash
# ロードバランサーステータスをチェック
hb lb status myapp-service

# バックエンドヘルスを表示
hb lb backends myapp-service

# トラフィック配信を監視
hb lb traffic myapp-service --watch
```

## トラブルシューティング

### 一般的な問題

1. **不均等な負荷分散**

   ```bash
   # ポッド分散をチェック
   hb get pods -o wide

   # サービスエンドポイントを確認
   hb get endpoints myapp-service
   ```

2. **セッションアフィニティが機能しない**

   ```bash
   # セッションアフィニティをテスト
   for i in {1..10}; do
     curl -b cookies.txt -c cookies.txt http://myapp.example.com
   done
   ```

3. **ヘルスチェック失敗**

   ```bash
   # ヘルスエンドポイントをチェック
   hb exec -it myapp-pod -- curl localhost:8080/health

   # ingress コントローラーログを表示
   hb logs -n ingress-nginx deployment/ingress-nginx-controller
   ```

## ベストプラクティス

1. **適切なロードバランサーの選択**

   - 内部トラフィックには Service を使用
   - HTTP/HTTPS トラフィックには Ingress を使用
   - 高度なトラフィック管理には Service Mesh を使用

2. **ヘルスチェック**

   - 包括的なヘルスチェックを実装
   - 適切なタイムアウトと閾値を使用
   - ヘルスチェックメトリクスを監視

3. **パフォーマンス**

   - コネクションプーリングを有効化
   - 適切なタイムアウトを設定
   - 可能な場合は HTTP/2 を使用

4. **信頼性**

   - サーキットブレーカーを実装
   - リトライを適切に設定
   - 外れ値検出を使用

5. **監視**
   - 負荷分散を追跡
   - エラー率を監視
   - 異常にアラート