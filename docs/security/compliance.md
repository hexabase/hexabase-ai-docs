# Compliance

For organizations operating in regulated industries, meeting compliance standards like PCI-DSS, HIPAA, or SOC 2 is a critical requirement. Hexabase.AI is designed with compliance in mind, providing tools and features that help you enforce policies, audit your environment, and demonstrate adherence to various regulatory frameworks.

## How Hexabase.AI Helps with Compliance

- **Secure by Default**: The platform provides a secure foundation, with features like workspace isolation, mTLS, and RBAC that align with the security principles of most compliance standards.
- **Policy Enforcement**: HKS allows you to programmatically enforce security and configuration policies across your environment.
- **Comprehensive Auditing**: Immutable, long-term audit logs provide a detailed record of all activities, which is essential for compliance reporting.
- **Automation**: Automate compliance checks and evidence gathering to reduce the manual burden of audits.

## Compliance Packs

Compliance Packs are pre-configured sets of policies, security controls, and monitoring rules tailored for specific regulatory standards. These are available on the Enterprise Plan.

### Enabling a Compliance Pack

An Org Admin can enable a Compliance Pack for a specific workspace.

```bash
# Enable the HIPAA compliance pack for the 'healthcare-data' workspace
hb workspace configure healthcare-data --compliance-pack hipaa
```

When a pack is enabled, HKS automatically:

1.  Applies a strict set of `NetworkPolicy` resources.
2.  Enforces `STRICT` mTLS for all service communication.
3.  Applies pod security standards to prevent privileged containers.
4.  Configures fine-grained audit logging for all resources in the workspace.
5.  Enables vulnerability scanning for all container images deployed to the workspace.

### Available Compliance Packs

- **PCI-DSS**: For handling credit card and payment information.
- **HIPAA**: For managing protected health information (PHI).
- **SOC 2**: For service organizations requiring reports on security, availability, and confidentiality.
- **CIS Benchmarks**: Enforces configuration best practices based on the Center for Internet Security benchmarks for Kubernetes.

## Pod Security Standards

Hexabase.AI enforces Kubernetes Pod Security Standards to ensure that workloads run securely. You can apply different levels of security to your workspaces.

```yaml
apiVersion: hks.io/v1
kind: WorkspacePolicy
metadata:
  name: production-pod-security
spec:
  # Applies to workspaces with this label
  workspaceSelector:
    environment: production
  # Enforce the 'baseline' or 'restricted' Kubernetes standard
  podSecurityStandard: "baseline"
```

- **Privileged**: Unrestricted, for trusted workloads only.
- **Baseline**: Minimally restrictive, prevents known privilege escalations.
- **Restricted**: Heavily restricted, follows current pod hardening best practices.

## Audit Logs for Compliance

Detailed audit logs are a cornerstone of any compliance strategy.

### Accessing Audit Logs

Enterprise Plan users have access to long-term, immutable audit logs.

```bash
# Query audit logs for a specific workspace and time range
hb audit-logs query \
  --workspace sensitive-data \
  --start-time "2025-06-01T00:00:00Z" \
  --end-time "2025-06-15T00:00:00Z" \
  --filter "event.type=resource.delete"
```

### SIEM Integration

You can stream audit logs directly to your organization's Security Information and Event Management (SIEM) system (e.g., Splunk, Datadog, ELK).

```yaml
apiVersion: hks.io/v1
kind: AuditLogSink
metadata:
  name: splunk-integration
spec:
  type: splunk
  config:
    endpoint: "https://http-inputs-my-org.splunkcloud.com"
    tokenSecretRef:
      name: splunk-hec-token
      key: token
  filter:
    # Only send critical events to the SIEM
    minSeverity: "warning"
```

## Vulnerability Management

Continuously scanning for vulnerabilities is a key compliance requirement.

### Automated Image Scanning

HKS automatically scans all container images upon deployment to a workspace.

```yaml
# Policy to block deployments with critical vulnerabilities
apiVersion: hks.io/v1
kind: ImagePolicy
metadata:
  name: block-critical-vulns
spec:
  workspaceSelector:
    environment: production
  scan:
    failOn:
      severity: "CRITICAL"
      # Optionally, fail if a fix is available
      fixAvailable: true
```

### Viewing Vulnerability Reports

You can view vulnerability reports for your running applications at any time.

```bash
# Get a vulnerability report for a deployment
hb get vulnerabilities --deployment myapp-deployment
```

## Best Practices for Maintaining Compliance

1.  **Engage Your Security Team**: Work with your organization's security and compliance teams to map regulatory requirements to HKS features.
2.  **Use Compliance Packs**: If you are on the Enterprise Plan, leverage Compliance Packs to automate the enforcement of baseline controls.
3.  **Automate Evidence Gathering**: Use the `hb audit-logs` CLI and SIEM integration to automate the collection of evidence required for audits.
4.  **Least Privilege**: Apply the principle of least privilege not just to users, but to all resources. Use strict network policies and pod security standards.
5.  **Stay Updated**: Regularly review and apply updates to your applications and the HKS platform to patch vulnerabilities.
6.  **Documentation**: Keep internal documentation that maps each compliance requirement to the specific control or policy you have implemented in Hexabase.AI.
