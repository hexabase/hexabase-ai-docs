# オンプレミス展開

## 概要

Hexabase.AI オンプレミス展開により、組織は AI 指向の Kubernetes プラットフォーム全体を自社のデータセンター内で実行でき、最大限の制御、セキュリティ、コンプライアンス機能を提供します。この展開モデルは、厳格なデータ主権要件、規制制約、またはオンプレミスインフラストラクチャを義務付けるセキュリティポリシーを持つ組織に最適です。

## 前提条件

### ハードウェア要件

#### 最小構成

**コントロールプレーンノード（HA用に3ノード推奨）**：
- **CPU**: ノードあたり8コア
- **RAM**: ノードあたり32 GB
- **ストレージ**: ノードあたり500 GB SSD
- **ネットワーク**: 10 Gbps ネットワークインターフェース

**ワーカーノード（最小3ノード）**：
- **CPU**: ノードあたり16コア
- **RAM**: ノードあたり64 GB
- **ストレージ**: ノードあたり1 TB NVMe SSD
- **ネットワーク**: 10 Gbps ネットワークインターフェース

#### 推奨本番構成

**コントロールプレーンノード（3ノード）**：
- **CPU**: ノードあたり16コア
- **RAM**: ノードあたり64 GB
- **ストレージ**: ノードあたり1 TB NVMe SSD
- **ネットワーク**: 25 Gbps ネットワークインターフェース

**ワーカーノード（5+ノード）**：
- **CPU**: ノードあたり32コア
- **RAM**: ノードあたり128 GB
- **ストレージ**: ノードあたり2 TB NVMe SSD + 独立ストレージネットワーク
- **ネットワーク**: 25 Gbps ネットワークインターフェース

**GPU ノード（AI ワークロード用）**：
- **CPU**: ノードあたり32コア
- **RAM**: ノードあたり256 GB
- **GPU**: NVIDIA A100 または H100 シリーズ
- **ストレージ**: ノードあたり4 TB NVMe SSD
- **ネットワーク**: 100 Gbps ネットワークインターフェース

### ソフトウェア要件

#### オペレーティングシステム
- **Ubuntu**: 22.04 LTS 以降
- **RHEL/CentOS**: 8.x 以降
- **SUSE Linux**: 15.x 以降

#### 必要なソフトウェア
- **Docker**: 24.0+ または containerd 1.7+
- **Kubernetes**: 1.28+（K3s経由でインストール）
- **Helm**: 3.12+
- **PostgreSQL**: 15+（外部可）
- **Redis**: 7.0+（外部可）

### ネットワーク要件

#### ネットワークトポロジー
```
┌─────────────────────────────────────┐
│         DMZ ネットワーク             │
│    (ロードバランサー, Ingress)      │
└─────────────┬───────────────────────┘
              │
┌─────────────┴───────────────────────┐
│      管理ネットワーク               │
│   (コントロールプレーン, 監視)      │
└─────────────┬───────────────────────┘
              │
┌─────────────┴───────────────────────┐
│      クラスターネットワーク         │
│    (ワーカーノード, ストレージ)     │
└─────────────────────────────────────┘
```

#### 必要なポート

**コントロールプレーン**：
- **6443**: Kubernetes API サーバー
- **2379-2380**: etcd
- **10250**: kubelet
- **10259**: kube-scheduler
- **10257**: kube-controller-manager

**ワーカーノード**：
- **10250**: kubelet
- **30000-32767**: NodePort サービス
- **179**: BGP（Calico使用時）

**Hexabase.AI 専用**：
- **8080**: Hexabase.AI API
- **5432**: PostgreSQL
- **6379**: Redis
- **4222**: NATS

## インストールガイド

### フェーズ1: インフラストラクチャ準備

#### 1. 物理インフラストラクチャの準備

```bash
# 冗長性のためのネットワークボンディング設定
sudo modprobe bonding
echo "alias bond0 bonding" >> /etc/modprobe.conf

# ネットワーク設定のセットアップ
cat > /etc/netplan/01-network.yaml << EOF
network:
  version: 2
  bonds:
    bond0:
      interfaces: [enp1s0, enp2s0]
      parameters:
        mode: 802.3ad
        mii-monitor-interval: 100
      addresses: [192.168.1.10/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

sudo netplan apply
```

#### 2. ストレージの設定

```bash
# 分散ストレージ用のCephクラスターセットアップ
# cephadmのインストール
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
sudo ./cephadm add-repo --release quincy
sudo ./cephadm install

# Cephクラスターのブートストラップ
sudo cephadm bootstrap --mon-ip 192.168.1.10
```

### フェーズ2: Kubernetes クラスターインストール

#### 1. K3s コントロールプレーンのインストール

```bash
# 最初のコントロールプレーンノードで
curl -sfL https://get.k3s.io | sh -s - server \
  --cluster-init \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --node-ip=192.168.1.10 \
  --cluster-cidr=10.42.0.0/16 \
  --service-cidr=10.43.0.0/16 \
  --flannel-backend=none

# ノードトークンの取得
sudo cat /var/lib/rancher/k3s/server/node-token
```

#### 2. 追加のコントロールプレーンノードの参加

```bash
# 追加のコントロールプレーンノードで
curl -sfL https://get.k3s.io | sh -s - server \
  --server https://192.168.1.10:6443 \
  --token <NODE_TOKEN> \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --node-ip=192.168.1.11

# コントロールプレーンノード3でIP 192.168.1.12を使用して繰り返し
```

### フェーズ3: Hexabase.AI プラットフォームインストール

#### 1. PostgreSQL のインストール

```bash
# PostgreSQL デプロイメントの作成
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgresql bitnami/postgresql \
  --set auth.postgresPassword=hexabase-secure-password \
  --set auth.database=hexabase \
  --set primary.persistence.size=100Gi \
  --namespace hexabase-system \
  --create-namespace
```

#### 2. Hexabase.AI プラットフォームのインストール

```bash
# Hexabase.AI Helmリポジトリの追加
helm repo add hexabase https://charts.hexabase.ai
helm repo update

# Hexabase.AI のインストール
helm install hexabase hexabase/hexabase-ai \
  --namespace hexabase-system
```

## インストール後の設定

### 1. Hexabase.AI の初期化

```bash
# 管理者認証情報の取得
kubectl get secret hexabase-admin-credentials \
  -n hexabase-system \
  -o jsonpath='{.data.username}' | base64 -d

# プラットフォームへのアクセス
echo "https://hexabase.example.com"
```

### 2. 組織とワークスペースの設定

```bash
# Hexabase CLI を使用した初期設定
curl -L https://github.com/hexabase/cli/releases/latest/download/hb-linux-amd64.tar.gz | tar xz
sudo mv hb /usr/local/bin/

# 組織の作成
hb organization create "マイエンタープライズ" \
  --plan enterprise \
  --admin-email admin@example.com
```

## 監視とメンテナンス

### ヘルスチェック

```bash
# クラスターヘルスの確認
kubectl get nodes
kubectl get pods -A
kubectl top nodes
kubectl top pods -A

# Hexabase.AI 専用コンポーネントの確認
kubectl get pods -n hexabase-system
kubectl logs -f deployment/hexabase-api -n hexabase-system
```

### 定期メンテナンスタスク

#### 週次タスク
- システムログのエラー確認
- リソース使用率の確認
- バックアップ完了の確認
- セキュリティパッチの更新

#### 月次タスク
- 認証情報の確認とローテーション
- キャパシティプランニング評価
- パフォーマンス最適化
- セキュリティ脆弱性スキャン

## トラブルシューティング

### 一般的な問題

#### 1. ポッドスケジューリングの問題
```bash
# ノードリソースの確認
kubectl describe nodes

# テイントと許容の確認
kubectl describe node <node-name>
```

#### 2. ストレージの問題
```bash
# Cephクラスターヘルスの確認
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph status

# PVC ステータスの確認
kubectl get pvc -A
kubectl describe pvc <pvc-name>
```

## セキュリティ考慮事項

### 1. エアギャップ展開

最大のセキュリティのため、Hexabase.AI は完全にエアギャップされた環境に展開できます：

```bash
# ローカルコンテナレジストリの作成
docker run -d -p 5000:5000 --name registry registry:2

# Hexabase.AI イメージのローカルレジストリへのプッシュ
docker tag hexabase/api:v1.0.0 localhost:5000/hexabase/api:v1.0.0
docker push localhost:5000/hexabase/api:v1.0.0
```

### 2. ハードウェアセキュリティモジュール統合

```bash
# キー管理用のHSM設定
cat > hsm-config.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: hsm-config
  namespace: hexabase-system
type: Opaque
data:
  hsm-endpoint: <base64-encoded-endpoint>
  hsm-token: <base64-encoded-token>
EOF

kubectl apply -f hsm-config.yaml
```

## 関連トピック

- [エンタープライズプラン機能](./enterprise-plan.md) - 完全なエンタープライズ機能
- [RBAC設定](../rbac/index.md) - ロールベースアクセス制御設定
- [RBAC設定](../rbac/index.md) - ロールベースアクセス制御設定
- [アプリケーション管理](../applications/index.md) - アプリケーションデプロイメントガイド