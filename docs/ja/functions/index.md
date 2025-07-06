# Functions

Hexabase.AIのFunctions機能でKubernetes上にサーバーレス関数をデプロイ・管理します。

## 概要

Hexabase.AI Functionsは、Kubernetesインフラストラクチャにサーバーレスコンピューティングをもたらし、サーバーやコンテナを管理することなくコードを実行できます。業界標準のフレームワークに基づいて構築されたFunctions機能は、自動スケーリング、イベント駆動実行、既存のKubernetesワークロードとのシームレスな統合を提供します。

## Functionsドキュメント

<div class="grid cards" markdown>

- :material-lightning-bolt:{ .lg .middle } **クイックスタート**

  ***

  数分で最初の関数をデプロイ

  [:octicons-arrow-right-24: 開始する](overview.md)

- :material-function:{ .lg .middle } **関数タイプ**

  ***

  HTTPエンドポイント、イベントハンドラー、スケジュール関数

  [:octicons-arrow-right-24: 関数タイプ](architecture.md)

- :material-code-braces:{ .lg .middle } **開発ガイド**

  ***

  関数の作成、テスト、デバッグ

  [:octicons-arrow-right-24: 開発ガイド](development.md)

- :material-rocket-launch:{ .lg .middle } **デプロイメント**

  ***

  関数を簡単にデプロイ・管理

  [:octicons-arrow-right-24: デプロイメントガイド](deployment.md)

</div>

## 主要機能

### 1. 多言語サポート

- **Python**: データ処理とMLワークロード
- **Node.js**: APIエンドポイントとWebhook
- **Go**: 高性能サービス
- **Java**: エンタープライズ統合
- **カスタムランタイム**: 独自ランタイムの持ち込み

### 2. イベントソース

- **HTTPトリガー**: RESTful APIとWebhook
- **メッセージキュー**: Kafka、RabbitMQ、NATS
- **ストレージイベント**: S3互換オブジェクトストレージ
- **スケジュールイベント**: Cronベーストリガー
- **カスタムイベント**: アプリケーション固有のトリガー

### 3. 自動スケーリング

- **ゼロスケール**: アイドル時のリソース節約
- **瞬間スケールアップ**: トラフィックスパイクの処理
- **並行実行**: 複数リクエストの処理
- **カスタムメトリクス**: 独自のメトリクスに基づくスケーリング

### 4. 開発者体験

- **ローカル開発**: 関数をローカルでテスト
- **ホットリロード**: 開発中の即座更新
- **統合ログ**: 一元化された関数ログ
- **分散トレーシング**: リクエストフローの追跡

## ユースケース

### APIエンドポイント

```python
# function.py
def handle(request):
    name = request.get('name', 'World')
    return {
        'statusCode': 200,
        'body': f'Hello, {name}!'
    }
```

### データ処理

```python
# process_image.py
import base64
from PIL import Image

def handle(event):
    # アップロードされた画像を処理
    image_data = base64.b64decode(event['data'])
    img = Image.open(io.BytesIO(image_data))

    # 画像リサイズ
    thumbnail = img.resize((128, 128))

    # 処理済み画像を返す
    output = io.BytesIO()
    thumbnail.save(output, format='JPEG')

    return {
        'statusCode': 200,
        'body': base64.b64encode(output.getvalue()),
        'headers': {'Content-Type': 'image/jpeg'}
    }
```

### イベント処理

```javascript
// handle_order.js
module.exports.handle = async (event) => {
  const order = JSON.parse(event.data);

  // 注文処理
  await validateOrder(order);
  await chargePayment(order);
  await sendConfirmation(order);

  return {
    statusCode: 200,
    body: JSON.stringify({
      orderId: order.id,
      status: "processed",
    }),
  };
};
```

## アーキテクチャ

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   イベントソース │────▶│  関数ルーター    │────▶│ 関数ランタイム    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │                          │
                               ▼                          ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │  オートスケーラー │     │   あなたの関数   │
                        └─────────────────┘     └─────────────────┘
```

## 関数ライフサイクル

1. **開発**: ローカルで作成・テスト
2. **パッケージング**: コードと依存関係をバンドル
3. **デプロイメント**: Hexabase.AIにプッシュ
4. **呼び出し**: イベントによってトリガー
5. **スケーリング**: 負荷に基づく自動調整
6. **監視**: パフォーマンスとエラーの追跡

## クイック例

### 関数のデプロイ

```bash
# 現在のディレクトリからデプロイ
hks function deploy hello-world \
  --runtime python3.9 \
  --handler function.handle \
  --trigger http

# Gitリポジトリからデプロイ
hks function deploy data-processor \
  --git-url https://github.com/myorg/functions \
  --git-path processors/etl \
  --trigger cron --schedule "0 * * * *"
```

### 関数の呼び出し

```bash
# HTTPトリガー
curl https://api.hexabase.ai/functions/hello-world \
  -d '{"name": "Alice"}'

# 直接呼び出し
hks function invoke data-processor \
  --data '{"file": "s3://bucket/data.csv"}'
```

### 関数ログの表示

```bash
hks function logs hello-world --follow
```

## 関数開発例

### HTTP API関数

```python
# api_function.py
import json

def handle(request):
    """RESTful API エンドポイント"""
    method = request.get('method', 'GET')
    path = request.get('path', '/')
    
    if method == 'GET' and path == '/users':
        # ユーザー一覧を返す
        users = get_users_from_database()
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(users)
        }
    
    elif method == 'POST' and path == '/users':
        # 新しいユーザーを作成
        user_data = json.loads(request.get('body', '{}'))
        user = create_user(user_data)
        return {
            'statusCode': 201,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(user)
        }
    
    return {
        'statusCode': 404,
        'body': 'Not Found'
    }
```

### イベント処理関数

```python
# event_processor.py
import logging

def handle(event):
    """メッセージキューからのイベント処理"""
    try:
        event_type = event.get('type')
        data = event.get('data')
        
        if event_type == 'user_registered':
            send_welcome_email(data['email'])
            create_user_profile(data)
            
        elif event_type == 'order_placed':
            process_payment(data['order_id'])
            update_inventory(data['items'])
            
        return {
            'statusCode': 200,
            'message': f'Successfully processed {event_type}'
        }
        
    except Exception as e:
        logging.error(f'Error processing event: {e}')
        return {
            'statusCode': 500,
            'error': str(e)
        }
```

### スケジュール関数

```python
# scheduled_task.py
import datetime
from database import get_connection

def handle(event):
    """日次データクリーンアップタスク"""
    today = datetime.date.today()
    cutoff_date = today - datetime.timedelta(days=30)
    
    # 30日以上古いログを削除
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "DELETE FROM logs WHERE created_at < %s",
        (cutoff_date,)
    )
    
    deleted_count = cursor.rowcount
    conn.commit()
    conn.close()
    
    return {
        'statusCode': 200,
        'message': f'Deleted {deleted_count} old log entries'
    }
```

## 設定とトリガー

### HTTP トリガー設定

```yaml
# function.yaml
name: hello-api
runtime: python3.9
handler: main.handle
triggers:
  - type: http
    methods: [GET, POST]
    path: /api/hello
    auth: required
resources:
  memory: 256MB
  timeout: 30s
environment:
  DATABASE_URL: ${DATABASE_URL}
  LOG_LEVEL: info
```

### イベントトリガー設定

```yaml
# event-function.yaml
name: order-processor
runtime: nodejs16
handler: index.handle
triggers:
  - type: queue
    source: order-events
    batch_size: 10
    max_batch_wait: 5s
scaling:
  min_instances: 0
  max_instances: 100
  concurrency: 10
```

### スケジュールトリガー設定

```yaml
# scheduled-function.yaml
name: daily-cleanup
runtime: python3.9
handler: cleanup.handle
triggers:
  - type: schedule
    cron: "0 2 * * *"  # 毎日午前2時
    timezone: Asia/Tokyo
resources:
  memory: 512MB
  timeout: 300s
```

## ベストプラクティス

### 1. ステートレス設計

関数は呼び出し間で状態を維持すべきではありません

### 2. 高速コールドスタート

依存関係と初期化時間を最小限に抑制

### 3. エラーハンドリング

適切なエラーハンドリングと再試行を実装

### 4. リソース制限

適切なメモリとタイムアウト制限を設定

### 5. セキュリティ

機密データにはシークレット管理を使用

## CronJobsとの比較

| 機能 | Functions | CronJobs |
|------|-----------|-----------|
| トリガー | イベント、HTTP、スケジュール | スケジュールのみ |
| スケーリング | 自動（0からN） | 固定レプリカ |
| 実行時間 | 短時間（秒〜分） | 長時間実行可能 |
| ユースケース | APIエンドポイント、Webhook | バッチ処理、バックアップ |

## 監視と運用

### ログ確認

```bash
# リアルタイムログ
hks function logs my-function --follow

# 特定期間のログ
hks function logs my-function --since 1h

# エラーログのみ
hks function logs my-function --level error
```

### メトリクス監視

```bash
# 関数統計表示
hks function stats my-function

# パフォーマンスメトリクス
hks function metrics my-function --period 7d
```

### デバッグ

```bash
# ローカルでテスト
hks function test my-function --data '{"test": "data"}'

# リモートデバッグ
hks function debug my-function --attach
```

## AI統合例

### AI関数デプロイ

```python
# ai_function.py
import openai
from hexabase import get_secret

def handle(request):
    """AI駆動のテキスト処理関数"""
    openai.api_key = get_secret('OPENAI_API_KEY')
    
    prompt = request.get('prompt', '')
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=150
    )
    
    return {
        'statusCode': 200,
        'body': {
            'response': response.choices[0].message.content,
            'usage': response.usage.total_tokens
        }
    }
```

## 次のステップ

- **開始**: [クイックスタート](overview.md)で最初の関数をデプロイ
- **学習**: 異なる[関数タイプ](architecture.md)を探索
- **構築**: [開発ガイド](development.md)に従う
- **デプロイ**: [デプロイメント](deployment.md)をマスター

## 関連ドキュメント

- スケジュールされたバッチジョブの[CronJobs](../cronjobs/index.md)
- 関数API用の[APIリファレンス](../api/function-api.md)
- 監視用の[オブザーバビリティ](../observability/index.md)
- [セキュリティベストプラクティス](../security/index.md)