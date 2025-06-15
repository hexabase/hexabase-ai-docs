# コアコンセプト

Hexabase.AI のコアコンセプトセクションへようこそ。このガイドでは、Hexabase.AI を使用する際に理解しておく必要がある基本的な概念と用語を紹介します。

!!! info "リンク先について"
    以下のリンクは英語版ドキュメントに接続されています。

## 概要

Hexabase.AI は、強力なマルチテナントの Kubernetes as a Service プラットフォームを提供するために連携する、いくつかの重要な概念に基づいて構築されています。これらの概念を理解することは、プラットフォームを効果的に使用および管理するために不可欠です。

## 主な概念

<div class="grid cards" markdown>

- :material-domain:{ .lg .middle } **組織 (Organizations)**

  ***

  Hexabase.AI を使用する企業やチームを表すトップレベルのエンティティ

  [:octicons-arrow-right-24: 組織について学ぶ (English)](../../concept/multi-tenancy.md)

- :material-view-dashboard:{ .lg .middle } **ワークスペース (Workspaces)**

  ***

  組織内で、異なるチームやプロジェクトのために分離された環境

  [:octicons-arrow-right-24: ワークスペースについて学ぶ (English)](../../concept/multi-tenancy.md)

- :material-folder-multiple:{ .lg .middle } **プロジェクト (Projects)**

  ***

  アプリケーションと構成を含む、デプロイ可能な単位

  [:octicons-arrow-right-24: プロジェクトについて学ぶ (English)](../../concept/core-concepts.md)

- :material-kubernetes:{ .lg .middle } **クラスター (Clusters)**

  ***

  ワークロードを実行するために Hexabase.AI によって管理される Kubernetes クラスター

  [:octicons-arrow-right-24: クラスターについて学ぶ (English)](../../concept/technology-stack.md)

</div>

## マルチテナンシーモデル

Hexabase.AI は階層的なマルチテナンシーモデルを実装しています：

```
組織
└── ワークスペース
    └── プロジェクト
        └── リソース (Deployments, Services, etc.)
```

この構造は以下を提供します：

- **分離**: 異なる組織間の完全な分離
- **柔軟性**: 異なるチームや環境のための複数のワークスペース
- **セキュリティ**: 各レベルでのロールベースのアクセス制御
- **リソース管理**: ワークスペースごとのクォータと制限

## プラットフォームのコンポーネント

### コントロールプレーン

- プラットフォーム全体の運用を管理
- 認証と認可を処理
- クラスターのプロビジョニングと管理を調整

### データプレーン

- Kubernetes クラスターで実際のワークロードを実行
- コンピュート、ストレージ、ネットワーキングリソースを提供
- セキュリティポリシーとリソースクォータを実装

### AIOps エンジン

- リソース使用率とパフォーマンスを監視
- インテリジェントな推奨事項を提供
- 最適化とスケーリングの決定を自動化

## 次のステップ

- **Hexabase.AI は初めてですか？** トップレベルの構造を理解するために [組織 (English)](../../concept/multi-tenancy.md) から始めましょう
- **チームをセットアップしますか？** [ワークスペース (English)](../../concept/multi-tenancy.md) について学び、環境を整理する方法を学びましょう
- **デプロイの準備はできましたか？** [プロジェクト (English)](../../concept/core-concepts.md) を理解し、アプリケーションをパッケージ化する方法を学びましょう
- **インフラを管理しますか？** [クラスター (English)](../../concept/technology-stack.md) とその機能を探りましょう

## 関連ドキュメント

- [概要 (English)](../../concept/overview.md)
- [アーキテクチャ概要 (English)](../../architecture/index.md)
- [API リファレンス (English)](../../api/index.md)
