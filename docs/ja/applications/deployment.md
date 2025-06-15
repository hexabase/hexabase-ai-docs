# アプリケーションデプロイメント

このガイドでは、Hexabase.AI にアプリケーションをデプロイするためのデプロイメント戦略とベストプラクティスについて説明します。

## デプロイメント方法

### 1. 直接 Kubernetes マニフェスト

標準の Kubernetes YAML マニフェストを使用してアプリケーションをデプロイします：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: app
          image: myregistry/myapp:v1.0.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

HKS CLI を使用してデプロイ：

```bash
hks apply -f deployment.yaml
```

### 2. Helm チャート

テンプレートとパッケージ管理のために Helm を使用してアプリケーションをデプロイします：

```bash
# Helm リポジトリを追加
hks helm repo add bitnami https://charts.bitnami.com/bitnami

# アプリケーションをインストール
hks helm install myapp bitnami/wordpress \
  --set wordpressBlogName="My Blog" \
  --namespace production
```

カスタム Helm チャート構造：

```
myapp/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── configmap.yaml
└── charts/
```

### 3. HKS アプリケーションテンプレート

事前設定されたアプリケーションテンプレートを使用：

```yaml
# app.hks.yaml
apiVersion: hks.io/v1
kind: Application
metadata:
  name: myapp
spec:
  template: nodejs-web
  source:
    git:
      url: https://github.com/myorg/myapp
      branch: main
  build:
    dockerfile: Dockerfile
  deploy:
    replicas: 3
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
```

### 4. GitOps デプロイメント

自動同期を伴う GitOps ワークフローを実装：

```yaml
# gitops-app.yaml
apiVersion: hks.io/v1
kind: GitOpsApplication
metadata:
  name: myapp
spec:
  source:
    repoURL: https://github.com/myorg/myapp-config
    path: overlays/production
    targetRevision: main
  destination:
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## コンテナイメージ管理

### イメージレジストリ統合

```yaml
# プライベートレジストリを設定
apiVersion: v1
kind: Secret
metadata:
  name: registry-credentials
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

### イメージスキャンとセキュリティ

```yaml
deploy:
  imagePolicy:
    scan:
      enabled: true
      failThreshold: HIGH
    sign:
      enabled: true
      keyRef: cosign-key
```

## 設定管理

### ConfigMaps

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.url: "postgres://db:5432/myapp"
  log.level: "info"
  feature.flags: |
    new-ui=true
    beta-features=false
```

### シークレット管理

```yaml
# HKS シークレット管理を使用
hks secret create app-secrets \
--from-literal=db-password=mypassword \
--from-file=tls.crt=/path/to/cert
```

### 環境変数

```yaml
containers:
  - name: app
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: app-secrets
            key: database-url
      - name: LOG_LEVEL
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: log.level
```

## ヘルスチェック

### Readiness Probe

```yaml
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```

### Liveness Probe

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### Startup Probe

```yaml
startupProbe:
  httpGet:
    path: /health/startup
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 10
  failureThreshold: 30
```

## デプロイメント戦略

### ローリングアップデート

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

### ブルーグリーンデプロイメント

```bash
# グリーンバージョンをデプロイ
hks deploy myapp-green --image myapp:v2.0.0

# グリーンバージョンをテスト
hks test myapp-green

# トラフィックを切り替え
hks switch-traffic myapp --to green

# ブルーバージョンを削除
hks delete deployment myapp-blue
```

### カナリアデプロイメント

```yaml
# HKS カナリア機能を使用
apiVersion: hks.io/v1
kind: CanaryDeployment
metadata:
  name: myapp-canary
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  canarySpec:
    image: myapp:v2.0.0
    percentage: 10
    stepWeight: 10
    stepDuration: 10m
```

## 永続ストレージ

### ボリュームクレーム

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
```

### ボリュームマウント

```yaml
containers:
  - name: app
    volumeMounts:
      - name: data
        mountPath: /var/lib/app/data
      - name: config
        mountPath: /etc/app
        readOnly: true
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: app-storage
  - name: config
    configMap:
      name: app-config
```

## ネットワーク設定

### サービス定義

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```

### Ingress 設定

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
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

## マルチ環境デプロイメント

### 環境分離

```yaml
# base/kustomization.yaml
resources:
  - deployment.yaml
  - service.yaml

# overlays/dev/kustomization.yaml
bases:
  - ../../base
patchesStrategicMerge:
  - deployment-patch.yaml
configMapGenerator:
  - name: app-config
    literals:
      - environment=development

# overlays/prod/kustomization.yaml
bases:
  - ../../base
replicas:
  - name: myapp
    count: 5
```

### Namespace 分離

```bash
# 環境を作成
hks namespace create dev
hks namespace create staging
hks namespace create production

# 特定の環境にデプロイ
hks deploy --namespace production
```

## 監視とオブザーバビリティ

### Prometheus メトリクス

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
```

### アプリケーションログ

```yaml
# ログ集約を設定
spec:
  containers:
    - name: app
      env:
        - name: LOG_FORMAT
          value: "json"
        - name: LOG_OUTPUT
          value: "stdout"
```

## ベストプラクティス

1. **コンテナベストプラクティス**

   - 最小限のベースイメージを使用
   - 非ルートユーザーとして実行
   - コンテナあたり1つのプロセス
   - シグナルを適切に処理

2. **リソース管理**

   - 常にリソースリクエストと制限を設定
   - 水平ポッド自動スケーリングを使用
   - 適切なヘルスチェックを実装

3. **セキュリティ**

   - 脆弱性についてイメージをスキャン
   - ネットワークポリシーを使用
   - RBAC を実装
   - 保存時にシークレットを暗号化

4. **高可用性**

   - 複数のゾーンにデプロイ
   - ポッド中断予算を使用
   - サーキットブレーカーを実装
   - 障害を想定した設計

5. **デプロイメント衛生**
   - 宣言的設定を使用
   - すべてをバージョン管理
   - デプロイメントを自動化
   - デプロイメントメトリクスを監視

## トラブルシューティング

### 一般的な問題

```bash
# デプロイメント状態をチェック
hks get deployments -n production

# ポッドログを表示
hks logs -f deployment/myapp

# イベントのためにポッドを記述
hks describe pod myapp-xyz

# リソース使用量をチェック
hks top pods -n production

# 実行中のコンテナをデバッグ
hks exec -it myapp-xyz -- /bin/sh
```

### ロールバック手順

```bash
# ロールアウト履歴を表示
hks rollout history deployment/myapp

# 前のバージョンにロールバック
hks rollout undo deployment/myapp

# 特定のリビジョンにロールバック
hks rollout undo deployment/myapp --to-revision=2
```