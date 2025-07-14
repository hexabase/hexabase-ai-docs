# Application Deployment

This guide covers deployment strategies and best practices for deploying applications to Hexabase.AI.

## Deployment Methods

### 1. Direct Kubernetes Manifests

Deploy applications using standard Kubernetes YAML manifests:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: app
          image: myregistry/myapp:v1.0.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

Deploy using HKS CLI:

```bash
hb apply -f deployment.yaml
```

### 2. Helm Charts

Deploy applications using Helm for templating and package management:

```bash
# Add a Helm repository
hb helm repo add bitnami https://charts.bitnami.com/bitnami

# Install an application
hb helm install myapp bitnami/wordpress \
  --set wordpressBlogName="My Blog" \
  --namespace production
```

Custom Helm chart structure:

```
myapp/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── configmap.yaml
└── charts/
```

### 3. HKS Application Templates

Use pre-configured application templates:

```yaml
# app.hks.yaml
apiVersion: hks.io/v1
kind: Application
metadata:
  name: myapp
spec:
  template: nodejs-web
  source:
    git:
      url: https://github.com/myorg/myapp
      branch: main
  build:
    dockerfile: Dockerfile
  deploy:
    replicas: 3
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
```

### 4. GitOps Deployment

Implement GitOps workflow with automatic synchronization:

```yaml
# gitops-app.yaml
apiVersion: hks.io/v1
kind: GitOpsApplication
metadata:
  name: myapp
spec:
  source:
    repoURL: https://github.com/myorg/myapp-config
    path: overlays/production
    targetRevision: main
  destination:
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Container Image Management

### Image Registry Integration

```yaml
# Configure private registry
apiVersion: v1
kind: Secret
metadata:
  name: registry-credentials
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

### Image Scanning and Security

```yaml
deploy:
  imagePolicy:
    scan:
      enabled: true
      failThreshold: HIGH
    sign:
      enabled: true
      keyRef: cosign-key
```

## Configuration Management

### ConfigMaps

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.url: "postgres://db:5432/myapp"
  log.level: "info"
  feature.flags: |
    new-ui=true
    beta-features=false
```

### Secrets Management

```yaml
# Using HKS secret management
hb secret create app-secrets \
--from-literal=db-password=mypassword \
--from-file=tls.crt=/path/to/cert
```

### Environment Variables

```yaml
containers:
  - name: app
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: app-secrets
            key: database-url
      - name: LOG_LEVEL
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: log.level
```

## Health Checks

### Readiness Probe

```yaml
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```

### Liveness Probe

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### Startup Probe

```yaml
startupProbe:
  httpGet:
    path: /health/startup
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 10
  failureThreshold: 30
```

## Deployment Strategies

### Rolling Update

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

### Blue-Green Deployment

```bash
# Deploy green version
hb deploy myapp-green --image myapp:v2.0.0

# Test green version
hb test myapp-green

# Switch traffic
hb switch-traffic myapp --to green

# Remove blue version
hb delete deployment myapp-blue
```

### Canary Deployment

```yaml
# Using HKS canary feature
apiVersion: hks.io/v1
kind: CanaryDeployment
metadata:
  name: myapp-canary
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  canarySpec:
    image: myapp:v2.0.0
    percentage: 10
    stepWeight: 10
    stepDuration: 10m
```

## Persistent Storage

### Volume Claims

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
```

### Volume Mounts

```yaml
containers:
  - name: app
    volumeMounts:
      - name: data
        mountPath: /var/lib/app/data
      - name: config
        mountPath: /etc/app
        readOnly: true
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: app-storage
  - name: config
    configMap:
      name: app-config
```

## Network Configuration

### Service Definition

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```

### Ingress Configuration

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-service
                port:
                  number: 80
```

## Multi-Environment Deployment

### Environment Separation

```yaml
# base/kustomization.yaml
resources:
  - deployment.yaml
  - service.yaml

# overlays/dev/kustomization.yaml
bases:
  - ../../base
patchesStrategicMerge:
  - deployment-patch.yaml
configMapGenerator:
  - name: app-config
    literals:
      - environment=development

# overlays/prod/kustomization.yaml
bases:
  - ../../base
replicas:
  - name: myapp
    count: 5
```

### Namespace Isolation

```bash
# Create environments
hb namespace create dev
hb namespace create staging
hb namespace create production

# Deploy to specific environment
hb deploy --namespace production
```

## Monitoring and Observability

### Prometheus Metrics

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
```

### Application Logs

```yaml
# Configure log aggregation
spec:
  containers:
    - name: app
      env:
        - name: LOG_FORMAT
          value: "json"
        - name: LOG_OUTPUT
          value: "stdout"
```

## Best Practices

1. **Container Best Practices**

   - Use minimal base images
   - Run as non-root user
   - One process per container
   - Handle signals properly

2. **Resource Management**

   - Always set resource requests and limits
   - Use horizontal pod autoscaling
   - Implement proper health checks

3. **Security**

   - Scan images for vulnerabilities
   - Use network policies
   - Implement RBAC
   - Encrypt secrets at rest

4. **High Availability**

   - Deploy across multiple zones
   - Use pod disruption budgets
   - Implement circuit breakers
   - Design for failure

5. **Deployment Hygiene**
   - Use declarative configuration
   - Version everything
   - Automate deployments
   - Monitor deployment metrics

## Troubleshooting

### Common Issues

```bash
# Check deployment status
hb get deployments -n production

# View pod logs
hb logs -f deployment/myapp

# Describe pod for events
hb describe pod myapp-xyz

# Check resource usage
hb top pods -n production

# Debug running container
hb exec -it myapp-xyz -- /bin/sh
```

### Rollback Procedures

```bash
# View rollout history
hb rollout history deployment/myapp

# Rollback to previous version
hb rollout undo deployment/myapp

# Rollback to specific revision
hb rollout undo deployment/myapp --to-revision=2
```
