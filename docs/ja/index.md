# Hexabase.AI ドキュメントへようこそ

**AI指向Kubernetes as a Service** - AI アプリケーションとエージェントを知能的な自動化でデプロイ、スケール、管理

## はじめに

<div class="grid cards" markdown>

- :material-brain:{ .lg .middle } **AI 開発者**

  ***

  AI アプリケーションとエージェントを本番対応の Kubernetes に高速デプロイ

  [:octicons-arrow-right-24: 開発を始める](concept/index.md)

- :material-account-group:{ .lg .middle } **チーム**

  ***

  ワークスペース分離で専用インフラストラクチャ上での AI ワークロードの協業とスケール

  [:octicons-arrow-right-24: チームセットアップ](../rbac/index.md)

- :material-office-building:{ .lg .middle } **エンタープライズ**

  ***

  完全な制御とコンプライアンスによるプライベート・オンプレミス AI インフラストラクチャのデプロイ

  [:octicons-arrow-right-24: エンタープライズガイド](../nodes/index.md)

- :material-rocket-launch:{ .lg .middle } **クイックスタート**

  ***

  ガイド付きセットアップで数分で最初の AI アプリケーションを実行

  [:octicons-arrow-right-24: クイックデプロイ](../applications/index.md)

</div>

## プラットフォームの機能

<div class="grid cards" markdown>

- :material-book-open-variant:{ .lg .middle } **コアコンセプト**

  ***

  Hexabase.AI の基本概念を理解します

  [:octicons-arrow-right-24: コンセプトを学ぶ (日本語)](concept/index.md)

- :material-briefcase:{ .lg .middle } **ユースケース**

  ***

  組織が Hexabase.AI をどのように使用しているかを探ります

  [:octicons-arrow-right-24: ユースケースを見る (English)](../usecases/index.md)

- :material-sitemap:{ .lg .middle } **アーキテクチャ**

  ***

  技術的なアーキテクチャを深く掘り下げます

  [:octicons-arrow-right-24: アーキテクチャドキュメント (English)](../architecture/index.md)

- :material-shield-lock:{ .lg .middle } **RBAC**

  ***

  ロールベースのアクセス制御とセキュリティ

  [:octicons-arrow-right-24: RBAC ガイド (English)](../rbac/index.md)

</div>

## 高度な機能

<div class="grid cards" markdown>

- :material-clock-outline:{ .lg .middle } **CronJobs**

  ***

  定期的なタスクをスケジュールおよび管理します

  [:octicons-arrow-right-24: CronJobs ガイド (English)](../cronjobs/index.md)

- :material-function:{ .lg .middle } **Functions**

  ***

  Kubernetes 上でサーバーレス関数をデプロイします

  [:octicons-arrow-right-24: Functions ドキュメント (English)](../functions/index.md)

- :material-chart-line:{ .lg .middle } **オブザーバビリティ**

  ***

  アプリケーションの監視、ログ記録、トレースを行います

  [:octicons-arrow-right-24: オブザーバビリティプラットフォーム (English)](../observability/index.md)

- :material-brain:{ .lg .middle } **AIOps**

  ***

  AI を活用した運用と自動化

  [:octicons-arrow-right-24: AIOps 機能 (English)](../aiops/index.md)

</div>

## 開発者向けリソース

<div class="grid cards" markdown>

- :material-translate:{ .lg .middle } **言語切り替え**

  ***

  英語版ドキュメントに切り替える

  [:octicons-arrow-right-24: English Documentation](../index.md)

- :material-api:{ .lg .middle } **API リファレンス**

  ***

  自動生成API ドキュメント（準備中）

  [:octicons-arrow-right-24: API リファレンス](https://api.hexabase.ai/docs)

</div>

## Hexabase.AI とは？

Hexabase.AI (HKS) は、AI アプリケーションとエージェントを構築する開発者向けに特別に設計された **AI指向Kubernetes as a Service プラットフォーム**です。CNCF オープンソース標準に基づいて構築され、AI ワークロードパターンを理解する知能的な自動化、監視、スケーリング機能を提供します。

### なぜ Hexabase.AI を選ぶのか？

- **AI ファーストデザイン**: AI アプリケーション、エージェント、機械学習ワークロードに最適化
- **即座の本番環境**: AI アプリケーションを数週間ではなく数分で本番環境にデプロイ
- **スマートスケーリング**: ワークロードパターンから学習する AI 駆動のリソース最適化
- **チーム協業**: きめ細かいアクセス制御を備えたマルチテナントワークスペース
- **エンタープライズ対応**: 完全なコンプライアンスと制御を備えたプライベート・オンプレミスデプロイ
- **オープン標準**: CNCF OSS に基づく構築 - ベンダーロックインなし、馴染みのあるツールを使用

### 最適な対象者

- LLM、ML モデル、AI エージェントを使用してアプリケーションをコーディングする **AI 開発者**
- DevOps のオーバーヘッドなしに迅速でスケーラブルな AI インフラストラクチャが必要な **スタートアップ**
- 異なる AI プロジェクトと実験のための分離された環境が必要な **チーム**
- ガバナンスとコンプライアンスを備えたプライベート AI インフラストラクチャが必要な **エンタープライズ**

## アーキテクチャと技術

Hexabase.AI は実績のある CNCF オープンソース技術に基づいて構築されており、信頼性、スケーラビリティ、ベンダー独立性を保証します：

- **Kubernetes**: コンテナオーケストレーションの基盤
- **Prometheus & Grafana**: 監視とオブザーバビリティスタック
- **OpenTelemetry**: 分散トレーシングとメトリクス収集
- **Proxmox**: 専用ノード管理のための仮想化
- **AI オペレーション**: Python ベースの知能的自動化エンジン

## クイックリンク

<div class="grid cards" markdown>

- **開発**

  ***

  - [プラットフォームコンセプト](concept/index.md)
  - [API リファレンス](https://api.hexabase.ai/docs)（自動生成）
  - [CLI ツールドキュメント](https://github.com/hexabase/cli/blob/main/README.md)

- **リソース**

  ***

  - [GitHub リポジトリ](https://github.com/KoribanDev/hexabase-ai)
  - [コミュニティサポート](https://community.hexabase.ai)
  - [リリースノート](https://github.com/KoribanDev/hexabase-ai/releases)

</div>

## サポート

お困りですか？こちらをご確認ください：

- [コミュニティフォーラム](https://community.hexabase.ai)
- [課題トラッカー](https://github.com/KoribanDev/hexabase-ai/issues)
- [サポートへのお問い合わせ](mailto:support@hexabase.ai)
