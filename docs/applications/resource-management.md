# Resource Management

Effective resource management is critical for optimal application performance and cluster efficiency in Hexabase.AI. This guide covers CPU, memory, storage, and other resource allocation strategies.

## Resource Types

### CPU Resources

CPU resources are measured in CPU units:

- `1` = 1 vCPU/Core
- `1000m` = 1 CPU (m = millicpu)
- `100m` = 0.1 CPU

```yaml
resources:
  requests:
    cpu: "100m" # Guaranteed minimum
  limits:
    cpu: "500m" # Maximum allowed
```

### Memory Resources

Memory is measured in bytes with unit suffixes:

- `Ki` = Kibibyte (1024 bytes)
- `Mi` = Mebibyte (1024 Ki)
- `Gi` = Gibibyte (1024 Mi)

```yaml
resources:
  requests:
    memory: "256Mi" # Guaranteed minimum
  limits:
    memory: "512Mi" # Maximum allowed
```

## Resource Requests and Limits

### Basic Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
        - name: app
          image: myapp:latest
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

### Understanding Requests vs Limits

- **Requests**: Guaranteed resources for scheduling
- **Limits**: Maximum resources a container can use

```yaml
# Burstable QoS class
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "200m"

# Guaranteed QoS class (requests = limits)
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## Quality of Service (QoS) Classes

### 1. Guaranteed

Highest priority, never killed unless exceeding limits:

```yaml
containers:
  - name: critical-app
    resources:
      requests:
        memory: "1Gi"
        cpu: "1"
      limits:
        memory: "1Gi"
        cpu: "1"
```

### 2. Burstable

Medium priority, can burst above requests:

```yaml
containers:
  - name: web-app
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "500m"
```

### 3. BestEffort

Lowest priority, first to be evicted:

```yaml
containers:
  - name: batch-job
    # No resources specified
```

## Resource Quotas

### Namespace Resource Limits

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: production
spec:
  hard:
    requests.cpu: "100"
    requests.memory: "200Gi"
    limits.cpu: "200"
    limits.memory: "400Gi"
    persistentvolumeclaims: "10"
    services.loadbalancers: "2"
```

### Object Count Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
  namespace: production
spec:
  hard:
    pods: "50"
    services: "10"
    replicationcontrollers: "20"
    secrets: "100"
    configmaps: "100"
```

## Limit Ranges

### Default Container Limits

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: production
spec:
  limits:
    - default:
        cpu: "500m"
        memory: "512Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
      max:
        cpu: "2"
        memory: "2Gi"
      min:
        cpu: "50m"
        memory: "64Mi"
      type: Container
```

### Pod-Level Limits

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limits
spec:
  limits:
    - max:
        cpu: "4"
        memory: "8Gi"
      min:
        cpu: "100m"
        memory: "128Mi"
      type: Pod
```

## Horizontal Pod Autoscaling (HPA)

### CPU-Based Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### Memory-Based Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-memory-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

### Custom Metrics Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-custom-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Pods
      pods:
        metric:
          name: requests_per_second
        target:
          type: AverageValue
          averageValue: "100"
    - type: Object
      object:
        metric:
          name: queue_length
        describedObject:
          apiVersion: v1
          kind: Service
          name: myapp-queue
        target:
          type: Value
          value: "30"
```

## Vertical Pod Autoscaling (VPA)

### VPA Configuration

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto" # or "Off", "Initial"
  resourcePolicy:
    containerPolicies:
      - containerName: app
        minAllowed:
          cpu: 100m
          memory: 128Mi
        maxAllowed:
          cpu: 2
          memory: 2Gi
        controlledResources: ["cpu", "memory"]
```

## Storage Resources

### Persistent Volume Claims

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
```

### Storage Classes

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
allowVolumeExpansion: true
```

### Volume Resource Limits

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-quota
spec:
  hard:
    requests.storage: "100Gi"
    persistentvolumeclaims: "10"
    fast-ssd.storageclass.storage.k8s.io/requests.storage: "50Gi"
    fast-ssd.storageclass.storage.k8s.io/persistentvolumeclaims: "5"
```

## Network Resources

### Bandwidth Limits

```yaml
metadata:
  annotations:
    kubernetes.io/ingress-bandwidth: "10M"
    kubernetes.io/egress-bandwidth: "10M"
```

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8080
```

## GPU Resources

### GPU Allocation

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
    - name: cuda-container
      image: nvidia/cuda:11.0-base
      resources:
        limits:
          nvidia.com/gpu: 1 # Request 1 GPU
```

### GPU Sharing

```yaml
# Using fractional GPUs with NVIDIA MIG
resources:
  limits:
    nvidia.com/mig-3g.20gb: 1
```

## Resource Monitoring

### Metrics Collection

```yaml
# Enable resource metrics
apiVersion: v1
kind: ConfigMap
metadata:
  name: metrics-config
data:
  metrics.yaml: |
    collection_interval: 30s
    resources:
      - cpu
      - memory
      - disk
      - network
```

### Resource Usage Commands

```bash
# View node resource usage
hb top nodes

# View pod resource usage
hb top pods -n production

# View container resource usage
hb top pod myapp-pod --containers

# Get resource quota status
hb get resourcequota -n production

# Describe resource usage
hb describe node worker-1
```

## Best Practices

### 1. Right-Sizing

```yaml
# Start with monitoring
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "200m"

# After analysis, adjust to actual usage
resources:
  requests:
    memory: "384Mi"  # P95 usage
    cpu: "150m"      # P95 usage
  limits:
    memory: "512Mi"  # P99 usage + buffer
    cpu: "300m"      # P99 usage + buffer
```

### 2. Resource Ratios

```yaml
# Good practice: 2:1 limit to request ratio
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi" # 2x request
    cpu: "1000m" # 2x request
```

### 3. Namespace Organization

```bash
# Create resource-isolated namespaces
hb create namespace dev --quota small
hb create namespace staging --quota medium
hb create namespace production --quota large
```

### 4. Resource Planning

```yaml
# Resource allocation strategy
apiVersion: v1
kind: ConfigMap
metadata:
  name: resource-tiers
data:
  small: |
    cpu: 100m-500m
    memory: 128Mi-512Mi
  medium: |
    cpu: 500m-2000m
    memory: 512Mi-2Gi
  large: |
    cpu: 2000m-8000m
    memory: 2Gi-8Gi
```

## Troubleshooting

### Common Issues

1. **OOMKilled Pods**

   ```bash
   # Check for OOM kills
   hb describe pod myapp-pod | grep -i oom

   # Increase memory limits
   hb set resources deployment myapp --limits=memory=1Gi
   ```

2. **CPU Throttling**

   ```bash
   # Check CPU throttling
   hb exec myapp-pod -- cat /sys/fs/cgroup/cpu/cpu.stat

   # Adjust CPU limits
   hb set resources deployment myapp --limits=cpu=1000m
   ```

3. **Pending Pods**

   ```bash
   # Check why pods are pending
   hb describe pod myapp-pod

   # View node resources
   hb describe nodes | grep -A 5 "Allocated resources"
   ```

### Resource Optimization

```bash
# Get recommendations from VPA
hb get vpa myapp-vpa -o yaml

# Analyze resource usage patterns
hb top pods --sort-by=cpu
hb top pods --sort-by=memory

# Export metrics for analysis
hb get --raw /metrics | grep container_
```

## HKS-Specific Features

### AI-Driven Resource Optimization

```yaml
apiVersion: hks.io/v1
kind: ResourceOptimizer
metadata:
  name: ai-optimizer
spec:
  target:
    kind: Deployment
    name: myapp
  optimization:
    mode: aggressive # or conservative, balanced
    metrics:
      - cpu
      - memory
    constraints:
      minReplicas: 2
      maxCost: 100 # USD per month
```

### Cost-Based Scaling

```yaml
apiVersion: hks.io/v1
kind: CostAwareHPA
metadata:
  name: cost-aware-scaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  costConstraints:
    maxMonthlyCost: 500
    preferSpotInstances: true
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```
