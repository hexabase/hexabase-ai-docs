# Service Discovery

Service discovery is essential for microservices communication in Hexabase.AI. This guide covers DNS-based discovery, service mesh integration, and advanced service discovery patterns.

## Overview

Hexabase.AI provides multiple service discovery mechanisms:

- **Kubernetes DNS** (CoreDNS)
- **Service mesh discovery** (Istio/Linkerd)
- **External service discovery** (Consul, etcd)
- **Headless services** for direct pod discovery

## Kubernetes DNS Service Discovery

### Basic Service Discovery

Every service gets a DNS entry:

```
<service-name>.<namespace>.svc.cluster.local
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-api
  namespace: production
spec:
  selector:
    app: backend
  ports:
    - port: 8080
      targetPort: 8080
```

Access patterns:

```bash
# From same namespace
curl http://backend-api:8080

# From different namespace
curl http://backend-api.production:8080

# Fully qualified
curl http://backend-api.production.svc.cluster.local:8080
```

### DNS Policies

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  dnsPolicy: ClusterFirst # Default
  # Other options: Default, None, ClusterFirstWithHostNet
  dnsConfig:
    nameservers:
      - 1.1.1.1
    searches:
      - production.svc.cluster.local
      - svc.cluster.local
    options:
      - name: ndots
        value: "5"
```

## Headless Services

### Direct Pod Discovery

```yaml
apiVersion: v1
kind: Service
metadata:
  name: database-cluster
spec:
  clusterIP: None # Headless service
  selector:
    app: postgres
  ports:
    - port: 5432
```

DNS returns all pod IPs:

```bash
# Returns A records for all pods
nslookup database-cluster.default.svc.cluster.local

# Individual pod DNS
<pod-name>.<service-name>.<namespace>.svc.cluster.local
```

### StatefulSet Service Discovery

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
    - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:14
```

Predictable pod names:

```bash
# Access specific replicas
postgres-0.postgres-headless.default.svc.cluster.local
postgres-1.postgres-headless.default.svc.cluster.local
postgres-2.postgres-headless.default.svc.cluster.local
```

## Service Mesh Discovery

### Istio Service Discovery

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: external-api
spec:
  hosts:
    - api.external.com
  ports:
    - number: 443
      name: https
      protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
```

### Virtual Services

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews-route
spec:
  hosts:
    - reviews
  http:
    - match:
        - headers:
            version:
              exact: v2
      route:
        - destination:
            host: reviews
            subset: v2
    - route:
        - destination:
            host: reviews
            subset: v1
```

### Destination Rules

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: reviews-destination
spec:
  host: reviews
  subsets:
    - name: v1
      labels:
        version: v1
    - name: v2
      labels:
        version: v2
```

## EndpointSlices

### Modern Endpoint Management

```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: myapp-endpoints
  labels:
    kubernetes.io/service-name: myapp
addressType: IPv4
endpoints:
  - addresses:
      - "10.1.2.3"
    conditions:
      ready: true
      serving: true
      terminating: false
ports:
  - port: 8080
    protocol: TCP
```

## Service Discovery Patterns

### Client-Side Load Balancing

```go
// Go example with client-side discovery
package main

import (
    "fmt"
    "net"
    "math/rand"
)

func discoverService(service string) ([]string, error) {
    _, addrs, err := net.LookupSRV("", "", service)
    if err != nil {
        return nil, err
    }

    var endpoints []string
    for _, addr := range addrs {
        endpoints = append(endpoints, fmt.Sprintf("%s:%d", addr.Target, addr.Port))
    }
    return endpoints, nil
}

func getRandomEndpoint(service string) (string, error) {
    endpoints, err := discoverService(service)
    if err != nil {
        return "", err
    }
    return endpoints[rand.Intn(len(endpoints))], nil
}
```

### Health-Aware Discovery

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "false"
spec:
  selector:
    app: api
  ports:
    - port: 80
  publishNotReadyAddresses: false # Only discover ready pods
```

## External Service Discovery

### Consul Integration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: consul-config
data:
  consul.json: |
    {
      "datacenter": "dc1",
      "services": [
        {
          "name": "web-app",
          "tags": ["production", "v1"],
          "port": 8080,
          "check": {
            "http": "http://localhost:8080/health",
            "interval": "10s"
          }
        }
      ]
    }
```

### External DNS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    external-dns.alpha.kubernetes.io/hostname: myapp.example.com
    external-dns.alpha.kubernetes.io/ttl: "60"
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
```

## Multi-Cluster Discovery

### Cross-Cluster Service Discovery

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: cross-cluster-service
spec:
  hosts:
    - remote-service.remote-cluster.local
  location: MESH_EXTERNAL
  ports:
    - number: 8080
      name: http
      protocol: HTTP
  resolution: DNS
  endpoints:
    - address: cluster-2-gateway.example.com
      ports:
        http: 15443
```

### Multi-Cluster DNS

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  remote.server: |
    remote-cluster.local:53 {
        forward . 10.0.0.100:53
    }
```

## Service Discovery Security

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-discovery-policy
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: production
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### mTLS for Service Communication

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

## Advanced Patterns

### Service Registry Pattern

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: service-registry
data:
  services.yaml: |
    services:
      - name: user-service
        endpoints:
          - host: user-service.production
            port: 8080
            weight: 100
      - name: order-service
        endpoints:
          - host: order-service-v1.production
            port: 8080
            weight: 80
          - host: order-service-v2.production
            port: 8080
            weight: 20
```

### Circuit Breaker with Discovery

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: circuit-breaker
spec:
  host: backend-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
      minHealthPercent: 30
```

## Monitoring Service Discovery

### Metrics

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
spec:
  selector:
    app: myapp
  ports:
    - name: web
      port: 80
    - name: metrics
      port: 9090
```

### Discovery Health Checks

```bash
# Check DNS resolution
hks exec -it debug-pod -- nslookup myservice

# Check endpoints
hks get endpoints myservice

# Check endpoint slices
hks get endpointslices -l kubernetes.io/service-name=myservice

# Test service discovery
hks run test --rm -it --image=busybox -- wget -O- http://myservice
```

## Troubleshooting

### Common Issues

1. **DNS Resolution Failures**

   ```bash
   # Check CoreDNS logs
   hks logs -n kube-system -l k8s-app=kube-dns

   # Test DNS from pod
   hks exec -it myapp -- nslookup kubernetes.default
   ```

2. **Service Not Found**

   ```bash
   # Verify service exists
   hks get svc myservice

   # Check service selector
   hks describe svc myservice

   # Verify matching pods
   hks get pods -l app=myapp
   ```

3. **Endpoint Not Ready**

   ```bash
   # Check endpoint status
   hks get endpoints myservice

   # Check pod readiness
   hks get pods -l app=myapp -o wide
   ```

### Debugging Tools

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-debug
spec:
  containers:
    - name: debug
      image: nicolaka/netshoot
      command: ["/bin/bash"]
      args: ["-c", "sleep 3600"]
```

Debug commands:

```bash
# DNS debugging
dig @10.96.0.10 myservice.default.svc.cluster.local

# Service discovery test
curl -v http://myservice.default.svc.cluster.local

# Trace network path
traceroute myservice.default.svc.cluster.local
```

## Best Practices

1. **Use Appropriate Discovery Method**

   - DNS for simple service discovery
   - Headless services for stateful applications
   - Service mesh for advanced traffic management

2. **Implement Health Checks**

   - Always define readiness probes
   - Use liveness probes for self-healing
   - Configure appropriate timeouts

3. **Cache Discovery Results**

   - Implement client-side caching
   - Use TTL appropriately
   - Handle cache invalidation

4. **Monitor Discovery Health**

   - Track DNS query latency
   - Monitor endpoint changes
   - Alert on discovery failures

5. **Security Considerations**
   - Use network policies
   - Implement mTLS where possible
   - Limit service exposure

## HKS-Specific Features

### AI-Enhanced Discovery

```yaml
apiVersion: hks.io/v1
kind: SmartDiscovery
metadata:
  name: intelligent-routing
spec:
  service: myapp
  optimization:
    - latency
    - cost
    - reliability
  learning:
    enabled: true
    window: 7d
```

### Global Service Catalog

```bash
# List all services across clusters
hks catalog list --global

# Search services by capability
hks catalog search --tag "user-auth"

# Get service details
hks catalog describe user-service --detailed
```
