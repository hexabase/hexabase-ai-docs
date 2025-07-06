# バックアップ

このセクションでは、Hexabase.AI（HKS）のバックアップと災害復旧戦略について説明します。ビジネス継続性を確保するため、データ、アプリケーション、設定を保護する方法を学びます。

## このセクションの内容

- **バックアップ戦略**: 異なるワークロードタイプに対する包括的なバックアップアプローチ
- **バックアップ設定**: クラスターとアプリケーションの自動バックアップ設定
- **リストア手順**: バックアップからの復元のステップバイステップガイド
- **災害復旧**: DR戦略の計画と実装
- **コンプライアンス**: データ保護の規制要件への対応

## 主要トピック

- Veleroを使用したクラスターレベルバックアップ
- アプリケーションデータバックアップ戦略
- 永続ボリュームスナップショット
- データベースバックアップとリストア手順
- 設定とシークレットバックアップ
- クロスリージョンバックアップレプリケーション
- バックアップスケジューリングと保持ポリシー
- バックアップとリストア手順のテスト
- RTO/RPO計画と最適化
- AI-Ops予測バックアップ最適化
- バックアップ監視とアラート

重要な本番データの保護から災害からの迅速復旧の確保まで、このセクションはHKSで堅牢なバックアップ戦略を実装するために必要なすべてを提供します。

## バックアップ概要

<div class="grid cards" markdown>

- :material-database:{ .lg .middle } **バックアップ戦略**

  ***

  包括的なデータ保護アプローチ

  [:octicons-arrow-right-24: 戦略を探索](strategies.md)

- :material-robot:{ .lg .middle } **自動バックアップ**

  ***

  スケジュールされた自動バックアップシステム

  [:octicons-arrow-right-24: 自動化設定](automated-backups.md)

- :material-backup-restore:{ .lg .middle } **リストア手順**

  ***

  データとアプリケーション復旧プロセス

  [:octicons-arrow-right-24: 復旧ガイド](restore-procedures.md)

- :material-shield-alert:{ .lg .middle } **災害復旧**

  ***

  ビジネス継続性とDR計画

  [:octicons-arrow-right-24: DR戦略](disaster-recovery.md)

</div>

## バックアップのタイプ

### 1. フルクラスターバックアップ

```bash
# Veleroを使用したクラスター全体のバックアップ
velero backup create cluster-backup-$(date +%Y%m%d) \
  --include-namespaces "*" \
  --storage-location default
```

**対象**:
- すべてのKubernetesリソース
- 永続ボリューム
- カスタムリソース定義
- RBAC設定

### 2. ネームスペースバックアップ

```bash
# 特定のネームスペースのバックアップ
velero backup create app-backup-$(date +%Y%m%d) \
  --include-namespaces production,staging \
  --storage-location default
```

**対象**:
- アプリケーション固有のリソース
- 設定とシークレット
- サービスとイングレス

### 3. 永続ボリュームバックアップ

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-backup
  annotations:
    backup.velero.io/backup-volumes: data-volume
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
```

**対象**:
- データベースファイル
- アプリケーションデータ
- ログファイル

## バックアップスケジュール

### 日次バックアップ

```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"  # 毎日午前2時
  template:
    includedNamespaces:
    - production
    storageLocation: default
    ttl: 720h  # 30日間保持
```

### 週次バックアップ

```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: weekly-backup
spec:
  schedule: "0 2 * * 0"  # 毎週日曜日午前2時
  template:
    includedNamespaces:
    - "*"
    storageLocation: long-term
    ttl: 2160h  # 90日間保持
```

## 保持ポリシー

| バックアップタイプ | 頻度 | 保持期間 | ストレージ |
|------------------|------|----------|------------|
| 日次バックアップ | 毎日 | 30日 | 標準 |
| 週次バックアップ | 毎週 | 90日 | 標準 |
| 月次バックアップ | 毎月 | 1年 | アーカイブ |
| 年次バックアップ | 毎年 | 7年 | コールド |

## バックアップ検証

### 自動検証

```bash
# バックアップの整合性チェック
velero backup describe backup-name --details

# リストアテスト（ドライラン）
velero restore create test-restore \
  --from-backup backup-name \
  --namespace-mappings production:test \
  --dry-run
```

### 定期復旧テスト

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-test
spec:
  schedule: "0 6 * * 1"  # 毎週月曜日午前6時
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup-tester
            image: hexabase/backup-tester:latest
            command:
            - /bin/sh
            - -c
            - |
              # 最新バックアップからテスト環境へリストア
              velero restore create test-$(date +%s) \
                --from-backup $(velero backup get -o name | head -1) \
                --namespace-mappings production:backup-test
```

## 災害復旧シナリオ

### シナリオ1: 単一ノード障害

**検出**: ノード監視アラート
**対応**: 自動Pod再スケジューリング
**RTO**: 5分
**RPO**: リアルタイム

### シナリオ2: クラスター全体障害

**検出**: クラスターヘルスチェック失敗
**対応**: セカンダリクラスターへの切り替え
**RTO**: 15分
**RPO**: 1時間

### シナリオ3: データセンター障害

**検出**: 地理的監視システム
**対応**: 別リージョンでのクラスター復旧
**RTO**: 4時間
**RPO**: 12時間

## 監視とアラート

### バックアップ監視

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: backup-monitoring
spec:
  groups:
  - name: backup.rules
    rules:
    - alert: BackupFailed
      expr: velero_backup_failure_total > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "バックアップが失敗しました"
        description: "{{ $labels.backup_name }}のバックアップが失敗しました"
    
    - alert: BackupNotScheduled
      expr: time() - velero_backup_last_successful_timestamp > 86400
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "24時間以上バックアップが実行されていません"
```

### ストレージ容量監視

```bash
# バックアップストレージ使用量確認
velero backup-location get

# 古いバックアップのクリーンアップ
velero backup delete backup-name --confirm
```

## セキュリティ考慮事項

### 暗号化

```yaml
# 保存時暗号化
apiVersion: v1
kind: Secret
metadata:
  name: cloud-credentials
type: Opaque
data:
  # 暗号化キーをBase64エンコード
  encryption-key: <base64-encoded-key>
```

### アクセス制御

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: backup-operator
rules:
- apiGroups: ["velero.io"]
  resources: ["backups", "restores"]
  verbs: ["create", "get", "list", "watch"]
- apiGroups: [""]
  resources: ["persistentvolumes", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch"]
```

## コンプライアンス

### 規制要件

- **GDPR**: 個人データの適切な保護とアクセス権
- **SOX**: 財務データの整合性と監査証跡
- **HIPAA**: 医療情報の暗号化と制御
- **ISO 27001**: 情報セキュリティ管理

### 監査ログ

```json
{
  "timestamp": "2024-07-06T12:00:00Z",
  "action": "backup_create",
  "user": "backup-operator",
  "resource": "production-backup-20240706",
  "status": "success",
  "details": {
    "namespaces": ["production"],
    "storage_location": "s3-backup",
    "size": "1.2GB"
  }
}
```

## パフォーマンス最適化

### 並列バックアップ

```yaml
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: parallel-backup
spec:
  provider: aws
  config:
    region: us-west-2
    bucket: hexabase-backups
    # 並列アップロード設定
    s3ForcePathStyle: "false"
    s3Url: https://s3.us-west-2.amazonaws.com
    concurrency: 5
```

### 増分バックアップ

```bash
# 増分バックアップの作成
velero backup create incremental-backup \
  --from-backup last-full-backup \
  --include-namespaces production
```

## トラブルシューティング

### よくある問題

1. **バックアップ失敗**
   ```bash
   # ログ確認
   velero backup logs backup-name
   
   # ストレージアクセス確認
   velero backup-location get
   ```

2. **リストア失敗**
   ```bash
   # リストア状況確認
   velero restore describe restore-name
   
   # 部分リストア
   velero restore create partial-restore \
     --from-backup backup-name \
     --include-resources pods,services
   ```

3. **ストレージ不足**
   ```bash
   # 古いバックアップの削除
   velero backup get | grep Completed | \
     awk '{print $1}' | head -10 | \
     xargs -I {} velero backup delete {} --confirm
   ```

## 次のステップ

- **戦略設計**: [バックアップ戦略](strategies.md)を確認
- **自動化**: [自動バックアップ](automated-backups.md)を設定
- **復旧手順**: [リストア手順](restore-procedures.md)を学習
- **DR計画**: [災害復旧](disaster-recovery.md)戦略を策定