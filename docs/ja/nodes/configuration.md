# ノード設定

このガイドでは、Hexabase.AI での専用ノードの高度な設定オプションについて説明します。デフォルト設定は一般的な使用に最適化されていますが、特定のワークロードに対してノードをカスタマイズする必要がある場合があります。

## ノードラベルとテイント

ラベルとテイントは、ポッドがノードにどのようにスケジュールされるかを制御する主要なメカニズムです。

- **ラベル**: `nodeSelector` と `nodeAffinity` で使用され、ポッドをノードに引き付けます。
- **テイント**: 一致する `toleration` を持たない限り、ポッドをノードから遠ざけるために使用されます。

### 一般的なラベル付けスキーム

- **ワークロードタイプ別**: `workload-type=database`, `workload-type=frontend`, `workload-type=ml`
- **環境別**: `environment=production`, `environment=staging`
- **ハードウェア別**: `gpu=nvidia-a10g`, `disk=fast-ssd`
- **チーム別**: `team=backend`, `team=data-science`

### 一般的なテイント

- **専用ハードウェア**: GPU ノードにテイント（`gpu=true:NoSchedule`）を適用することで、GPU を特別に要求するポッドのみがそこにスケジュールされることを保証します。
- **ノードメンテナンス**: メンテナンスを実行する前に、`maintenance=true:NoExecute` で手動でノードにテイントを適用できます。`NoExecute` 効果は、テイントを許容しない実行中のポッドを退避させます。

### ラベルとテイントの更新

HKS UI または CLI を通じて、いつでもノードからラベルとテイントを追加または削除できます。

```bash
# ノードに新しいラベルを追加
hb node label my-node-01 owner=sre-team

# ノードに新しいテイントを追加
hb node taint my-node-01 sensitive=true:NoSchedule

# ノードからテイントを削除
hb node taint my-node-01 sensitive:NoSchedule-
```

## ノードプール

ノードプールは、同じ設定（インスタンスタイプ、ディスクサイズ、ラベル、テイント）を共有する専用ノードのグループです。ノードプールを使用することで、同じタイプの複数のノードが必要な場合の管理が簡素化されます。

```bash
# 3つの同一ノードでノードプールを作成
hb nodepool create production-workers \
  --node-type c5.xlarge \
  --node-count 3 \
  --labels "pool=production-workers" \
  --enable-autoscaling --min-nodes 2 --max-nodes 10
```

### ノードプールの自動スケーリング

ノードプールで自動スケーリングが有効になっている場合、Hexabase.AI はリソース需要に基づいてノードを自動的に追加または削除します。

- **スケールアップ**: プール内のリソース不足により스ケジュールできない保留中のポッドがある場合、新しいノードが追加されます（`max-nodes` まで）。
- **スケールダウン**: プール内のノードが指定期間中に使用率が低く、そのポッドが他の場所に安全に再スケジュールできる場合、そのノードはドレイン処理され終了されます（`min-nodes` まで）。

## カスタムノード設定（エンタープライズプラン）

高度なユースケースでは、エンタープライズプランのお客様は `NodeConfig` リソースを使用してノードにカスタム設定を適用できます。

### カスタムカーネルパラメータ

高性能ネットワーキングやデータベースアプリケーションなど、特定のワークロード用に `sysctl` カーネルパラメータを調整できます。

```yaml
apiVersion: hks.io/v1
kind: NodeConfig
metadata:
  name: high-performance-net
spec:
  # このラベルを持つノードにこの設定を適用
  nodeSelector:
    workload-type: "real-time-bidding"

  # 適用するカーネル設定
  kernel:
    sysctl:
      net.core.somaxconn: "65535"
      net.ipv4.tcp_max_syn_backlog: "16384"
      vm.max_map_count: "262144"
```

### カスタム起動スクリプト

以下のようなアクションを実行するために、ノード起動時にカスタムスクリプトを実行します：

- サードパーティの監視やセキュリティエージェントのインストール
- 大容量データセットのダウンロードとキャッシュ
- カスタムハードウェア設定の実行

```yaml
apiVersion: hks.io/v1
kind: NodeConfig
metadata:
  name: install-custom-agent
spec:
  nodeSelector:
    team: "security"

  startupScript: |
    #!/bin/bash
    set -e
    echo "Installing custom security agent..."
    curl -sSL https://my-agent.com/install.sh | bash
    systemctl enable --now my-custom-agent
```

**セキュリティ注意**: すべての起動スクリプトはサンドボックス環境で実行され、Hexabase.AI セキュリティチームによるレビューの対象となります。すべてのアクションが許可されるわけではありません。

## ノードイメージの管理

Hexabase.AI は、専用ノード用に最適化された強化された OS イメージのセットを管理します。これらのイメージは、一般的な Linux ディストリビューション（Ubuntu や Bottlerocket など）に基づいており、`kubelet`、コンテナランタイム、HKS エージェントなどの必要なコンポーネントで事前設定されています。

- **自動更新**: HKS は、セキュリティパッチと OS 更新を適用するために、無停止でローリング方式で新しいノードイメージを自動的にロールアウトします。
- **カスタムイメージ（エンタープライズプラン）**: 独自の「ゴールデン」OS イメージを使用する厳格な要件を持つ組織向けに、HKS は、特定のセキュリティと互換性基準を満たすことを条件として、カスタムイメージをプロビジョニングパイプラインに統合する作業を支援できます。