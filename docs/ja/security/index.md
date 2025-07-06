# セキュリティ

このセクションでは、Hexabase.AI（HKS）の包括的なセキュリティガイダンスを提供します。多層防御戦略の実装と安全なKubernetes環境の維持方法を学びます。

## このセクションの内容

- **セキュリティアーキテクチャ**: HKSセキュリティレイヤーとコンポーネントの理解
- **アクセス制御**: RBAC、認証、認可の設定
- **ネットワークセキュリティ**: ネットワークポリシー、サービスメッシュセキュリティ、暗号化
- **コンプライアンス**: 業界標準と規制要件への対応
- **セキュリティオペレーション**: 監視、インシデント対応、脅威検知

## 主要トピック

- アイデンティティとアクセス管理（IAM）
- ロールベースアクセス制御（RBAC）
- ポッドセキュリティ標準とポリシー
- ネットワークポリシーとマイクロセグメンテーション
- シークレット管理と暗号化
- コンテナイメージセキュリティスキャン
- ランタイムセキュリティと脅威検知
- SSL/TLS証明書管理
- セキュリティ監査ログと監視
- コンプライアンスフレームワーク（SOC2、HIPAA、PCI-DSS）
- AI-Opsセキュリティ異常検知
- ゼロトラストアーキテクチャ実装
- セキュリティベストプラクティスとハードニングガイド

基本的なセキュリティ衛生から高度な脅威保護まで、このセクションは安全なHKS環境の構築と維持を支援します。

## セキュリティコンポーネント

<div class="grid cards" markdown>

- :material-shield-lock:{ .lg .middle } **アクセス制御**

  ***

  RBAC、認証、認可の設定

  [:octicons-arrow-right-24: アクセス制御](access-control.md)

- :material-network-outline:{ .lg .middle } **ネットワークセキュリティ**

  ***

  ネットワークポリシーと暗号化

  [:octicons-arrow-right-24: ネットワークセキュリティ](network-security.md)

- :material-key-variant:{ .lg .middle } **シークレット管理**

  ***

  機密情報の安全な管理

  [:octicons-arrow-right-24: シークレット管理](secrets-management.md)

- :material-eye-check:{ .lg .middle } **脅威検知**

  ***

  ランタイムセキュリティと監視

  [:octicons-arrow-right-24: 脅威検知](threat-detection.md)

</div>

## セキュリティアーキテクチャ

### 多層防御

```
┌─────────────────────────────────────────┐
│          アプリケーション層               │
│  (WAF, 認証, アプリケーションセキュリティ)  │
├─────────────────────────────────────────┤
│           Kubernetes層                 │
│    (RBAC, PSP, ネットワークポリシー)      │
├─────────────────────────────────────────┤
│          コンテナ層                     │
│  (イメージスキャン, ランタイム保護)         │
├─────────────────────────────────────────┤
│           ノード層                      │
│    (ホスト強化, OS セキュリティ)          │
├─────────────────────────────────────────┤
│          インフラ層                     │
│    (ネットワークセキュリティ, 暗号化)      │
└─────────────────────────────────────────┘
```

## アクセス制御

### RBAC設定

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: development
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "update", "patch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: User
  name: john.doe@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

### サービスアカウント

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: production
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: app-cluster-role
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
```

## ネットワークセキュリティ

### ネットワークポリシー

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### TLS暗号化

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - api.hexabase.ai
    secretName: api-tls-secret
  rules:
  - host: api.hexabase.ai
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

## ポッドセキュリティ

### Pod Security Standards

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### SecurityContext

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: myapp:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

## シークレット管理

### 暗号化設定

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
data:
  database-password: <base64-encoded-password>
  api-key: <base64-encoded-api-key>
```

### 外部シークレット管理

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.company.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "myapp"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secret
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: myapp-secret
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: myapp
      property: password
```

## イメージセキュリティ

### イメージスキャニング

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-image-scanning
spec:
  rules:
  - when:
    - key: custom.image_scanned
      values: ["true"]
```

### Admission Controller

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: disallow-privileged
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Privileged containers are not allowed"
      pattern:
        spec:
          =(securityContext):
            =(privileged): "false"
```

## 監視とアラート

### セキュリティアラート

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: security-alerts
spec:
  groups:
  - name: security.rules
    rules:
    - alert: UnauthorizedApiAccess
      expr: increase(nginx_ingress_controller_requests{status=~"401|403"}[5m]) > 10
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "認証失敗が多発しています"
        description: "過去5分間で{{ $value }}回の認証失敗がありました"
    
    - alert: PrivilegedPodDetected
      expr: kube_pod_container_status_running{container=~".*privileged.*"} > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "特権ポッドが検出されました"
```

### ログ監視

```yaml
apiVersion: logging.coreos.com/v1
kind: ClusterLogForwarder
metadata:
  name: security-logs
spec:
  outputs:
  - name: security-siem
    type: http
    url: https://siem.company.com/api/logs
    http:
      headers:
        Authorization: "Bearer <token>"
  pipelines:
  - name: security-audit
    inputRefs:
    - audit
    - infrastructure
    filterRefs:
    - security-filter
    outputRefs:
    - security-siem
```

## コンプライアンス

### SOC2 対応

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: compliance-config
data:
  audit-policy.yaml: |
    apiVersion: audit.k8s.io/v1
    kind: Policy
    rules:
    - level: RequestResponse
      resources:
      - group: ""
        resources: ["secrets", "configmaps"]
    - level: Request
      resources:
      - group: "rbac.authorization.k8s.io"
        resources: ["*"]
```

### GDPR対応

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processor
  annotations:
    gdpr.compliance/data-classification: "personal"
    gdpr.compliance/retention-period: "7y"
spec:
  containers:
  - name: processor
    image: myapp:latest
    env:
    - name: GDPR_MODE
      value: "enabled"
```

## 脅威検知

### ランタイム保護

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: runtime-protection
spec:
  selector:
    matchLabels:
      app: myapp
  rules:
  - when:
    - key: source.ip
      notValues: ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  - to:
    - operation:
        methods: ["GET", "POST"]
```

### 異常検知

```python
# AI-powered anomaly detection
import numpy as np
from sklearn.ensemble import IsolationForest

def detect_security_anomalies(metrics_data):
    """
    セキュリティメトリクスの異常を検知
    """
    model = IsolationForest(contamination=0.1)
    anomalies = model.fit_predict(metrics_data)
    
    # -1 は異常、1 は正常
    return anomalies == -1
```

## ベストプラクティス

### 1. 最小権限の原則

- 必要最小限の権限のみ付与
- 定期的な権限レビュー
- 未使用権限の削除

### 2. 多要素認証

- すべての管理者アカウントでMFA必須
- サービスアカウントの適切な管理
- 定期的なアクセスレビュー

### 3. 暗号化

- 保存時暗号化（データベース、ストレージ）
- 転送時暗号化（TLS/SSL）
- キー管理システムの使用

### 4. 定期監査

- セキュリティ設定の定期確認
- 脆弱性スキャンの実施
- ペネトレーションテストの実行

## インシデント対応

### 対応手順

1. **検知**: 自動アラートまたは手動発見
2. **隔離**: 影響範囲の特定と封じ込め
3. **評価**: 損害とリスクの評価
4. **根絶**: 脅威の除去
5. **復旧**: システムの正常化
6. **学習**: 事後レビューと改善

### 緊急時コマンド

```bash
# ポッドの緊急停止
kubectl delete pod suspicious-pod --force --grace-period=0

# ネットワークアクセス遮断
kubectl apply -f emergency-network-policy.yaml

# ノードの隔離
kubectl cordon compromised-node
kubectl drain compromised-node --ignore-daemonsets
```

## 次のステップ

- **アクセス制御**: [アクセス制御](access-control.md)を設定
- **ネットワーク**: [ネットワークセキュリティ](network-security.md)を実装
- **シークレット**: [シークレット管理](secrets-management.md)を設定
- **監視**: [脅威検知](threat-detection.md)を有効化

## 関連ドキュメント

- [RBAC設定](../rbac/index.md)
- [オブザーバビリティ](../observability/index.md)
- [AIOps](../aiops/index.md)
- [アーキテクチャ](../architecture/index.md)