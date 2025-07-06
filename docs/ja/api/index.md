# APIリファレンス

Hexabase.AIプラットフォームとプログラム的に統合するための完全なAPIドキュメント。

## 概要

Hexabase.AI APIは、すべてのプラットフォーム機能への包括的なプログラム的アクセスを提供します。REST原則に基づいて構築され、複雑なクエリにはGraphQLサポートを提供する当社のAPIにより、ワークフローの自動化、CI/CDパイプラインとの統合、プラットフォーム上でのカスタムツールの構築が可能です。

## APIドキュメント

<div class="grid cards" markdown>

-   :material-key:{ .lg .middle } **認証**

    ---

    APIキー、OAuth、サービスアカウント

    [:octicons-arrow-right-24: 認証ガイド](authentication.md)

-   :material-api:{ .lg .middle } **REST API**

    ---

    すべてのリソース用RESTfulエンドポイント

    [:octicons-arrow-right-24: RESTリファレンス](rest-api.md)

-   :material-graphql:{ .lg .middle } **GraphQL API**

    ---

    複雑なデータニーズに対応する柔軟なクエリ

    [:octicons-arrow-right-24: GraphQLスキーマ](websocket-api.md)

-   :material-code-json:{ .lg .middle } **SDK・ツール**

    ---

    クライアントライブラリと開発者ツール

    [:octicons-arrow-right-24: SDKドキュメント](../sdk/index.md)

</div>

## クイックスタート

### 1. APIキーの取得
```bash
# APIキーを生成
hks auth create-key --name "My API Key" --scope workspace:read,write

# 出力:
# API Key: hks_live_a1b2c3d4e5f6...
# Key ID: key_123456
```

### 2. 最初のリクエスト
```bash
# curlを使用
curl -H "Authorization: Bearer hks_live_a1b2c3d4e5f6..." \
  https://api.hexabase.ai/v1/workspaces

# HTTPieを使用
http GET https://api.hexabase.ai/v1/workspaces \
  Authorization:"Bearer hks_live_a1b2c3d4e5f6..."
```

### 3. SDKの使用
```python
# Python SDK
from hexabase import Client

client = Client(api_key="hks_live_a1b2c3d4e5f6...")
workspaces = client.workspaces.list()
```

## API設計原則

### RESTful設計
- **リソースベース**: URLはリソースを表す
- **HTTPメソッド**: 標準動詞（GET、POST、PUT、DELETE）
- **ステートレス**: 各リクエストは独立している
- **一貫性**: 予測可能な命名規則

### レスポンス形式
```json
{
  "data": {
    "id": "ws_123",
    "name": "My Workspace",
    "plan": "professional"
  },
  "meta": {
    "request_id": "req_abc123",
    "timestamp": "2024-07-06T12:00:00Z"
  }
}
```

### エラーハンドリング
```json
{
  "error": {
    "code": "WORKSPACE_NOT_FOUND",
    "message": "The specified workspace does not exist",
    "details": {
      "workspace_id": "ws_invalid"
    }
  },
  "meta": {
    "request_id": "req_abc123"
  }
}
```

## 認証方法

### APIキー認証
```bash
curl -H "Authorization: Bearer hks_live_..." \
  https://api.hexabase.ai/v1/workspaces
```

### OAuth 2.0
```bash
# アクセストークンを使用
curl -H "Authorization: Bearer eyJhbGciOiJSUzI1..." \
  https://api.hexabase.ai/v1/workspaces
```

### サービスアカウント
```bash
# サービスアカウントキー
curl -H "Authorization: Bearer hks_svc_..." \
  https://api.hexabase.ai/v1/admin/users
```

## レート制限

| プラン | リクエスト/分 | バースト制限 |
|--------|--------------|-------------|
| Starter | 100 | 200 |
| Professional | 500 | 1000 |
| Enterprise | 2000 | 5000 |
| Custom | カスタム | カスタム |

### レート制限ヘッダー
```
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 487
X-RateLimit-Reset: 1625097600
Retry-After: 60
```

## ページネーション

### カーソルベースページネーション
```bash
# 最初のページ
GET /v1/workspaces?limit=20

# 次のページ
GET /v1/workspaces?limit=20&cursor=eyJpZCI6IndzXzEyMyJ9
```

### レスポンス例
```json
{
  "data": [
    {"id": "ws_1", "name": "Workspace 1"},
    {"id": "ws_2", "name": "Workspace 2"}
  ],
  "pagination": {
    "has_more": true,
    "next_cursor": "eyJpZCI6IndzXzIifQ=="
  }
}
```

## フィルタリングとソート

### クエリパラメータ
```bash
# フィルタリング
GET /v1/workspaces?plan=professional&status=active

# ソート
GET /v1/workspaces?sort=name:asc&sort=created_at:desc

# 検索
GET /v1/workspaces?search=production
```

### 高度なフィルタリング
```bash
# 日付範囲
GET /v1/workspaces?created_after=2024-01-01&created_before=2024-12-31

# 配列フィルター
GET /v1/projects?tags=production,frontend
```

## WebSocket API

### 接続
```javascript
const ws = new WebSocket('wss://api.hexabase.ai/v1/ws');
ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'hks_live_...'
  }));
};
```

### イベント購読
```javascript
// ワークスペースイベントを購読
ws.send(JSON.stringify({
  type: 'subscribe',
  channels: ['workspace.ws_123', 'project.proj_456']
}));
```

## API エクスプローラー

### インタラクティブドキュメント
- **Swagger UI**: https://api.hexabase.ai/docs
- **GraphQL Playground**: https://api.hexabase.ai/graphql
- **Postman Collection**: [ダウンロード](https://postman.hexabase.ai)

### テスト環境
```bash
# サンドボックス環境
curl -H "Authorization: Bearer hks_test_..." \
  https://api-sandbox.hexabase.ai/v1/workspaces
```

## 次のステップ

- **認証の設定**: [認証ガイド](authentication.md)を読む
- **REST APIの探索**: [RESTリファレンス](rest-api.md)で利用可能なエンドポイントを確認
- **SDKの使用**: [SDKドキュメント](../sdk/index.md)でお好みの言語のライブラリを見つける
- **サンプルの確認**: [GitHub](https://github.com/hexabase/examples)で実用的な例を見る

## サポート

- **ドキュメント**: [docs.hexabase.ai](https://docs.hexabase.ai)
- **コミュニティ**: [Discord](https://discord.gg/hexabase)
- **課題報告**: [GitHub Issues](https://github.com/hexabase/hexabase-ai/issues)
- **メール**: [api-support@hexabase.ai](mailto:api-support@hexabase.ai)