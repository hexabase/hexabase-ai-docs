# Security Best Practices

This document provides a consolidated list of security best practices for using Hexabase.AI. While other documents cover specific features, this guide serves as a checklist to ensure you are operating in the most secure manner possible.

## 1. Identity and Access Management

- **Enforce MFA**: For the built-in HKS identity provider, ensure all users have Multi-Factor Authentication (MFA) enabled.
- **Use SSO for Enterprises**: Integrate your corporate identity provider (Okta, Azure AD) to centralize user management and enforce your organization's authentication policies.
- **Principle of Least Privilege (PoLP)**:
  - Assign users the most restrictive role that still allows them to perform their duties (e.g., prefer `developer` over `workspace_admin`).
  - Create custom, fine-grained roles for specific tasks if needed.
- **Regularly Audit Permissions**: Periodically review who has access to what. Remove stale user accounts and permissions promptly.
- **Use Service Accounts for Automation**:
  - Never use a human user's credentials in scripts or CI/CD pipelines.
  - Create dedicated `ServiceAccount`s with the minimum required permissions.
  - Generate short-lived API keys for these accounts.

## 2. Network Security

- **Start with "Default Deny"**: Apply a default-deny `NetworkPolicy` to all production namespaces. This blocks all pod-to-pod traffic by default, forcing you to explicitly allow necessary communication paths.
- **Micro-segment Your Applications**: Create granular `NetworkPolicy` resources that only allow required traffic between application components.
- **Control Egress Traffic**: Do not allow unrestricted outbound internet access from your pods. Use an `EgressGateway` to filter and monitor outbound traffic. Whitelist only the external IPs and domains your application needs to access.
- **Encrypt All Traffic**:
  - Terminate TLS at the Ingress for all external traffic.
  - Enable `STRICT` mTLS for all internal service-to-service traffic using the integrated service mesh.

## 3. Workload and Pod Security

- **Use Minimal, Secure Base Images**: Build your container images from trusted, minimal base images (like `distroless` or `alpine`) to reduce the attack surface.
- **Run as Non-Root**: Never run your container processes as the `root` user. Use a `securityContext` to specify a non-root user.
- **Read-Only Root Filesystem**: Where possible, run your containers with a read-only root filesystem to prevent an attacker from modifying the container's contents.
  ```yaml
  securityContext:
    readOnlyRootFilesystem: true
  ```
- **Apply Pod Security Standards**: Use `WorkspacePolicy` to enforce `baseline` or `restricted` pod security standards on your production workspaces, preventing the use of privileged containers.
- **Automate Vulnerability Scanning**:
  - Integrate image scanning into your CI/CD pipeline to catch vulnerabilities before deployment.
  - Use HKS `ImagePolicy` to block deployments that contain critical vulnerabilities.

## 4. Data and Storage Security

- **Encrypt Data at Rest**: Ensure that your `StorageClass` is configured to encrypt persistent volumes at rest using the underlying cloud provider's encryption mechanisms.
- **Secure Backups**:
  - Encrypt backups both in transit and at rest.
  - Use a dedicated, access-restricted bucket for your backup storage location.
  - Use separate storage locations for your primary and disaster recovery backups, preferably in different geographic regions.
- **Manage Secrets Securely**:
  - Use HKS or Kubernetes `Secrets` for all sensitive data like passwords, API keys, and certificates.
  - Do not store secrets in environment variables, ConfigMaps, or container images.
  - Use a secret management solution like HashiCorp Vault for enhanced security, and integrate it with HKS.

## 5. Auditing and Monitoring

- **Enable Comprehensive Auditing**: Ensure audit logging is enabled for all your production workspaces.
- **Integrate with SIEM**: Stream audit logs to your central SIEM for analysis and long-term retention.
- **Monitor for Anomalies**: Configure AIOps alerts to notify you of unusual activity, such as a spike in `403 Forbidden` errors, unexpected egress traffic, or anomalous API calls.
- **Log Everything**: Configure your applications to log to `stdout`/`stderr` in a structured format (like JSON) so HKS can aggregate and analyze the logs effectively.

## 6. General Best Practices

- **Infrastructure as Code (IaC)**: Define all your resources—from applications to security policies—as code (YAML) and store it in a version control system like Git. This makes your configuration auditable and repeatable.
- **Automate Compliance**: Leverage HKS `CompliancePacks` to automate the enforcement of security controls required by standards like HIPAA or PCI-DSS.
- **Regularly Test Your Security**:
  - Periodically run penetration tests against your applications.
  - Regularly test your disaster recovery and restore procedures.
