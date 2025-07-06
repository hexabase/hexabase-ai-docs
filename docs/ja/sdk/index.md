# SDK

このセクションでは、Hexabase.AIソフトウェア開発キット（SDK）とプログラム的インターフェースについて説明します。アプリケーションにHKS機能を統合し、プラットフォーム操作を自動化する方法を学びます。

## このセクションの内容

- **SDKインストール**: 異なる言語のHKS SDKの使用開始
- **APIリファレンス**: 包括的なAPIドキュメントと例
- **SDKガイド**: 一般的なSDK使用例のチュートリアル
- **CLIツール**: コマンドラインインターフェースドキュメント
- **統合例**: 実際の統合パターンとコードサンプル

## 主要トピック

- HKS用Go SDK
- 自動化とAI-Ops統合用Python SDK
- Webアプリケーション用JavaScript/TypeScript SDK
- REST APIドキュメント
- GraphQL APIエンドポイント
- リアルタイム更新用WebSocket API
- 認証とAPIキー管理
- レート制限とベストプラクティス
- SDKバージョニングと移行ガイド
- カスタムリソース定義（CRD）
- Webhook開発
- Operator SDK統合
- コード例とテンプレート

カスタムツールの構築、ワークフローの自動化、既存システムへのHKS統合など、どのような作業であっても、このセクションは必要な技術リソースを提供します。

## SDK概要

<div class="grid cards" markdown>

-   :material-language-go:{ .lg .middle } **Go SDK**

    ---

    高性能なシステム統合とカスタムオペレーター開発

    [:octicons-arrow-right-24: Go SDKドキュメント](go.md)

-   :material-language-python:{ .lg .middle } **Python SDK**

    ---

    AI/ML統合と自動化スクリプト

    [:octicons-arrow-right-24: Python SDKドキュメント](python.md)

-   :material-language-javascript:{ .lg .middle } **JavaScript SDK**

    ---

    フロントエンドとNode.jsアプリケーション

    [:octicons-arrow-right-24: JavaScript SDKドキュメント](javascript.md)

-   :material-console:{ .lg .middle } **CLI ツール**

    ---

    コマンドライン管理とスクリプト作成

    [:octicons-arrow-right-24: CLIリファレンス](cli.md)

</div>

## クイックスタート

### 1. SDKのインストール

=== "JavaScript/Node.js"
    ```bash
    npm install @hexabase/sdk
    # または
    yarn add @hexabase/sdk
    ```

=== "Python"
    ```bash
    pip install hexabase-sdk
    # または
    poetry add hexabase-sdk
    ```

=== "Go"
    ```bash
    go get github.com/hexabase/hexabase-go
    ```

### 2. 基本設定

=== "JavaScript"
    ```javascript
    import { HexabaseClient } from '@hexabase/sdk';

    const client = new HexabaseClient({
      apiKey: 'hks_live_...',
      baseURL: 'https://api.hexabase.ai'
    });
    ```

=== "Python"
    ```python
    from hexabase import Client

    client = Client(
        api_key='hks_live_...',
        base_url='https://api.hexabase.ai'
    )
    ```

=== "Go"
    ```go
    import "github.com/hexabase/hexabase-go"

    client := hexabase.NewClient(&hexabase.Config{
        APIKey:  "hks_live_...",
        BaseURL: "https://api.hexabase.ai",
    })
    ```

### 3. 最初のAPI呼び出し

=== "JavaScript"
    ```javascript
    // ワークスペース一覧を取得
    const workspaces = await client.workspaces.list();
    console.log(workspaces);

    // プロジェクト作成
    const project = await client.projects.create({
      name: 'My Project',
      workspaceId: 'ws_123'
    });
    ```

=== "Python"
    ```python
    # ワークスペース一覧を取得
    workspaces = client.workspaces.list()
    print(workspaces)

    # プロジェクト作成
    project = client.projects.create(
        name='My Project',
        workspace_id='ws_123'
    )
    ```

=== "Go"
    ```go
    // ワークスペース一覧を取得
    workspaces, err := client.Workspaces.List(ctx)
    if err != nil {
        log.Fatal(err)
    }

    // プロジェクト作成
    project, err := client.Projects.Create(ctx, &hexabase.CreateProjectRequest{
        Name:        "My Project",
        WorkspaceID: "ws_123",
    })
    ```

## 認証方法

### APIキー認証

```bash
# APIキー生成
hks auth create-key --name "My App" --scope workspace:read,write

# 環境変数に設定
export HEXABASE_API_KEY="hks_live_..."
```

### OAuth認証

```javascript
// OAuth設定
const client = new HexabaseClient({
  auth: {
    type: 'oauth',
    clientId: 'your-client-id',
    clientSecret: 'your-client-secret',
    redirectUri: 'https://app.example.com/callback'
  }
});

// 認証URL生成
const authUrl = client.auth.getAuthorizationUrl();
```

## 一般的な使用例

### ワークスペース管理

```python
# ワークスペース作成
workspace = client.workspaces.create(
    name='Production Environment',
    plan='professional',
    organization_id='org_123'
)

# リソース使用状況取得
usage = client.workspaces.get_usage(workspace.id)
print(f"CPU使用率: {usage.cpu_percent}%")
```

### アプリケーションデプロイ

```javascript
// アプリケーションデプロイ
const deployment = await client.applications.deploy({
  name: 'my-app',
  image: 'nginx:latest',
  replicas: 3,
  projectId: 'proj_456'
});

// デプロイ状況監視
const status = await client.applications.getStatus(deployment.id);
```

### Function管理

```go
// Function作成
function, err := client.Functions.Create(ctx, &hexabase.CreateFunctionRequest{
    Name:      "process-data",
    Runtime:   "nodejs18",
    Code:      functionCode,
    ProjectID: "proj_789",
})

// Function実行
result, err := client.Functions.Invoke(ctx, function.ID, map[string]interface{}{
    "input": "test data",
})
```

## 高度な機能

### WebSocket接続

```javascript
// リアルタイムイベント購読
const ws = client.websocket.connect();

ws.subscribe('workspace.ws_123', (event) => {
  console.log('ワークスペースイベント:', event);
});

ws.subscribe('project.proj_456', (event) => {
  console.log('プロジェクトイベント:', event);
});
```

### バッチ操作

```python
# 複数リソースの一括操作
batch = client.batch()

# 複数の操作をキューに追加
batch.create_project(name='Project 1', workspace_id='ws_123')
batch.create_project(name='Project 2', workspace_id='ws_123')
batch.update_workspace('ws_123', {'description': 'Updated'})

# 一括実行
results = batch.execute()
```

### カスタムリソース操作

```go
// カスタムリソース定義
type MyCustomResource struct {
    hexabase.Resource `json:",inline"`
    Spec MyCustomSpec `json:"spec"`
}

// カスタムリソース作成
resource := &MyCustomResource{
    Resource: hexabase.Resource{
        Name:      "my-resource",
        Namespace: "default",
    },
    Spec: MyCustomSpec{
        Replicas: 3,
        Image:    "my-app:latest",
    },
}

err := client.CustomResources.Create(ctx, resource)
```

## エラーハンドリング

### JavaScript

```javascript
try {
  const workspace = await client.workspaces.get('ws_invalid');
} catch (error) {
  if (error.code === 'WORKSPACE_NOT_FOUND') {
    console.log('ワークスペースが見つかりません');
  } else if (error.code === 'RATE_LIMIT_EXCEEDED') {
    console.log('レート制限に達しました。しばらく待ってください。');
  } else {
    console.error('予期しないエラー:', error.message);
  }
}
```

### Python

```python
from hexabase.exceptions import WorkspaceNotFound, RateLimitExceeded

try:
    workspace = client.workspaces.get('ws_invalid')
except WorkspaceNotFound:
    print('ワークスペースが見つかりません')
except RateLimitExceeded as e:
    print(f'レート制限: {e.retry_after}秒後に再試行')
except Exception as e:
    print(f'予期しないエラー: {e}')
```

## テストとモック

### JavaScript

```javascript
import { HexabaseClient } from '@hexabase/sdk';
import { createMockClient } from '@hexabase/sdk/testing';

// モッククライアント作成
const mockClient = createMockClient();

// モックレスポンス設定
mockClient.workspaces.list.mockResolvedValue([
  { id: 'ws_123', name: 'Test Workspace' }
]);

// テスト実行
const workspaces = await mockClient.workspaces.list();
expect(workspaces).toHaveLength(1);
```

### Python

```python
from hexabase.testing import MockClient

# モッククライアント作成
client = MockClient()

# モックレスポンス設定
client.workspaces.list.return_value = [
    {'id': 'ws_123', 'name': 'Test Workspace'}
]

# テスト実行
workspaces = client.workspaces.list()
assert len(workspaces) == 1
```

## パフォーマンス最適化

### 並行処理

```python
import asyncio
from hexabase.async_client import AsyncClient

async def main():
    client = AsyncClient(api_key='hks_live_...')
    
    # 並行してデータ取得
    workspaces_task = client.workspaces.list()
    projects_task = client.projects.list()
    
    workspaces, projects = await asyncio.gather(
        workspaces_task, projects_task
    )

asyncio.run(main())
```

### キャッシュ活用

```javascript
// レスポンスキャッシュ設定
const client = new HexabaseClient({
  apiKey: 'hks_live_...',
  cache: {
    ttl: 300, // 5分間キャッシュ
    maxSize: 100 // 最大100エントリ
  }
});

// キャッシュされたデータは自動的に使用される
const workspaces = await client.workspaces.list();
```

## 次のステップ

- **詳細なSDKドキュメント**: 各言語固有の機能と例
- **APIリファレンス**: 完全なエンドポイントリスト
- **統合ガイド**: 特定のユースケースの実装方法
- **サンプルコード**: [GitHub](https://github.com/hexabase/examples)でより多くの例