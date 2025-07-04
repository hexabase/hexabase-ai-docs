# Hexabase KaaSサービス サービス提供範囲と責任分界点

Hexabase KaaS（Kubernetes as a Service）は、Kubernetesと完全互換性を持ちながら、専門知識がない方でも直感的に操作できるUIと補助機能により、コンテナアプリケーションの運用を容易にするプラットフォームです。
本ドキュメントでは、Hexabase KaaSをご利用いただく上での、弊社（Hexabase）とお客様との間のサービス提供範囲と責任分界点を明確にすることを目的とします。

## 1. 責任分界点の概要

Hexabase KaaSにおける責任範囲は、一般的なクラウドサービスの責任共有モデルに準じます。以下の表は、サービス提供形態ごとの責任の所在をまとめたものです。

| レイヤー | 内容 | KaaS版 | 他社クラウド版 | オンプレミス版 |
| :--- | :--- | :---: | :---: | :---: |
| **アプリケーション** | アプリケーション本体、データ、セキュリティ対策、コンテナイメージ管理 | **お客様** | **お客様** | **お客様** |
| **Kubernetes基盤** | コンテナオーケストレーション、監視・ログ機能、リソース管理、アクセス制御 | **Hexabase** | **Hexabase** | **Hexabase** |
| **仮想インフラ** | 仮想マシン、仮想ネットワーク、仮想ストレージ | **Hexabase** | **お客様 (※1)** | **お客様 (※1)** |
| **物理インフラ** | 物理サーバー、ネットワーク機器、データセンター | **Hexabase** | **お客様 (※1)** | **お客様 (※1)** |

---
**(※1) 他社クラウド版・オンプレミス版のインフラについて**

* **他社クラウド版:** お客様がご契約のクラウドサービス（AWS, Azure, GCPなど）のアカウント、およびその上で動作するKubernetes（EKS, AKS, GKEなど）の管理責任はお客様にあります。
* **オンプレミス版:** お客様が保有する物理サーバーや仮想化基盤（Proxmoxなど）の管理責任はお客様にあります。

**【構築・運用支援】**
上記(※1)の範囲について、Hexabase社による**初期構築サービス**や**マネージド・サービス**を別途ご契約いただくことで、Hexabase社が構築や運用を代行することも可能です。詳細については個別にご相談ください。

---

## 2. 各レイヤーにおける責任分界点の詳細

### 2.1. アプリケーションレイヤー（お客様の責任範囲）

Hexabaseは、お客様のアプリケーションを動作させるための強力なプラットフォームと機能を提供しますが、アプリケーションそのものの管理責任は負いません。

| 項目 | お客様の責任範囲 |
| :--- | :--- |
| **アプリケーションの動作保証** | お客様が開発・デプロイしたアプリケーションの正常な動作、パフォーマンス、品質の担保。 |
| **アプリケーションのセキュリティ** | アプリケーションコードの脆弱性対策、適切なライブラリの使用、コンテナイメージの脆弱性スキャンと対策。 |
| **データのバックアップと復旧** | データベースやファイルなど、アプリケーションが利用する永続データのバックアップ計画の策定、定期的な実行、および障害発生時のお客様自身によるデータ復旧作業。 |
| **コンテナイメージのアップデート** | アプリケーションの機能追加やバグ修正、セキュリティパッチが適用された新しいコンテナイメージをお客様自身で準備し、デプロイ（最新化）すること。 |

### 2.2. Kubernetesプラットフォームレイヤー（Hexabaseの責任範囲）

Hexabaseは、お客様がアプリケーションの運用に集中できるよう、複雑なKubernetes環境の管理・運用を責任を持って行います。

| 項目 | Hexabaseの提供範囲 |
| :--- | :--- |
| **コンテナオーケストレーション** | コンテナの自動デプロイ、スケーリング、およびライフサイクル管理機能の提供。 |
| **リソース管理と最適化** | コンテナが必要とするCPU、メモリ、ストレージ等のリソースを効率的に管理・最適化する機能の提供。 |
| **プラットフォームの監視とロギング** | Kubernetesクラスタおよびコンテナの稼働状況やパフォーマンスを監視し、ログを収集・分析するための統合的な機能を提供。 |
| **ネットワークとストレージ管理** | コンテナ間の安全な通信を実現するネットワーク機能や、データの永続化を行うストレージ機能の提供。 |
| **セキュリティとコンプライアンス** | Kubernetesクラスタ自体のセキュリティ維持、アクセス制御、ネットワークポリシー、マルチテナント環境におけるリソース分離機能の提供。 |
| **プラットフォームのアップデート** | Kubernetes本体のバージョンアップやセキュリティパッチの適用といった、プラットフォームのメンテナンス。 |
| **VM/コンテナ統合管理** | Kubernetes上で仮想マシン（VM）とコンテナを一元的に管理できる機能の提供。 |
| **サポートとドキュメント** | お客様がサービスを円滑に利用するための技術サポート、および各種ドキュメントの提供。 |

### 2.3. インフラストラクチャーレイヤー（提供形態により分担）

インフラ層の責任分界点は、お客様が選択する提供形態によって異なります。

#### **KaaS版をご利用の場合（Hexabaseの責任範囲）**
物理サーバー、ネットワーク、ストレージ、およびそれらを仮想化する基盤の全てを、Hexabaseがフルマネージドで提供します。お客様はインフラの存在を意識することなく、サーバーレス感覚でサービスをご利用いただけます。

#### **他社クラウド版・オンプレミス版をご利用の場合（お客様の責任範囲）**
前述の通り、基盤となるクラウド環境やオンプレミスの物理/仮想環境の構築・管理・運用はお客様の責任範囲となります。Hexabase KaaSは、その上で動作するプラットフォームとしてサービスを提供します。