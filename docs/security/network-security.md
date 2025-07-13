# Network Security

Network security in Hexabase.AI is a multi-layered strategy designed to protect your applications from unauthorized access and to control the flow of traffic within and between your workspaces.

## Layers of Network Security

1.  **Workspace Isolation**: Each workspace is backed by a dedicated Kubernetes namespace, providing a primary boundary for network policies.
2.  **Network Policies**: Kubernetes NetworkPolicies are used to control traffic between pods within a workspace.
3.  **Ingress Control**: Ingress controllers and API gateways manage and secure all traffic entering the cluster from the outside.
4.  **Egress Control**: Egress gateways control and monitor all traffic leaving the cluster.
5.  **Service Mesh Security**: For fine-grained control, a service mesh (like Istio) provides mutual TLS (mTLS) for all service-to-service communication.

## Workspace Network Isolation

By default, workspaces are isolated from each other at the network level. Pods in `workspace-a` cannot directly communicate with pods in `workspace-b` unless explicitly allowed by an administrator.

## Kubernetes Network Policies

NetworkPolicies are the primary tool for implementing micro-segmentation within a workspace.

### Default Deny Policy

It is a best practice to start with a "default deny" policy for your production workspaces. This policy blocks all pod-to-pod traffic unless it is explicitly allowed by another policy.

```yaml
# policy-default-deny.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {} # Selects all pods in the namespace
  policyTypes:
    - Ingress
    - Egress
```

Applying this policy will immediately block all traffic. You must then create specific "allow" policies.

### Allowing Traffic Between Pods

This example allows pods with the label `role: frontend` to connect to pods with the label `role: backend` on port 8080.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### Limiting Egress Traffic

This policy only allows pods with `role: backend` to initiate connections to an external database IP.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-db
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: 192.168.100.10/32 # External DB IP
      ports:
        - protocol: TCP
          port: 5432
```

## Securing Ingress Traffic

All external traffic should pass through a secure Ingress gateway.

### TLS Termination

Terminate TLS at the edge using certificates managed by HKS.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    hks.io/tls-certificate: "my-app-cert"
spec:
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls # HKS manages this secret
  rules:
    - host: myapp.example.com
      http:
        paths:
        # ...
```

### Web Application Firewall (WAF)

Enable the WAF on your Ingress to protect against common web exploits (like SQL injection and XSS).

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    hks.io/waf-policy: "level-2-standard"
    hks.io/rate-limit: "100-per-minute"
# ...
```

## Controlling Egress Traffic

By default, pods can send traffic to any external destination. For a secure environment, this should be restricted.

### Egress Gateway

Configure a dedicated egress gateway to route all outbound traffic through a single, monitored point.

```yaml
apiVersion: hks.io/v1
kind: EgressGateway
metadata:
  name: main-egress-gw
spec:
  # Route all outbound traffic from this namespace through the gateway
  selector: {}
  # Assign a static IP for whitelisting by external services
  staticIp: true
  # Log all outbound connections
  logging:
    enabled: true
```

You can then create `NetworkPolicy` resources that only allow egress to the egress gateway itself.

## Service Mesh Security with mTLS

For the highest level of security (zero-trust networking), enable mutual TLS (mTLS) for all traffic _inside_ your workspace.

### Enabling mTLS

With HKS's integrated service mesh, enabling mTLS is a single command or annotation.

```bash
# Enable mTLS for the entire 'production' workspace
hb mesh mtls enable --workspace production
```

Or via a policy:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default-mtls
  namespace: production
spec:
  mtls:
    mode: STRICT
```

With `STRICT` mTLS, all service-to-service communication is automatically encrypted, and services must present a valid certificate to communicate, preventing spoofing and man-in-the-middle attacks within the cluster.

## Security Best Practices

1.  **Start with Default Deny**: Always apply a default-deny network policy to production namespaces and explicitly allow required traffic.
2.  **Micro-segmentation**: Create fine-grained network policies that only allow pods to communicate with the specific services they need.
3.  **Control Egress**: Don't allow unrestricted outbound access from your pods. Use an egress gateway and network policies to limit what your applications can connect to externally.
4.  **Encrypt Everywhere**: Use TLS for all ingress traffic and enable mTLS for all internal service-to-service traffic.
5.  **Audit Network Policies**: Regularly review and audit your network policies to ensure they are still correct and not overly permissive.
6.  **Log Network Traffic**: Enable flow logging on your egress gateway and service mesh to get visibility into your network traffic patterns, which is invaluable for security audits and troubleshooting.
