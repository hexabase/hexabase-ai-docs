# Hexabase AI: コンセプトとアーキテクチャ

## 1. プロジェクト概要

### ビジョン

Hexabase AI は、K3s と vCluster を基盤とするオープンソースのマルチテナント Kubernetes as a Service プラットフォームであり、あらゆるスキルレベルの開発者が Kubernetes を利用できるように設計されています。

### コアバリュー

- **導入の容易さ**: 軽量な K3s ベースと vCluster 仮想化による迅速なデプロイメント
- **直感的な UX**: 組織、ワークスペース、プロジェクトを通じて Kubernetes の複雑さを抽象化
- **強力なテナント分離**: vCluster がテナントごとに専用 API サーバーとコントロールプレーンを提供
- **クラウドネイティブ運用**: Prometheus、Grafana、Loki 監視内蔵；Flux GitOps；Kyverno ポリシー
- **オープンソースの透明性**: 完全なソースコード公開によるコミュニティ主導の開発

### 既存のコードベース

- **UI (Next.js)**: https://github.com/b-eee/hxb-next-webui
- **API (Go)**: https://github.com/b-eee/apicore

両リポジトリとも、この仕様に基づく大幅な再実装が必要です。

## 2. システムアーキテクチャ

### コンポーネント概要

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Hexabase UI    │────▶│  Hexabase API    │────▶│  Host K3s       │
│  (Next.js)      │     │  (Control Plane) │     │  Cluster        │
└─────────────────┘     └────────┬─────────┘     └────────┬────────┘
                                 │                        │
                        ┌────────┴────────┐               │
                        │                 │          ┌────▼────────┐
                  ┌─────▼─────┐     ┌─────▼─────┐    │  vClusters  │
                  │PostgreSQL │     │   Redis   │    │  (Tenants)  │
                  └───────────┘     └───────────┘    └─────────────┘
                                          │
                                    ┌─────▼─────┐
                                    │   NATS    │
                                    └───────────┘
```

### データフロー

1. **ユーザー操作**: ブラウザ → UI → 認証トークン付き API リクエスト
2. **API 処理**: 認証検証 → ビジネスロジック → DB 更新 → 非同期タスク
3. **vCluster オーケストレーション**: API → client-go → Host K3s → vCluster ライフサイクル
4. **非同期処理**: API → NATS → ワーカー → 長時間実行オペレーション
5. **状態永続化**: すべてのエンティティに PostgreSQL、キャッシュに Redis
6. **監視**: Prometheus メトリクス → Loki ログ → Grafana ダッシュボード
7. **GitOps デプロイメント**: Git → Flux → Host K3s → 自動アップデート
8. **ポリシー適用**: Kyverno admission controller → ポリシー検証

## 3. コアコンセプト

| Hexabase コンセプト     | Kubernetes 同等物     | スコープ    | 説明                                   |
| ---------------------- | -------------------- | ---------- | ------------------------------------- |
| 組織                   | N/A                  | Hexabase   | 請求とユーザー管理単位                  |
| ワークスペース          | vCluster             | Host K3s   | 分離された Kubernetes 環境              |
| ワークスペースプラン    | ResourceQuota/Nodes  | vCluster   | リソース制限とノード配分                |
| 組織ユーザー           | N/A                  | Hexabase   | 請求/管理担当者                        |
| ワークスペースメンバー  | OIDC Subject         | vCluster   | kubectl アクセス権を持つ技術ユーザー   |
| ワークスペースグループ  | OIDC Claim           | vCluster   | 権限割り当て単位（階層的）             |
| ワークスペース ClusterRole | ClusterRole      | vCluster   | プリセットワークスペース全体権限        |
| プロジェクト           | Namespace            | vCluster   | ワークスペース内のリソース分離          |
| プロジェクトロール      | Role                 | Namespace  | プロジェクト内のカスタム権限            |

## 4. ユーザーフロー

### 4.1 サインアップと組織管理

- **認証**: OIDC による外部 IdP（Google/GitHub）
- **自動プロビジョニング**: 初回サインアップ時にプライベート組織を作成
- **組織管理者**: 請求（Stripe）とユーザー招待を管理

### 4.2 ワークスペース（vCluster）管理

- **作成**: プラン選択 → vCluster プロビジョニング → OIDC 設定
- **初期設定**:
  - ClusterRoles 自動作成: `hexabase:workspace-admin`, `hexabase:workspace-viewer`
  - デフォルトグループ作成: `WorkspaceMembers` → `WSAdmins`, `WSUsers`
  - 作成者を `WSAdmins` グループに割り当て

### 4.3 プロジェクト（Namespace）管理

- **作成**: UI リクエスト → vCluster 内で namespace 作成
- **ResourceQuota**: ワークスペースプランに基づく自動適用
- **カスタムロール**: UI を通じてプロジェクトスコープロールを作成

### 4.4 権限管理

- **割り当て**: UI を通じてグループ → ロール/ClusterRoles
- **継承**: 再帰的なグループメンバーシップ解決
- **OIDC 統合**: トークンクレーム内の平坦化されたグループ

## 5. 技術スタック

### コアコンポーネント

- **フロントエンド**: Next.js
- **バックエンド**: Go (Golang)
- **データベース**: PostgreSQL（プライマリ）、Redis（キャッシュ）
- **メッセージング**: NATS
- **コンテナプラットフォーム**: K3s + vCluster

### CI/CD & 運用

- **CI パイプライン**: Tekton（Kubernetes ネイティブ）
- **GitOps**: ArgoCD または Flux
- **コンテナスキャン**: Trivy
- **ランタイムセキュリティ**: Falco
- **ポリシーエンジン**: Kyverno

## 6. インストール（IaC）

### Helm アンブレラチャート

```yaml
apiVersion: v2
name: hexabase-ai
dependencies:
  - name: postgresql
    repository: https://charts.bitnami.com/bitnami
  - name: redis
    repository: https://charts.bitnami.com/bitnami
  - name: nats
    repository: https://nats-io.github.io/k8s/helm/charts/
```

### クイックインストール

```bash
helm repo add hexabase https://hexabase.ai/charts
helm install hexabase-ai hexabase/hexabase-ai -f values.yaml
```

## 7. 主要機能

### マルチテナンシー

- vCluster による完全な API サーバー分離
- テナントごとの専用コントロールプレーンコンポーネント
- プレミアムプラン向けオプション専用ノード

### セキュリティ

- 外部 IdP 認証のみ
- Hexabase が vCluster の OIDC プロバイダーとして機能
- Kyverno ポリシー適用
- テナント間のネットワーク分離

### スケーラビリティ

- コントロールプレーンコンポーネントの水平スケーリング
- キューベースの非同期処理
- ステートレス API 設計
- Redis キャッシュレイヤー

### オブザーバビリティ

- Prometheus メトリクス収集
- Loki による集中ログ
- 事前構築済み Grafana ダッシュボード
- リアルタイムリソース使用量追跡

## 8. まとめ

Hexabase AI は、インテリジェントな抽象化、強力なマルチテナンシー、エンタープライズグレードの運用ツールを通じて Kubernetes アクセスを民主化します。K3s と vCluster を活用することで、個人開発者から大規模組織まで対応する本番環境対応プラットフォームを提供し、ネイティブ Kubernetes の柔軟性とパワーを維持します。

オープンソースの性質により、透明性、コミュニティ主導のイノベーション、特定要件に対するカスタマイズ能力が保証されます。シンプルな Helm ベースのインストールと包括的な監視により、Hexabase AI はアクセス可能な Kubernetes プラットフォームの新しい標準を表しています。