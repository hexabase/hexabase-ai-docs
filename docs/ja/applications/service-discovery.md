# サービスディスカバリー

サービスディスカバリーは、Hexabase.AI でのマイクロサービス通信に不可欠です。このガイドでは、DNS ベースのディスカバリー、サービスメッシュ統合、高度なサービスディスカバリーパターンについて説明します。

## 概要

Hexabase.AI は複数のサービスディスカバリーメカニズムを提供します：

- **Kubernetes DNS**（CoreDNS）
- **サービスメッシュディスカバリー**（Istio/Linkerd）
- **外部サービスディスカバリー**（Consul、etcd）
- **ヘッドレスサービス** 直接ポッドディスカバリー用

## Kubernetes DNS サービスディスカバリー

### 基本サービスディスカバリー

すべてのサービスが DNS エントリを取得します：

```
<service-name>.<namespace>.svc.cluster.local
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-api
  namespace: production
spec:
  selector:
    app: backend
  ports:
    - port: 8080
      targetPort: 8080
```

アクセスパターン：

```bash
# 同じ namespace から
curl http://backend-api:8080

# 異なる namespace から
curl http://backend-api.production:8080

# 完全修飾
curl http://backend-api.production.svc.cluster.local:8080
```

### DNS ポリシー

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  dnsPolicy: ClusterFirst # デフォルト
  # その他のオプション: Default, None, ClusterFirstWithHostNet
  dnsConfig:
    nameservers:
      - 1.1.1.1
    searches:
      - production.svc.cluster.local
      - svc.cluster.local
    options:
      - name: ndots
        value: "5"
```

## ヘッドレスサービス

### 直接ポッドディスカバリー

```yaml
apiVersion: v1
kind: Service
metadata:
  name: database-cluster
spec:
  clusterIP: None # ヘッドレスサービス
  selector:
    app: postgres
  ports:
    - port: 5432
```

DNS はすべてのポッド IP を返します：

```bash
# すべてのポッドの A レコードを返す
nslookup database-cluster.default.svc.cluster.local

# 個別のポッド DNS
<pod-name>.<service-name>.<namespace>.svc.cluster.local
```

### StatefulSet サービスディスカバリー

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
    - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:14
```

予測可能なポッド名：

```bash
# 特定のレプリカにアクセス
postgres-0.postgres-headless.default.svc.cluster.local
postgres-1.postgres-headless.default.svc.cluster.local
postgres-2.postgres-headless.default.svc.cluster.local
```

## サービスメッシュディスカバリー

### Istio サービスディスカバリー

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: external-api
spec:
  hosts:
    - api.external.com
  ports:
    - number: 443
      name: https
      protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
```

### 仮想サービス

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews-route
spec:
  hosts:
    - reviews
  http:
    - match:
        - headers:
            version:
              exact: v2
      route:
        - destination:
            host: reviews
            subset: v2
    - route:
        - destination:
            host: reviews
            subset: v1
```

### デスティネーションルール

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: reviews-destination
spec:
  host: reviews
  subsets:
    - name: v1
      labels:
        version: v1
    - name: v2
      labels:
        version: v2
```

## EndpointSlices

### モダンエンドポイント管理

```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: myapp-endpoints
  labels:
    kubernetes.io/service-name: myapp
addressType: IPv4
endpoints:
  - addresses:
      - "10.1.2.3"
    conditions:
      ready: true
      serving: true
      terminating: false
ports:
  - port: 8080
    protocol: TCP
```

## サービスディスカバリーパターン

### クライアントサイドロードバランシング

```go
// クライアントサイドディスカバリーを使用した Go の例
package main

import (
    "fmt"
    "net"
    "math/rand"
)

func discoverService(service string) ([]string, error) {
    _, addrs, err := net.LookupSRV("", "", service)
    if err != nil {
        return nil, err
    }

    var endpoints []string
    for _, addr := range addrs {
        endpoints = append(endpoints, fmt.Sprintf("%s:%d", addr.Target, addr.Port))
    }
    return endpoints, nil
}

func getRandomEndpoint(service string) (string, error) {
    endpoints, err := discoverService(service)
    if err != nil {
        return "", err
    }
    return endpoints[rand.Intn(len(endpoints))], nil
}
```

### ヘルス対応ディスカバリー

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "false"
spec:
  selector:
    app: api
  ports:
    - port: 80
  publishNotReadyAddresses: false # 準備完了ポッドのみを発見
```

## 外部サービスディスカバリー

### Consul 統合

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: consul-config
data:
  consul.json: |
    {
      "datacenter": "dc1",
      "services": [
        {
          "name": "web-app",
          "tags": ["production", "v1"],
          "port": 8080,
          "check": {
            "http": "http://localhost:8080/health",
            "interval": "10s"
          }
        }
      ]
    }
```

### 外部 DNS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    external-dns.alpha.kubernetes.io/hostname: myapp.example.com
    external-dns.alpha.kubernetes.io/ttl: "60"
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
```

## マルチクラスターディスカバリー

### クロスクラスターサービスディスカバリー

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: cross-cluster-service
spec:
  hosts:
    - remote-service.remote-cluster.local
  location: MESH_EXTERNAL
  ports:
    - number: 8080
      name: http
      protocol: HTTP
  resolution: DNS
  endpoints:
    - address: cluster-2-gateway.example.com
      ports:
        http: 15443
```

### マルチクラスター DNS

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  remote.server: |
    remote-cluster.local:53 {
        forward . 10.0.0.100:53
    }
```

## サービスディスカバリーセキュリティ

### ネットワークポリシー

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-discovery-policy
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: production
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### サービス通信用 mTLS

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

## 高度なパターン

### サービスレジストリパターン

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: service-registry
data:
  services.yaml: |
    services:
      - name: user-service
        endpoints:
          - host: user-service.production
            port: 8080
            weight: 100
      - name: order-service
        endpoints:
          - host: order-service-v1.production
            port: 8080
            weight: 80
          - host: order-service-v2.production
            port: 8080
            weight: 20
```

### ディスカバリー付きサーキットブレーカー

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: circuit-breaker
spec:
  host: backend-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
      minHealthPercent: 30
```

## サービスディスカバリー監視

### メトリクス

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
spec:
  selector:
    app: myapp
  ports:
    - name: web
      port: 80
    - name: metrics
      port: 9090
```

### ディスカバリーヘルスチェック

```bash
# DNS 解決をチェック
hb exec -it debug-pod -- nslookup myservice

# エンドポイントをチェック
hb get endpoints myservice

# エンドポイントスライスをチェック
hb get endpointslices -l kubernetes.io/service-name=myservice

# サービスディスカバリーをテスト
hb run test --rm -it --image=busybox -- wget -O- http://myservice
```

## トラブルシューティング

### 一般的な問題

1. **DNS 解決失敗**

   ```bash
   # CoreDNS ログをチェック
   hb logs -n kube-system -l k8s-app=kube-dns

   # ポッドから DNS をテスト
   hb exec -it myapp -- nslookup kubernetes.default
   ```

2. **サービスが見つからない**

   ```bash
   # サービスが存在することを確認
   hb get svc myservice

   # サービスセレクターをチェック
   hb describe svc myservice

   # 一致するポッドを確認
   hb get pods -l app=myapp
   ```

3. **エンドポイントが準備できていない**

   ```bash
   # エンドポイント状態をチェック
   hb get endpoints myservice

   # ポッド準備状態をチェック
   hb get pods -l app=myapp -o wide
   ```

### デバッグツール

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-debug
spec:
  containers:
    - name: debug
      image: nicolaka/netshoot
      command: ["/bin/bash"]
      args: ["-c", "sleep 3600"]
```

デバッグコマンド：

```bash
# DNS デバッグ
dig @10.96.0.10 myservice.default.svc.cluster.local

# サービスディスカバリーテスト
curl -v http://myservice.default.svc.cluster.local

# ネットワークパスをトレース
traceroute myservice.default.svc.cluster.local
```

## ベストプラクティス

1. **適切なディスカバリー方法を使用**

   - シンプルなサービスディスカバリーには DNS
   - ステートフルアプリケーションにはヘッドレスサービス
   - 高度なトラフィック管理にはサービスメッシュ

2. **ヘルスチェックを実装**

   - 常に readiness probe を定義
   - 自己修復のため liveness probe を使用
   - 適切なタイムアウトを設定

3. **ディスカバリー結果をキャッシュ**

   - クライアントサイドキャッシングを実装
   - TTL を適切に使用
   - キャッシュ無効化を処理

4. **ディスカバリーヘルスを監視**

   - DNS クエリレイテンシを追跡
   - エンドポイント変更を監視
   - ディスカバリー失敗にアラート

5. **セキュリティ考慮事項**
   - ネットワークポリシーを使用
   - 可能な場合は mTLS を実装
   - サービス公開を制限

## HKS 固有の機能

### AI 強化ディスカバリー

```yaml
apiVersion: hks.io/v1
kind: SmartDiscovery
metadata:
  name: intelligent-routing
spec:
  service: myapp
  optimization:
    - latency
    - cost
    - reliability
  learning:
    enabled: true
    window: 7d
```

### グローバルサービスカタログ

```bash
# クラスター全体のすべてのサービスをリスト
hb catalog list --global

# 機能でサービスを検索
hb catalog search --tag "user-auth"

# サービス詳細を取得
hb catalog describe user-service --detailed
```