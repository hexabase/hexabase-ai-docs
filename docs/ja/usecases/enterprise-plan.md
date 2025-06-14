# エンタープライズプランシナリオ

**エンタープライズプラン**は Hexabase.AI のプレミアオファリングであり、厳格なセキュリティ、コンプライアンス、スケーラビリティ、ガバナンス要件を持つ大規模組織向けに設計されています。このユースケースでは、大企業がプラットフォームの全機能を活用する方法を説明します。

## 目標

エンタープライズプランの目標は、大規模組織に高度に安全で、コンプライアンスに準拠し、スケーラブルで統制可能なプラットフォームを提供することです。金融や医療などのセキュリティ要件が厳しい企業、マルチリージョンデプロイメント、詳細なコスト管理、包括的な監査機能を必要とする企業向けに設計されています。

### 1. 集中ガバナンスと組織

- 企業は Hexabase.AI 上に中央組織を設定します。
- シームレスで安全なユーザー認証のために、既存のシングルサインオン（SSO）プロバイダー（Okta や Azure AD など）を統合します。
- 内部の企業構造に直接マッピングされるカスタムロールとポリシーを使用した、きめ細かい RBAC モデルを実装します。

### 2. ワークスペースとコスト管理

- 中央 IT 部門は、異なる事業部門用に複数のワークスペースを作成します（例：`Finance-BU`、`Healthcare-Analytics`、`Retail-Apps`）。
- エンタープライズの主要機能は**予算計画**です。各ワークスペースに特定の予算とリソースクォータを割り当てます。
- プラットフォームは詳細なコスト配分レポートを提供し、組織は事業部門、プロジェクト、または特定のラベルごとに支出を追跡でき、財務ガバナンスにとって重要です。

### 3. 妥協のないセキュリティとコンプライアンス

- **完全な監査ログ**：エンタープライズプランは、長期保持を備えた包括的で不変の監査ログを提供します。すべてのアクションがログに記録され、SIEM（セキュリティ情報イベント管理）システムにエクスポートできます。
- **コンプライアンスパック**：企業は関連するワークスペースに PCI-DSS と HIPAA 用の事前構築されたコンプライアンスパックを適用し、これらの標準に必要なセキュリティポリシーと構成を自動的に実施します。
- **プライベートネットワーキング**：機密データを扱うワークスペースは、専用 VPN ゲートウェイを介してオンプレミスデータセンターに接続され、安全でプライベートなトラフィックを確保します。

### 4. 高度なスケーラビリティと信頼性

- **スケールアウトプラン**：プラットフォームはマルチリージョンおよびマルチクラウドデプロイメント用に構成されています。金融事業部門のミッションクリティカルなアプリケーションは、最大の可用性のために 2 つの異なるクラウドプロバイダー間でアクティブ-アクティブで実行できます。
- **高度なバックアップと DR**：企業は、データベースのポイントインタイムリカバリ、アプリケーション対応のバックアップポリシー、自動災害復旧計画テストを可能にする高度なバックアップ戦略を設計します。

### 5. フル機能の AIOps

- エンタープライズプランは、プラットフォームの完全な **AIOps スイート**を解き放ちます：
  - **予測スケーリング**：AIOps エンジンは履歴トレンドを分析してトラフィックスパイク（金融アプリの市場開始時など）を予測し、先制的にリソースをスケールします。
  - **自動根本原因分析**：問題が発生すると、AIOps アシスタントは問題を特定するだけでなく、それを引き起こした特定のコードコミットまたはインフラストラクチャの変更まで問題を追跡します。
  - **セキュリティ脅威検出**：AI は、異常な API アクセスパターンやデータの外部流出の試みなど、セキュリティ脅威を示す可能性のある異常な動作を継続的に監視します。

### 6. カスタム契約とサポート

- 企業は予算サイクルに合わせた固定価格モデルで**特別契約**を結ぶことができます。
- また、専任のテクニカルアカウントマネージャー（TAM）と 24 時間 365 日のプレミアムサポート SLA を受け、専門家のヘルプが常に利用可能です。

## 使用機能の概要

| 機能                  | エンタープライズプランの使用                                                       |
| :-------------------- | :--------------------------------------------------------------------------------- |
| **ガバナンス**        | SSO 統合、カスタム RBAC、集中ポリシー管理                                          |
| **コスト管理**        | ワークスペースごとの予算計画、詳細なコスト配分、固定価格契約                       |
| **監査ログ**          | 長期保持と SIEM 統合を備えた完全で不変の監査ログ                                   |
| **セキュリティ**      | コンプライアンスパック（PCI、HIPAA）、プライベートネットワーキング、高度な脅威検出 |
| **スケーラビリティ**  | 自動スケールアウトプランを備えたマルチリージョン、マルチクラウドデプロイメント     |
| **バックアップと DR** | 高度なアプリケーション対応のバックアップ戦略と自動 DR テスト                       |
| **AIOps**             | 予測スケーリング、自動根本原因分析、AI 駆動セキュリティを含むフルスイート          |
| **サポート**          | 専任 TAM、プレミアムサポート、カスタム SLA                                         |
