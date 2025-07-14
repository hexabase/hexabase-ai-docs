# Load Balancing

Load balancing is crucial for distributing traffic across multiple instances of your applications in Hexabase.AI. This guide covers various load balancing strategies and configurations.

## Overview

Hexabase.AI provides multiple levels of load balancing:

- **Service-level load balancing** (Layer 4)
- **Ingress-level load balancing** (Layer 7)
- **Global load balancing** (Multi-region)
- **Service mesh load balancing** (Advanced traffic management)

## Service Load Balancing

### ClusterIP Service

Basic load balancing within the cluster:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
  sessionAffinity: None # Round-robin by default
```

### Session Affinity

Maintain sticky sessions:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600 # 1 hour
```

### Headless Service

For client-side load balancing:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-headless
spec:
  clusterIP: None
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

## Ingress Load Balancing

### NGINX Ingress

Configure NGINX-based load balancing:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/load-balance: "round_robin"
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
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

### Load Balancing Algorithms

Available algorithms for NGINX:

```yaml
annotations:
  # Round Robin (default)
  nginx.ingress.kubernetes.io/load-balance: "round_robin"

  # Least Connections
  nginx.ingress.kubernetes.io/load-balance: "least_conn"

  # IP Hash
  nginx.ingress.kubernetes.io/load-balance: "ip_hash"

  # Consistent Hashing
  nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
```

### Advanced NGINX Configuration

```yaml
annotations:
  # Connection limits
  nginx.ingress.kubernetes.io/limit-connections: "10"
  nginx.ingress.kubernetes.io/limit-rps: "100"

  # Timeouts
  nginx.ingress.kubernetes.io/proxy-connect-timeout: "5"
  nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
  nginx.ingress.kubernetes.io/proxy-read-timeout: "60"

  # Retries
  nginx.ingress.kubernetes.io/proxy-next-upstream: "error timeout"
  nginx.ingress.kubernetes.io/proxy-next-upstream-tries: "3"
```

## Service Mesh Load Balancing

### Istio Configuration

Advanced traffic management with Istio:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp-destination
spec:
  host: myapp-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        http2MaxRequests: 100
        maxRequestsPerConnection: 2
    loadBalancer:
      simple: LEAST_REQUEST # or ROUND_ROBIN, RANDOM, PASSTHROUGH
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
```

### Circuit Breaking

Implement circuit breakers:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp-circuit-breaker
spec:
  host: myapp-service
  trafficPolicy:
    outlierDetection:
      consecutive5xxErrors: 5
      consecutiveGatewayErrors: 5
      interval: 10s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
      minHealthPercent: 30
      splitExternalLocalOriginErrors: true
```

### Retry Configuration

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-retry
spec:
  hosts:
    - myapp-service
  http:
    - timeout: 30s
      retries:
        attempts: 3
        perTryTimeout: 10s
        retryOn: gateway-error,connect-failure,refused-stream
        retryRemoteLocalities: true
```

## Global Load Balancing

### Multi-Region Setup

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: global-ingress
  annotations:
    external-dns.alpha.kubernetes.io/hostname: myapp.global.example.com
    external-dns.alpha.kubernetes.io/ttl: "60"
spec:
  rules:
    - host: myapp.global.example.com
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

### Geographic Load Balancing

Using HKS global load balancer:

```yaml
apiVersion: hks.io/v1
kind: GlobalLoadBalancer
metadata:
  name: myapp-global
spec:
  selector:
    app: myapp
  regions:
    - name: us-east-1
      weight: 40
      healthCheck:
        path: /health
        interval: 10s
    - name: eu-west-1
      weight: 30
    - name: ap-southeast-1
      weight: 30
  routing:
    policy: geographic # or weighted, latency, failover
    stickyRegion: true
```

## Health Checks

### Service Health Checks

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
  healthCheckNodePort: 30000
```

### Ingress Health Checks

```yaml
annotations:
  nginx.ingress.kubernetes.io/health-check-path: "/health"
  nginx.ingress.kubernetes.io/health-check-interval: "10"
  nginx.ingress.kubernetes.io/health-check-timeout: "5"
  nginx.ingress.kubernetes.io/health-check-max-fails: "3"
```

## Load Balancer Types

### Network Load Balancer (Layer 4)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-nlb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

### Application Load Balancer (Layer 7)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-alb
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
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

## Traffic Distribution

### Weighted Routing

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-weighted
spec:
  hosts:
    - myapp-service
  http:
    - match:
        - headers:
            version:
              exact: v2
      route:
        - destination:
            host: myapp-service
            subset: v2
          weight: 20
        - destination:
            host: myapp-service
            subset: v1
          weight: 80
```

### A/B Testing

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-ab-test
spec:
  hosts:
    - myapp-service
  http:
    - match:
        - headers:
            user-group:
              exact: beta
      route:
        - destination:
            host: myapp-service
            subset: v2
    - route:
        - destination:
            host: myapp-service
            subset: v1
```

### Canary Deployments

```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: myapp-canary
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  service:
    port: 80
    targetPort: 8080
  analysis:
    interval: 1m
    threshold: 10
    maxWeight: 50
    stepWeight: 10
    metrics:
      - name: request-success-rate
        thresholdRange:
          min: 99
        interval: 1m
```

## Performance Optimization

### Connection Pooling

```yaml
trafficPolicy:
  connectionPool:
    tcp:
      maxConnections: 100
      connectTimeout: 30s
      tcpKeepalive:
        time: 7200
        interval: 75
        probes: 10
    http:
      http1MaxPendingRequests: 100
      http2MaxRequests: 100
      maxRequestsPerConnection: 2
      h2UpgradePolicy: UPGRADE
```

### Keep-Alive Settings

```yaml
annotations:
  nginx.ingress.kubernetes.io/upstream-keepalive-connections: "32"
  nginx.ingress.kubernetes.io/upstream-keepalive-timeout: "60"
  nginx.ingress.kubernetes.io/upstream-keepalive-requests: "100"
```

## Monitoring and Metrics

### Prometheus Metrics

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
    prometheus.io/port: "9090"
spec:
  selector:
    app: myapp
  ports:
    - name: http
      port: 80
      targetPort: 8080
    - name: metrics
      port: 9090
      targetPort: 9090
```

### Load Balancer Metrics

Monitor key metrics:

- Request rate per backend
- Response time distribution
- Error rates
- Connection pool usage
- Circuit breaker status

```bash
# Check load balancer status
hb lb status myapp-service

# View backend health
hb lb backends myapp-service

# Monitor traffic distribution
hb lb traffic myapp-service --watch
```

## Troubleshooting

### Common Issues

1. **Uneven Load Distribution**

   ```bash
   # Check pod distribution
   hb get pods -o wide

   # Verify service endpoints
   hb get endpoints myapp-service
   ```

2. **Session Affinity Not Working**

   ```bash
   # Test session affinity
   for i in {1..10}; do
     curl -b cookies.txt -c cookies.txt http://myapp.example.com
   done
   ```

3. **Health Check Failures**

   ```bash
   # Check health endpoint
   hb exec -it myapp-pod -- curl localhost:8080/health

   # View ingress controller logs
   hb logs -n ingress-nginx deployment/ingress-nginx-controller
   ```

## Best Practices

1. **Choose the Right Load Balancer**

   - Use Service for internal traffic
   - Use Ingress for HTTP/HTTPS traffic
   - Use Service Mesh for advanced traffic management

2. **Health Checks**

   - Implement comprehensive health checks
   - Use appropriate timeouts and thresholds
   - Monitor health check metrics

3. **Performance**

   - Enable connection pooling
   - Configure appropriate timeouts
   - Use HTTP/2 when possible

4. **Reliability**

   - Implement circuit breakers
   - Configure retries appropriately
   - Use outlier detection

5. **Monitoring**
   - Track load distribution
   - Monitor error rates
   - Alert on anomalies
