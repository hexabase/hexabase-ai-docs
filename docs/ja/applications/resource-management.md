# リソース管理

効果的なリソース管理は、Hexabase.AI での最適なアプリケーションパフォーマンスとクラスター効率にとって重要です。このガイドでは、CPU、メモリ、ストレージ、その他のリソース配分戦略について説明します。

## リソースタイプ

### CPU リソース

CPU リソースは CPU 単位で測定されます：

- `1` = 1 vCPU/コア
- `1000m` = 1 CPU（m = ミリCPU）
- `100m` = 0.1 CPU

```yaml
resources:
  requests:
    cpu: "100m" # 保証される最小値
  limits:
    cpu: "500m" # 許可される最大値
```

### メモリリソース

メモリは単位接尾辞付きのバイトで測定されます：

- `Ki` = キビバイト（1024バイト）
- `Mi` = メビバイト（1024 Ki）
- `Gi` = ギビバイト（1024 Mi）

```yaml
resources:
  requests:
    memory: "256Mi" # 保証される最小値
  limits:
    memory: "512Mi" # 許可される最大値
```

## リソースリクエストと制限

### 基本設定

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
        - name: app
          image: myapp:latest
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

### リクエスト vs 制限の理解

- **リクエスト**: スケジューリングのための保証リソース
- **制限**: コンテナが使用できる最大リソース

```yaml
# Burstable QoS クラス
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "200m"

# Guaranteed QoS クラス（リクエスト = 制限）
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## サービス品質（QoS）クラス

### 1. Guaranteed

最高優先度、制限を超えない限り終了されません：

```yaml
containers:
  - name: critical-app
    resources:
      requests:
        memory: "1Gi"
        cpu: "1"
      limits:
        memory: "1Gi"
        cpu: "1"
```

### 2. Burstable

中優先度、リクエスト以上にバーストできます：

```yaml
containers:
  - name: web-app
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "500m"
```

### 3. BestEffort

最低優先度、最初に退避されます：

```yaml
containers:
  - name: batch-job
    # リソースが指定されていません
```

## リソースクォータ

### Namespace リソース制限

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: production
spec:
  hard:
    requests.cpu: "100"
    requests.memory: "200Gi"
    limits.cpu: "200"
    limits.memory: "400Gi"
    persistentvolumeclaims: "10"
    services.loadbalancers: "2"
```

### オブジェクト数クォータ

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
  namespace: production
spec:
  hard:
    pods: "50"
    services: "10"
    replicationcontrollers: "20"
    secrets: "100"
    configmaps: "100"
```

## 制限範囲

### デフォルトコンテナ制限

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: production
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "512Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      max:
        cpu: "2"
        memory: "2Gi"
      min:
        cpu: "50m"
        memory: "64Mi"
      type: Container
```

### ポッドレベル制限

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limits
spec:
  limits:
    - max:
        cpu: "4"
        memory: "8Gi"
      min:
        cpu: "100m"
        memory: "128Mi"
      type: Pod
```

## 水平ポッド自動スケーリング（HPA）

### CPU ベース自動スケーリング

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### メモリベース自動スケーリング

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-memory-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

### カスタムメトリクス自動スケーリング

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-custom-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Pods
      pods:
        metric:
          name: requests_per_second
        target:
          type: AverageValue
          averageValue: "100"
    - type: Object
      object:
        metric:
          name: queue_length
        describedObject:
          apiVersion: v1
          kind: Service
          name: myapp-queue
        target:
          type: Value
          value: "30"
```

## 垂直ポッド自動スケーリング（VPA）

### VPA 設定

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto" # または "Off", "Initial"
  resourcePolicy:
    containerPolicies:
      - containerName: app
        minAllowed:
          cpu: 100m
          memory: 128Mi
        maxAllowed:
          cpu: 2
          memory: 2Gi
        controlledResources: ["cpu", "memory"]
```

## ストレージリソース

### 永続ボリュームクレーム

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
```

### ストレージクラス

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
allowVolumeExpansion: true
```

### ボリュームリソース制限

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-quota
spec:
  hard:
    requests.storage: "100Gi"
    persistentvolumeclaims: "10"
    fast-ssd.storageclass.storage.k8s.io/requests.storage: "50Gi"
    fast-ssd.storageclass.storage.k8s.io/persistentvolumeclaims: "5"
```

## ネットワークリソース

### 帯域幅制限

```yaml
metadata:
  annotations:
    kubernetes.io/ingress-bandwidth: "10M"
    kubernetes.io/egress-bandwidth: "10M"
```

### ネットワークポリシー

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8080
```

## GPU リソース

### GPU 配分

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
    - name: cuda-container
      image: nvidia/cuda:11.0-base
      resources:
        limits:
          nvidia.com/gpu: 1 # 1つの GPU をリクエスト
```

### GPU 共有

```yaml
# NVIDIA MIG を使用した分数 GPU
resources:
  limits:
    nvidia.com/mig-3g.20gb: 1
```

## リソース監視

### メトリクス収集

```yaml
# リソースメトリクスを有効化
apiVersion: v1
kind: ConfigMap
metadata:
  name: metrics-config
data:
  metrics.yaml: |
    collection_interval: 30s
    resources:
      - cpu
      - memory
      - disk
      - network
```

### リソース使用量コマンド

```bash
# ノードリソース使用量を表示
hb top nodes

# ポッドリソース使用量を表示
hb top pods -n production

# コンテナリソース使用量を表示
hb top pod myapp-pod --containers

# リソースクォータ状態を取得
hb get resourcequota -n production

# リソース使用量を詳述
hb describe node worker-1
```

## ベストプラクティス

### 1. 適正サイジング

```yaml
# 監視から開始
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "200m"

# 分析後、実際の使用量に調整
resources:
  requests:
    memory: "384Mi"  # P95 使用量
    cpu: "150m"      # P95 使用量
  limits:
    memory: "512Mi"  # P99 使用量 + バッファ
    cpu: "300m"      # P99 使用量 + バッファ
```

### 2. リソース比率

```yaml
# 良い実践: 2:1 の制限対リクエスト比率
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi" # リクエストの2倍
    cpu: "1000m" # リクエストの2倍
```

### 3. Namespace 構成

```bash
# リソース分離された namespace を作成
hb create namespace dev --quota small
hb create namespace staging --quota medium
hb create namespace production --quota large
```

### 4. リソース計画

```yaml
# リソース配分戦略
apiVersion: v1
kind: ConfigMap
metadata:
  name: resource-tiers
data:
  small: |
    cpu: 100m-500m
    memory: 128Mi-512Mi
  medium: |
    cpu: 500m-2000m
    memory: 512Mi-2Gi
  large: |
    cpu: 2000m-8000m
    memory: 2Gi-8Gi
```

## トラブルシューティング

### 一般的な問題

1. **OOMKilled ポッド**

   ```bash
   # OOM 強制終了をチェック
   hb describe pod myapp-pod | grep -i oom

   # メモリ制限を増加
   hb set resources deployment myapp --limits=memory=1Gi
   ```

2. **CPU スロットリング**

   ```bash
   # CPU スロットリングをチェック
   hb exec myapp-pod -- cat /sys/fs/cgroup/cpu/cpu.stat

   # CPU 制限を調整
   hb set resources deployment myapp --limits=cpu=1000m
   ```

3. **保留中のポッド**

   ```bash
   # ポッドが保留中の理由をチェック
   hb describe pod myapp-pod

   # ノードリソースを表示
   hb describe nodes | grep -A 5 "Allocated resources"
   ```

### リソース最適化

```bash
# VPA から推奨事項を取得
hb get vpa myapp-vpa -o yaml

# リソース使用パターンを分析
hb top pods --sort-by=cpu
hb top pods --sort-by=memory

# 分析用にメトリクスをエクスポート
hb get --raw /metrics | grep container_
```

## HKS 固有の機能

### AI 主導リソース最適化

```yaml
apiVersion: hks.io/v1
kind: ResourceOptimizer
metadata:
  name: ai-optimizer
spec:
  target:
    kind: Deployment
    name: myapp
  optimization:
    mode: aggressive # または conservative, balanced
    metrics:
      - cpu
      - memory
    constraints:
      minReplicas: 2
      maxCost: 100 # 月あたり USD
```

### コストベーススケーリング

```yaml
apiVersion: hks.io/v1
kind: CostAwareHPA
metadata:
  name: cost-aware-scaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  costConstraints:
    maxMonthlyCost: 500
    preferSpotInstances: true
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```