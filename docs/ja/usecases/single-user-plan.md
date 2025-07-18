# シングルユーザープランシナリオ

このユースケースでは、Hexabase.AI を個人開発者が利用する場合の流れを示しています。個人開発者向けに2つのプランを提供しています（個人プロジェクトと学習用の **Hobby プラン**、専用リソースが必要な本番ワークロード用の **Pro プラン**）

## 目的

シングルユーザープランの目的は、個人開発者がアプリケーションを構築・テスト・デプロイするための、強力でコスト効率が高く、信頼性のあるプラットフォームを提供することです。インフラ管理の複雑さを意識せずに、個人プロジェクト、フリーランス業務、新規スタートアップのプロトタイピングなどに最適です。

### 1. IdPでHexabase.AIに初回ログインする

- 開発者はIdP（Google、GitHub等）を使用してログインを行います。
- システムは初回ログインを検出すると、個人用の組織を作成します。

### 2. 初回ログイン後のワークスペースセットアップ

- システムはワークスペース未作成のユーザを検出すると、ワークスペースの作成を案内する画面を表示します
- このワークスペースは完全に隔離された環境で、開発者専用のプライベートKubernetesネームスペースが割り当てられます。
- ワークスペースのセットアップ完了後、ダッシュボードやCLIから利用可能なリソースやクォータを確認できます。

### 3. アプリケーションのデプロイ

- 開発者のアプリケーションは、さまざまな構成が可能です（例：Node.js バックエンドと React フロントエンドなど）
- HKS CLI を使用して、開発者はアプリケーションコンテナを**共有ノードプール**にデプロイします。これは開発とステージングに最適なコスト効率の高いオプションです。
- データベースが必要な場合、HKS マーケットプレイスから PostgreSQL インスタンスをプロビジョニングできます。これは永続ストレージボリュームを使用します。プランには限定量の高速ストレージが含まれています。

### 4. CI/CD のセットアップ

- 開発者は個人の GitHub リポジトリをプロジェクトに接続します。
- テンプレートを使用してシンプルな CI/CD パイプラインを設定します：
  - `git push` のたびに、パイプラインは自動的にコンテナイメージをビルドします。
  - ユニットテストを実行します。
  - ワークスペース内のステージング環境に新しいバージョンをデプロイします。

### 5. サーバーレスとスケジュールジョブの活用

- 毎日のサマリーメール送信などのタスクを処理するために、開発者は1日1回サーバーレス **Function** をトリガーする **CronJob** を作成します。
- Function にはビジネスロジックが含まれており、スケジュールされたタスクを実行する非常に効率的な方法です。

### 6. AIOps アシスタンス

- アプリケーションがパフォーマンスの問題を経験した場合、統合された **AIOps アシスタント**が異常（メモリリークなど）を検出できます。
- 詳細なレポートと修正の提案を含む Slack 通知で開発者に積極的に通知でき、トラブルシューティングの時間を節約します。
- このプランの AIOps 機能は、コア監視と異常検出に焦点を当てています。

### 7. スケールアップ：専用ノード

- アプリケーションが本番環境の準備ができると、より多くのパフォーマンスとリソース保証が必要になる場合があります。
- 開発者は**専用ノード**を含むようにプランをアップグレードできます。
- UI から、新しい専用ノードがプロビジョニングされ、ワークスペースに追加され、より高いパフォーマンスと分離のために本番デプロイメントを移動できます。

## 機能の概要

### Hobby プランの機能

| 機能               | Hobby プランの使用                       |
| :----------------- | :--------------------------------------- |
| **組織**           | 1つの隔離された個人用組織                |
| **ワークスペース** | 1つの隔離された個人用ワークスペース      |
| **ノード**         | 共有ノードプールのみ                     |
| **CI/CD**          | 基本的なテンプレートベースのパイプライン |
| **Functions**      | 最大5つのサーバーレス関数                |
| **CronJobs**       | 最大10個のスケジュールジョブ             |
| **ストレージ**     | 10GB の永続ストレージ                    |
| **AIOps**          | 基本的な監視とアラート                   |
| **サポート**       | コミュニティサポート                     |

## Pro プランの機能

プロジェクトを本番環境に移行する準備ができたら、Pro プランにアップグレードして拡張機能を利用できます：

| 機能               | Pro プランの使用                                              |
| :----------------- | :------------------------------------------------------------ |
| **組織**           | 1つの隔離された個人用組織                                     |
| **ワークスペース** | 本番グレードの分離を備えた1つの個人ワークスペース             |
| **ノード**         | 専用ノード1台含む（アップグレード可能）                       |
| **CI/CD**          | 並列ビルドを備えた高度なパイプライン                          |
| **Functions**      | 無制限のサーバーレス関数                                      |
| **CronJobs**       | 無制限のスケジュールジョブ                                    |
| **ストレージ**     | 100GB の高性能 SSD ストレージ                                 |
| **AIOps**          | フル AIOps スイート：異常検出、予測スケーリング、コスト最適化 |
| **バックアップ**   | 7日間保持の自動日次バックアップ                               |
| **サポート**       | 24時間応答の優先メールサポート                                |
| **SLA**            | 99.9% アップタイム保証                                        |

### Hobby から Pro へのアップグレード

アップグレードプロセスはシームレスです：

1. ダッシュボードで「Pro にアップグレード」をクリック
2. 既存のワークロードは中断なく実行を続けます
3. 専用ノードが数分以内にプロビジョニングされます
4. パフォーマンス向上のために重要なワークロードを専用ノードに移行
5. 拡張機能とサポートをすぐに利用開始
