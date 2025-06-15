# Kubernetes RBAC

セキュアなマルチテナント Kubernetes 運用のために、Hexabase.AI がロールベースアクセス制御（RBAC）をどのように実装・管理するかを学びます。

## 概要

Hexabase.AI は、マルチテナンシー、簡素化された管理、強化されたセキュリティのための追加機能を備えた Kubernetes ネイティブ RBAC を拡張する洗練された RBAC システムを提供します。私たちの RBAC 実装により、ユーザーは必要な権限のみを取得できます—多すぎず、少なすぎません。

## RBAC コンポーネント

<div class="grid cards" markdown>

- :material-account-key:{ .lg .middle } **ロールと権限**

  ***

  事前定義されたロールとカスタム権限モデルを理解

  [:octicons-arrow-right-24: ロールを探索](hexabase-rbac.md)

- :material-account-group:{ .lg .middle } **ユーザー管理**

  ***

  ユーザー、グループ、サービスアカウントの管理

  [:octicons-arrow-right-24: ユーザー管理ガイド](kubernetes-rbac.md)

- :material-shield-check:{ .lg .middle } **ポリシー設定**

  ***

  アクセスポリシーの設定とカスタマイズ

  [:octicons-arrow-right-24: ポリシー設定](kubernetes-rbac.md)

- :material-book-open:{ .lg .middle } **ベストプラクティス**

  ***

  セキュリティベストプラクティスと一般的なパターン

  [:octicons-arrow-right-24: RBAC ベストプラクティス](best-practices.md)

</div>

## RBAC モデル

Hexabase.AI は、きめ細かいアクセス制御を提供する階層 RBAC モデルを実装しています：

```
組織
├── 組織ロール（Admin、Viewer）
└── ワークスペース
    ├── ワークスペースロール（Owner、Developer、Viewer）
    └── プロジェクト
        └── Kubernetes RBAC（ネイティブロール）
```

### 主要機能

#### 1. マルチレベル権限

- **組織レベル**: ワークスペースの作成と請求管理の制御
- **ワークスペースレベル**: プロジェクトデプロイメントとリソースクォータの管理
- **プロジェクトレベル**: きめ細かい Kubernetes 権限

#### 2. 事前定義ロール

- **組織管理者**: 組織の完全制御
- **ワークスペース所有者**: ワークスペース管理とプロジェクトデプロイ
- **開発者**: アプリケーションのデプロイと管理
- **閲覧者**: リソースへの読み取り専用アクセス

#### 3. カスタムロール

- 特定権限を持つカスタムロールの作成
- 複雑なシナリオ向けの複数権限の組み合わせ
- テンプレートベースのロール作成

#### 4. 動的権限継承

- 組織からワークスペースへの権限のカスケード
- 下位レベルでの継承権限のオーバーライド
- 自動権限伝播

## 一般的な RBAC シナリオ

### シナリオ 1: 開発チームセットアップ

```yaml
チーム構造:
  - チームリーダー: ワークスペース所有者
  - 開発者: デプロイ権限を持つ開発者ロール
  - QA エンジニア: ログアクセスを持つ閲覧者ロール
  - CI/CD サービス: デプロイ権限を持つサービスアカウント
```

### シナリオ 2: マルチ環境アクセス

```yaml
環境セットアップ:
  - 本番: シニア開発者と SRE に限定
  - ステージング: すべての開発者にオープン
  - 開発: すべてのチームメンバーのセルフサービス
```

### シナリオ 3: クライアントアクセス

```yaml
外部アクセス:
  - クライアント関係者: 特定ワークスペースの閲覧者ロール
  - 請負業者: 期間限定の開発者アクセス
  - 監査担当者: 監査ログ可視性を持つ読み取り専用アクセス
```

## セキュリティ考慮事項

### 最小権限の原則

- ユーザーは必要最小限の権限を取得
- 定期的な権限監査
- 自動権限クリーンアップ

### 職務分離

- デプロイと承認の異なるロール
- 独立した本番アクセス制御
- すべての権限変更の監査証跡

### 多層防御

- 複数のアクセス制御レイヤー
- ネットワークポリシーが RBAC を補完
- リソースクォータが悪用を防止

## クイックスタート例

### 開発者アクセスの付与

```bash
hks rbac grant-role developer user@example.com --workspace my-workspace
```

### カスタムロールの作成

```bash
hks rbac create-role custom-deployer \
  --permissions deploy,view-logs,manage-secrets \
  --workspace my-workspace
```

### ユーザー権限の表示

```bash
hks rbac list-permissions user@example.com
```

## Kubernetes との統合

Hexabase.AI RBAC はネイティブ Kubernetes RBAC とシームレスに統合されます：

1. **自動変換**: プラットフォームロールが Kubernetes ロールにマップ
2. **サービスアカウント管理**: 自動サービスアカウント作成
3. **Namespace 分離**: RBAC ポリシーが namespace 境界を強制
4. **監査コンプライアンス**: コンプライアンスのためにすべてのアクションをログ

## 次のステップ

- **RBAC が初めてですか？** [ロールと権限](hexabase-rbac.md) から始めましょう
- **ユーザーをセットアップしますか？** [ユーザー管理ガイド](kubernetes-rbac.md) に従ってください
- **カスタムポリシーが必要ですか？** [ポリシー設定](kubernetes-rbac.md) について学習してください
- **セキュリティ重視ですか？** [RBAC ベストプラクティス](best-practices.md) をレビューしてください

## 関連ドキュメント

- [セキュリティアーキテクチャ](../architecture/security-architecture.md)
- [コアコンセプト](../concept/index.md)
- [API 認証](../api/authentication.md)
- [監査ログ](../security/compliance.md#audit-logs-for-compliance)