# CronJobs

Kubernetes CronJobsを使用してHexabase.AIでスケジュールされたタスクのデプロイメントと管理をマスターしましょう。

## 概要

Hexabase.AIのCronJobsは、Kubernetes環境でスケジュールされたタスクを実行する信頼性の高い方法を提供します。定期的なバックアップ、データ処理ジョブ、メンテナンスタスクの実行が必要な場合、我々のプラットフォームはCronJobの作成と管理を簡素化し、監視、アラート、ジョブ履歴追跡などのエンタープライズ機能を追加します。

## CronJobドキュメント

<div class="grid cards" markdown>

- :material-clock-start:{ .lg .middle } **はじめに**

  ***

  CronJobsの作成とデプロイの基本を学ぶ

  [:octicons-arrow-right-24: CronJob基本](management.md)

- :material-calendar-clock:{ .lg .middle } **スケジューリングパターン**

  ***

  cron式とスケジューリング戦略をマスター

  [:octicons-arrow-right-24: スケジューリングガイド](management.md)

- :material-cog-sync:{ .lg .middle } **高度な設定**

  ***

  ジョブポリシー、リソース、依存関係を設定

  [:octicons-arrow-right-24: 高度な設定](management.md)

- :material-monitor-dashboard:{ .lg .middle } **監視＆デバッグ**

  ***

  ジョブ実行の追跡と障害のトラブルシューティング

  [:octicons-arrow-right-24: 監視ガイド](../observability/monitoring-setup.md)

</div>

## 主要機能

### 1. 強化されたスケジューリング

- **視覚的Cronビルダー**: 直感的なUIでcron式を作成
- **タイムゾーンサポート**: 任意のタイムゾーンでジョブをスケジュール
- **スケジュール検証**: 無効なcron式を防止
- **次回実行プレビュー**: ジョブが次にいつ実行されるかを確認

### 2. ジョブ管理

- **ジョブ履歴**: ログとメトリクスですべての実行を追跡
- **手動トリガー**: テスト用のオンデマンドジョブ実行
- **一時停止/再開**: 削除せずにジョブを一時的に無効化
- **バッチ操作**: 複数のCronJobsを一度に管理

### 3. エンタープライズ機能

- **失敗通知**: ジョブが失敗した時のアラート
- **成功追跡**: ジョブ完了率の監視
- **リソース制限**: 暴走ジョブの防止
- **依存関係管理**: ジョブをチェーン化

### 4. 統合機能

- **シークレット管理**: 認証情報の安全な注入
- **ConfigMapサポート**: 動的設定
- **ボリュームマウント**: 永続データへのアクセス
- **サービス接続**: 他のサービスとの連携

## 一般的なユースケース

### データ処理

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-etl
spec:
  schedule: "0 2 * * *" # 毎日午前2時
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: etl-processor
              image: myapp/etl:latest
              command: ["python", "etl.py"]
```

### バックアップ操作

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
spec:
  schedule: "0 */6 * * *" # 6時間毎
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: postgres:14
              command: ["pg_dump"]
              env:
                - name: PGPASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: db-secret
                      key: password
```

### メンテナンスタスク

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-old-data
spec:
  schedule: "30 3 * * 0" # 毎週日曜日午前3:30
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: cleanup
              image: myapp/maintenance:latest
              command: ["./cleanup.sh"]
```

## CronJobライフサイクル

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    作成     │────▶│ スケジュール │────▶│    実行中   │
└─────────────┘     └─────────────┘     └─────────────┘
                           │                     │
                           ▼                     ▼
                    ┌─────────────┐     ┌─────────────┐
                    │   一時停止   │     │    完了     │
                    └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │    履歴     │
                                        └─────────────┘
```

## ベストプラクティス

### 1. べき等なジョブ

副作用なしに安全に再実行できるジョブを設計

### 2. 適切なタイムアウト

ハングしたジョブを防ぐために現実的な期限を設定

### 3. リソース制限

クラスター安定性を保護するためにCPUとメモリ制限を定義

### 4. エラーハンドリング

適切なエラーハンドリングと再試行ロジックを実装

### 5. 監視

ジョブ失敗とパフォーマンス問題のアラートを設定

## クイック例

### シンプルな時間別ジョブ

```bash
hks cronjob create hourly-report \
  --schedule "0 * * * *" \
  --image myapp/reporter:latest \
  --command "python report.py"
```

### 環境変数付きジョブ

```bash
hks cronjob create data-sync \
  --schedule "*/15 * * * *" \
  --image myapp/sync:latest \
  --env DATABASE_URL=postgresql://... \
  --env API_KEY_FROM_SECRET=api-secret:key
```

### ジョブ履歴表示

```bash
hks cronjob history daily-backup --last 10
```

## cron式ガイド

### 基本形式

```
┌───────────── 分 (0 - 59)
│ ┌─────────── 時 (0 - 23)
│ │ ┌───────── 日 (1 - 31)
│ │ │ ┌─────── 月 (1 - 12)
│ │ │ │ ┌───── 曜日 (0 - 6) (日曜日は0)
│ │ │ │ │
* * * * *
```

### よく使用されるパターン

| 式 | 説明 |
|---|---|
| `0 0 * * *` | 毎日午前0時 |
| `0 */6 * * *` | 6時間毎 |
| `30 2 * * 0` | 毎週日曜日午前2:30 |
| `0 9 1 * *` | 毎月1日午前9時 |
| `*/15 * * * *` | 15分毎 |

## ジョブ設定例

### リソース制限付きジョブ

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: resource-limited-job
spec:
  schedule: "0 3 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: processor
            image: myapp/processor:latest
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"
          restartPolicy: OnFailure
```

### 失敗ポリシー付きジョブ

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: reliable-job
spec:
  schedule: "0 */2 * * *"
  failedJobsHistoryLimit: 3
  successfulJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      backoffLimit: 3
      activeDeadlineSeconds: 3600  # 1時間タイムアウト
      template:
        spec:
          containers:
          - name: worker
            image: myapp/worker:latest
          restartPolicy: OnFailure
```

### シークレット使用ジョブ

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: secret-job
spec:
  schedule: "0 4 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: secure-worker
            image: myapp/secure:latest
            env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: password
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: api-credentials
                  key: key
          restartPolicy: OnFailure
```

## 監視とアラート

### ジョブ監視メトリクス

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cronjob-monitoring
spec:
  groups:
  - name: cronjob.rules
    rules:
    - alert: CronJobFailed
      expr: kube_job_status_failed > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "CronJobが失敗しました"
        description: "{{ $labels.job_name }}が失敗しました"
    
    - alert: CronJobNotScheduled
      expr: time() - kube_cronjob_next_schedule_time > 3600
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: "CronJobがスケジュールされていません"
```

### ログ監視

```bash
# ジョブログの表示
kubectl logs job/my-cronjob-1234567890

# CronJobのすべてのジョブログ
kubectl logs -l job-name=my-cronjob --tail=100
```

## トラブルシューティングガイド

### よくある問題

1. **ジョブが実行されない**

   - cron式の構文を確認
   - タイムゾーン設定を確認
   - ジョブが一時停止されていないか確認

2. **ジョブが失敗する**

   - ジョブログを確認
   - リソース制限を確認
   - イメージの可用性を確認

3. **パフォーマンス問題**
   - リソース使用量の監視
   - 同時実行ジョブ制限の確認
   - ジョブ期間トレンドの確認

### デバッグコマンド

```bash
# CronJob状態確認
kubectl get cronjob my-cronjob

# ジョブ詳細確認
kubectl describe cronjob my-cronjob

# 最新ジョブの確認
kubectl get jobs -l job-name=my-cronjob

# ジョブの手動作成
kubectl create job manual-job --from=cronjob/my-cronjob
```

## パフォーマンス最適化

### 効率的なジョブ設計

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: optimized-job
spec:
  schedule: "0 2 * * *"
  concurrencyPolicy: Replace  # 長時間実行ジョブの重複を防ぐ
  startingDeadlineSeconds: 300  # 5分以内に開始
  jobTemplate:
    spec:
      parallelism: 3  # 並列実行
      completions: 9  # 3×3のタスク
      template:
        spec:
          containers:
          - name: worker
            image: myapp/optimized:latest
            resources:
              requests:
                memory: "128Mi"
                cpu: "100m"
```

### バッチ処理戦略

```python
# 効率的なバッチ処理例
import os
import time
from concurrent.futures import ThreadPoolExecutor

def process_batch(items):
    """アイテムのバッチを処理"""
    batch_size = int(os.getenv('BATCH_SIZE', '100'))
    
    with ThreadPoolExecutor(max_workers=4) as executor:
        for i in range(0, len(items), batch_size):
            batch = items[i:i + batch_size]
            executor.submit(process_items, batch)
            
            # レート制限
            time.sleep(0.1)

def process_items(items):
    """個別アイテム処理"""
    for item in items:
        # アイテム処理ロジック
        process_single_item(item)
```

## 次のステップ

- **CronJobsが初めて？** [はじめに](management.md)から開始
- **スケジューリングのヘルプが必要？** [スケジューリングパターン](management.md)をチェック
- **高度な使用法？** [設定オプション](management.md)を探索
- **問題がある？** [監視＆デバッグ](../observability/monitoring-setup.md)を参照

## 関連ドキュメント

- [Kubernetes Jobs Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- イベント駆動タスクの[Functions](../functions/index.md)
- 監視用の[オブザーバビリティ](../observability/index.md)
- プログラムアクセス用の[APIリファレンス](../api/index.md)