# On-Premise Deployment

## Overview

Hexabase.AI On-Premise deployment enables organizations to run the complete AI-oriented Kubernetes platform within their own data centers, providing maximum control, security, and compliance capabilities. This deployment model is ideal for organizations with strict data sovereignty requirements, regulatory constraints, or security policies that mandate on-premises infrastructure.

## Prerequisites

### Hardware Requirements

#### Minimum Configuration

**Control Plane Nodes (3 nodes recommended for HA)**:
- **CPU**: 8 cores per node
- **RAM**: 32 GB per node
- **Storage**: 500 GB SSD per node
- **Network**: 10 Gbps network interface

**Worker Nodes (minimum 3 nodes)**:
- **CPU**: 16 cores per node
- **RAM**: 64 GB per node
- **Storage**: 1 TB NVMe SSD per node
- **Network**: 10 Gbps network interface

#### Recommended Production Configuration

**Control Plane Nodes (3 nodes)**:
- **CPU**: 16 cores per node
- **RAM**: 64 GB per node
- **Storage**: 1 TB NVMe SSD per node
- **Network**: 25 Gbps network interface

**Worker Nodes (5+ nodes)**:
- **CPU**: 32 cores per node
- **RAM**: 128 GB per node
- **Storage**: 2 TB NVMe SSD per node + separate storage network
- **Network**: 25 Gbps network interface

**GPU Nodes (for AI workloads)**:
- **CPU**: 32 cores per node
- **RAM**: 256 GB per node
- **GPU**: NVIDIA A100 or H100 series
- **Storage**: 4 TB NVMe SSD per node
- **Network**: 100 Gbps network interface

### Software Requirements

#### Operating System
- **Ubuntu**: 22.04 LTS or later
- **RHEL/CentOS**: 8.x or later
- **SUSE Linux**: 15.x or later

#### Required Software
- **Docker**: 24.0+ or containerd 1.7+
- **Kubernetes**: 1.28+ (installed via K3s)
- **Helm**: 3.12+
- **PostgreSQL**: 15+ (can be external)
- **Redis**: 7.0+ (can be external)

### Network Requirements

#### Network Topology
```
┌─────────────────────────────────────┐
│         DMZ Network                 │
│    (Load Balancers, Ingress)       │
└─────────────┬───────────────────────┘
              │
┌─────────────┴───────────────────────┐
│      Management Network             │
│   (Control Plane, Monitoring)      │
└─────────────┬───────────────────────┘
              │
┌─────────────┴───────────────────────┐
│      Cluster Network               │
│    (Worker Nodes, Storage)         │
└─────────────────────────────────────┘
```

#### Required Ports

**Control Plane**:
- **6443**: Kubernetes API Server
- **2379-2380**: etcd
- **10250**: kubelet
- **10259**: kube-scheduler
- **10257**: kube-controller-manager

**Worker Nodes**:
- **10250**: kubelet
- **30000-32767**: NodePort services
- **179**: BGP (if using Calico)

**Hexabase.AI Specific**:
- **8080**: Hexabase.AI API
- **5432**: PostgreSQL
- **6379**: Redis
- **4222**: NATS

### Storage Requirements

#### Persistent Storage
- **Distributed Storage**: Rook/Ceph or similar
- **NFS**: For shared storage requirements
- **Local Storage**: NVMe SSDs for high-performance workloads

#### Backup Storage
- **Network Storage**: NAS or SAN for backup retention
- **Object Storage**: MinIO or external S3-compatible storage

## Installation Guide

### Phase 1: Infrastructure Preparation

#### 1. Prepare Physical Infrastructure

```bash
# Configure network bonding for redundancy
sudo modprobe bonding
echo "alias bond0 bonding" >> /etc/modprobe.conf

# Set up network configuration
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

#### 2. Configure Storage

```bash
# Set up Ceph cluster for distributed storage
# Install cephadm
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
sudo ./cephadm add-repo --release quincy
sudo ./cephadm install

# Bootstrap Ceph cluster
sudo cephadm bootstrap --mon-ip 192.168.1.10
```

#### 3. Load Balancer Setup

```bash
# Install and configure HAProxy for control plane HA
sudo apt update && sudo apt install -y haproxy

cat > /etc/haproxy/haproxy.cfg << EOF
global
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend kubernetes-frontend
    bind *:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    balance roundrobin
    server control1 192.168.1.10:6443 check
    server control2 192.168.1.11:6443 check
    server control3 192.168.1.12:6443 check

frontend hexabase-frontend
    bind *:8080
    mode tcp
    option tcplog
    default_backend hexabase-backend

backend hexabase-backend
    mode tcp
    balance roundrobin
    server api1 192.168.1.20:8080 check
    server api2 192.168.1.21:8080 check
    server api3 192.168.1.22:8080 check
EOF

sudo systemctl enable haproxy
sudo systemctl start haproxy
```

### Phase 2: Kubernetes Cluster Installation

#### 1. Install K3s Control Plane

```bash
# On first control plane node
curl -sfL https://get.k3s.io | sh -s - server \
  --cluster-init \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --node-ip=192.168.1.10 \
  --cluster-cidr=10.42.0.0/16 \
  --service-cidr=10.43.0.0/16 \
  --flannel-backend=none

# Get the node token
sudo cat /var/lib/rancher/k3s/server/node-token
```

#### 2. Join Additional Control Plane Nodes

```bash
# On additional control plane nodes
curl -sfL https://get.k3s.io | sh -s - server \
  --server https://192.168.1.10:6443 \
  --token <NODE_TOKEN> \
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --node-ip=192.168.1.11

# Repeat for control plane node 3 with IP 192.168.1.12
```

#### 3. Join Worker Nodes

```bash
# On worker nodes
curl -sfL https://get.k3s.io | sh -s - agent \
  --server https://192.168.1.10:6443 \
  --token <NODE_TOKEN> \
  --node-ip=192.168.1.20

# Configure kubectl on control plane
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
```

### Phase 3: Network and Storage Setup

#### 1. Install Calico CNI

```bash
# Install Calico for advanced networking
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

cat > calico-config.yaml << EOF
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: 10.42.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
EOF

kubectl apply -f calico-config.yaml
```

#### 2. Install Rook/Ceph Storage

```bash
# Install Rook operator
kubectl apply -f https://raw.githubusercontent.com/rook/rook/v1.12.3/deploy/examples/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/v1.12.3/deploy/examples/common.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/v1.12.3/deploy/examples/operator.yaml

# Create Ceph cluster
cat > ceph-cluster.yaml << EOF
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: rook-ceph
  namespace: rook-ceph
spec:
  cephVersion:
    image: quay.io/ceph/ceph:v17.2.6
  dataDirHostPath: /var/lib/rook
  skipUpgradeChecks: false
  continueUpgradeAfterChecksEvenIfNotHealthy: false
  waitTimeoutForHealthyOSDInMinutes: 10
  mon:
    count: 3
    allowMultiplePerNode: false
  mgr:
    count: 2
    allowMultiplePerNode: false
  dashboard:
    enabled: true
    ssl: true
  storage:
    useAllNodes: true
    useAllDevices: true
    config:
      osdsPerDevice: "1"
EOF

kubectl apply -f ceph-cluster.yaml
```

### Phase 4: Hexabase.AI Platform Installation

#### 1. Install PostgreSQL

```bash
# Create PostgreSQL deployment
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgresql bitnami/postgresql \
  --set auth.postgresPassword=hexabase-secure-password \
  --set auth.database=hexabase \
  --set primary.persistence.size=100Gi \
  --set primary.resources.requests.memory=8Gi \
  --set primary.resources.requests.cpu=2000m \
  --namespace hexabase-system \
  --create-namespace
```

#### 2. Install Redis

```bash
# Install Redis for caching and sessions
helm install redis bitnami/redis \
  --set auth.password=redis-secure-password \
  --set master.persistence.size=20Gi \
  --set replica.replicaCount=2 \
  --namespace hexabase-system
```

#### 3. Install NATS

```bash
# Install NATS for messaging
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats \
  --set config.cluster.enabled=true \
  --set config.cluster.replicas=3 \
  --namespace hexabase-system
```

#### 4. Install Hexabase.AI Platform

```bash
# Add Hexabase.AI Helm repository
helm repo add hexabase https://charts.hexabase.ai
helm repo update

# Create configuration values
cat > hexabase-values.yaml << EOF
global:
  environment: production
  
api:
  replicaCount: 3
  image:
    repository: hexabase/api
    tag: "v1.0.0"
  resources:
    requests:
      memory: 2Gi
      cpu: 1000m
    limits:
      memory: 4Gi
      cpu: 2000m

ui:
  replicaCount: 2
  image:
    repository: hexabase/ui
    tag: "v1.0.0"
  
postgres:
  host: postgresql.hexabase-system.svc.cluster.local
  database: hexabase
  username: postgres
  password: hexabase-secure-password

redis:
  host: redis-master.hexabase-system.svc.cluster.local
  password: redis-secure-password

nats:
  url: nats://nats.hexabase-system.svc.cluster.local:4222

storage:
  storageClass: rook-ceph-block

monitoring:
  enabled: true
  grafana:
    enabled: true
  prometheus:
    enabled: true

ingress:
  enabled: true
  hostname: hexabase.example.com
  tls:
    enabled: true
    secretName: hexabase-tls
EOF

# Install Hexabase.AI
helm install hexabase hexabase/hexabase-ai \
  --values hexabase-values.yaml \
  --namespace hexabase-system
```

### Phase 5: Security and SSL Configuration

#### 1. Install cert-manager

```bash
# Install cert-manager for TLS certificate management
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml

# Create Let's Encrypt ClusterIssuer
cat > letsencrypt-issuer.yaml << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

kubectl apply -f letsencrypt-issuer.yaml
```

#### 2. Configure Network Policies

```bash
# Create network policies for security
cat > network-policies.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: hexabase-api-policy
  namespace: hexabase-system
spec:
  podSelector:
    matchLabels:
      app: hexabase-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: hexabase-ui
    - podSelector:
        matchLabels:
          app: nginx-ingress
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
EOF

kubectl apply -f network-policies.yaml
```

## Post-Installation Configuration

### 1. Initialize Hexabase.AI

```bash
# Get admin credentials
kubectl get secret hexabase-admin-credentials \
  -n hexabase-system \
  -o jsonpath='{.data.username}' | base64 -d

kubectl get secret hexabase-admin-credentials \
  -n hexabase-system \
  -o jsonpath='{.data.password}' | base64 -d

# Access the platform
echo "https://hexabase.example.com"
```

### 2. Configure Organization and Workspaces

```bash
# Use Hexabase CLI to set up initial configuration
curl -L https://github.com/hexabase/cli/releases/latest/download/hks-linux-amd64.tar.gz | tar xz
sudo mv hb /usr/local/bin/

# Configure CLI
hb config init \
  --api-url https://hexabase.example.com \
  --username admin \
  --password <ADMIN_PASSWORD>

# Create organization
hb organization create "My Enterprise" \
  --plan enterprise \
  --admin-email admin@example.com

# Create workspace
hb workspace create production \
  --organization "My Enterprise" \
  --plan dedicated \
  --region on-premise
```

### 3. Backup Configuration

```bash
# Configure automated backups
cat > backup-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: backup-config
  namespace: hexabase-system
data:
  backup.yaml: |
    schedule: "0 2 * * *"  # Daily at 2 AM
    retention: "30d"
    destinations:
      - type: s3
        endpoint: backup.example.com
        bucket: hexabase-backups
        region: us-east-1
    components:
      - postgresql
      - etcd
      - application-data
EOF

kubectl apply -f backup-config.yaml
```

## Monitoring and Maintenance

### Health Checks

```bash
# Check cluster health
kubectl get nodes
kubectl get pods -A
kubectl top nodes
kubectl top pods -A

# Check Hexabase.AI specific components
kubectl get pods -n hexabase-system
kubectl logs -f deployment/hexabase-api -n hexabase-system
```

### Regular Maintenance Tasks

#### Weekly Tasks
- Review system logs for errors
- Check resource utilization
- Verify backup completion
- Update security patches

#### Monthly Tasks
- Review and rotate credentials
- Capacity planning assessment
- Performance optimization
- Security vulnerability scanning

#### Quarterly Tasks
- Kubernetes version updates
- Hexabase.AI platform updates
- Disaster recovery testing
- Architecture review

## Troubleshooting

### Common Issues

#### 1. Pod Scheduling Issues
```bash
# Check node resources
kubectl describe nodes

# Check taints and tolerations
kubectl describe node <node-name>

# Check resource quotas
kubectl describe resourcequota -A
```

#### 2. Storage Issues
```bash
# Check Ceph cluster health
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph status

# Check PVC status
kubectl get pvc -A
kubectl describe pvc <pvc-name>
```

#### 3. Network Connectivity Issues
```bash
# Check Calico status
kubectl get pods -n calico-system

# Test pod-to-pod connectivity
kubectl run test-pod --image=busybox --rm -it -- /bin/sh
# Inside pod: ping <target-ip>

# Check network policies
kubectl get networkpolicies -A
```

## Security Considerations

### 1. Air-Gapped Deployment

For maximum security, Hexabase.AI can be deployed in completely air-gapped environments:

```bash
# Create local container registry
docker run -d -p 5000:5000 --name registry registry:2

# Push Hexabase.AI images to local registry
docker tag hexabase/api:v1.0.0 localhost:5000/hexabase/api:v1.0.0
docker push localhost:5000/hexabase/api:v1.0.0

# Update Helm values to use local registry
cat > air-gapped-values.yaml << EOF
global:
  imageRegistry: localhost:5000
  
api:
  image:
    repository: localhost:5000/hexabase/api
    tag: "v1.0.0"
EOF
```

### 2. Hardware Security Module Integration

```bash
# Configure HSM for key management
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
  hsm-pin: <base64-encoded-pin>
EOF

kubectl apply -f hsm-config.yaml
```

## Related Topics

- [Enterprise Plan Features](./enterprise-plan.md) - Complete enterprise capabilities
- [Security Architecture](../security/index.md) - Comprehensive security overview
- [RBAC Configuration](../rbac/index.md) - Role-based access control setup
- [Monitoring Setup](../observability/index.md) - Complete observability stack