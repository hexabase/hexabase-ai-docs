# 権限モデル

Hexabase.AI 権限モデルは、柔軟で拡張可能になるよう設計されており、プラットフォーム内のすべてのアクションにきめ細かい制御を提供します。ほとんどのユーザーは組み込みロールを使用しますが、基盤となる権限モデルを理解することは、カスタムロールを作成したり、監査目的で有用です。

## 権限の構造

権限は、誰がどのリソースに対して何をできるかを定義する単一のルールです。各権限は3つのコンポーネントで構成されます：

1. **`apiGroups`**: アクセスされる API のグループ。コア Kubernetes リソースの場合、グループは `""`（空文字列）です。その他の場合、`apps`、`batch`、`hks.io` などの名前付きグループです。
2. **`resources`**: 権限が適用されるオブジェクトのタイプ（例：`pods`、`deployments`、`backupplans`）。
3. **`verbs`**: リソースで許可されるアクション（例：`get`、`create`、`delete`）。

**権限ステートメントの例:**
"`apps`（`apiGroup`）で `deployments`（`resource`）の `creating`（`verb`）を許可します。"

## ロール内での権限の定義方法

カスタム `WorkspaceRole` では、権限はリストで定義されます。

```yaml
apiVersion: hks.io/v1
kind: WorkspaceRole
metadata:
  name: custom-viewer
spec:
  permissions:
    # ルール 1: コアワークロードリソースの表示を許可
    - apiGroups: ["", "apps", "batch"]
      resources: ["pods", "deployments", "jobs", "services"]
      verbs: ["get", "list", "watch"]

    # ルール 2: ポッドログの表示を許可
    - apiGroups: [""]
      resources: ["pods/log"]
      verbs: ["get", "list", "watch"]

    # ルール 3: HKS 固有リソースの表示を許可
    - apiGroups: ["hks.io"]
      resources: ["backups", "functions"]
      verbs: ["get", "list", "watch"]
```

## 一般的な動詞

権限で割り当てることができる最も一般的なアクション（動詞）です。

| 動詞               | 説明                                                    |
| :----------------- | :------------------------------------------------------ |
| `get`              | 名前で単一のリソースを取得                               |
| `list`             | リソースのリストを取得                                   |
| `watch`            | リソースの変更をリアルタイムで「監視」                   |
| `create`           | 新しいリソースを作成                                     |
| `update`           | 既存のリソースを変更                                     |
| `patch`            | 既存のリソースに部分的な変更を適用                       |
| `delete`           | リソースを削除                                           |
| `deletecollection` | 複数のリソースを一度に削除                               |
| `*`                | すべての動詞を表すワイルドカード。注意して使用           |

## リソース命名とサブリソース

一部のリソースには、独立して制御できるサブリソースがあります。最も一般的な例は `pods/log` です。

- ポッドを表示する権限を付与するには、`pods` リソースに対する `get` が必要です。
- ポッドのログを表示する権限を付与するには、`pods/log` サブリソースに対する `get` が必要です。

これにより、ポッドが動作していることは確認できるが、ログ内の潜在的に機密性の高い情報にはアクセスできないユーザー用のロールを作成できます。

## 集約ロール

Hexabase.AI は Kubernetes のロール集約機能を利用しています。これは、一部のロールが他のロールで構成されることを意味します。

例えば、HKS の組み込み `developer` ロールは、実際にはより小さく、より焦点を絞った複数のロールを集約しています：

- コアワークロード（`pods`、`deployments`）を管理するロール
- ネットワーキング（`services`、`ingresses`）を管理するロール
- ワークスペース内の CI/CD リソースを管理するロール

これにより、システムの管理と拡張が容易になります。HKS に新機能が追加されると、その機能用の新しい詳細なロールを作成し、ベースロール（`admin`、`developer`、`viewer`）を直接変更することなく、ベースロールに集約できます。

## 生の Kubernetes ロールの表示

`workspace_admin` 権限を持っている場合、HKS が独自の `WorkspaceRole` から生成する生の Kubernetes `Role` を表示できます。

```bash
# まず、生成されたロールの名前を見つけます
# 通常、'hks-' がプレフィックスとして付きます
kubectl get roles -n <your-workspace-namespace>

# 次に、ロールの YAML 定義を表示します
kubectl get role <generated-role-name> -o yaml
```

これは、Kubernetes レベルで適用されている正確な権限を理解するための有用なデバッグツールです。