# Enterprise Plan Scenario

The **Enterprise Plan** is the premier offering from Hexabase.AI, designed for large organizations with stringent security, compliance, scalability, and governance requirements. This use case illustrates how a large enterprise leverages the full power of the platform.

## Goal

The goal of the Enterprise Plan is to provide a highly secure, compliant, scalable, and governable platform for large organizations. It is designed for enterprises with stringent requirements for security (e.g., in finance or healthcare), multi-region deployments, detailed cost management, and comprehensive auditing capabilities.

### 1. Centralized Governance and Organization

- An enterprise sets up a central organization on Hexabase.AI.
- They integrate their existing Single Sign-On (SSO) provider (like Okta or Azure AD) for seamless and secure user authentication.
- A fine-grained RBAC model is implemented, with custom roles and policies that map directly to their internal corporate structure.

### 2. Workspace and Cost Management

- The central IT department creates multiple workspaces for different business units (e.g., `Finance-BU`, `Healthcare-Analytics`, `Retail-Apps`).
- A key feature for the enterprise is **Budget Planning**. They assign specific budgets and resource quotas to each workspace.
- The platform provides detailed cost-allocation reports, allowing the organization to track spending per business unit, project, or even by specific labels, which is crucial for financial governance.

### 3. Uncompromising Security and Compliance

- **Full Audit Logs**: The Enterprise Plan provides comprehensive, immutable audit logs with long-term retention. All actions are logged and can be exported to their SIEM (Security Information and Event Management) system.
- **Compliance Packs**: The enterprise applies pre-built compliance packs for PCI-DSS and HIPAA to relevant workspaces, which automatically enforce security policies and configurations required for those standards.
- **Private Networking**: Workspaces handling sensitive data are connected to on-premises data centers via a dedicated VPN gateway, ensuring secure, private traffic.

### 4. Advanced Scalability and Reliability

- **Scale-Out Plan**: The platform is configured for multi-region and multi-cloud deployments. A mission-critical application in the finance business unit can run active-active across two different cloud providers for maximum availability.
- **Advanced Backup and DR**: The enterprise designs sophisticated backup strategies, enabling point-in-time recovery for databases, application-aware backup policies, and automated disaster recovery plan testing.

### 5. Full-Featured AIOps

- The Enterprise Plan unlocks the platform's complete **AIOps suite**:
  - **Predictive Scaling**: The AIOps engine analyzes historical trends to predict traffic spikes (e.g., during market open for a finance app) and pre-emptively scales resources.
  - **Automated Root Cause Analysis**: When an issue occurs, the AIOps assistant not only identifies it but also traces the problem back to the specific code commit or infrastructure change that caused it.
  - **Security Threat Detection**: The AI continuously monitors for anomalous behavior that could indicate a security threat, such as unusual API access patterns or data exfiltration attempts.

### 6. Custom Contracts and Support

- An enterprise can have a **special contract** with a fixed pricing model that aligns with their budget cycles.
- They also receive a dedicated Technical Account Manager (TAM) and a 24/7 premium support SLA, ensuring expert help is always available.

## Summary of Features Used

| Feature             | Enterprise Plan Usage                                                                           |
| :------------------ | :---------------------------------------------------------------------------------------------- |
| **Governance**      | SSO integration, custom RBAC, and centralized policy management.                                |
| **Cost Management** | Budget planning per workspace, detailed cost allocation, and fixed-price contracts.             |
| **Audit Logs**      | Complete, immutable audit logs with long-term retention and SIEM integration.                   |
| **Security**        | Compliance packs (PCI, HIPAA), private networking, and advanced threat detection.               |
| **Scalability**     | Multi-region, multi-cloud deployments with automated scale-out plans.                           |
| **Backups & DR**    | Advanced, application-aware backup strategies and automated DR testing.                         |
| **AIOps**           | Full suite including predictive scaling, automated root cause analysis, and AI-driven security. |
| **Support**         | Dedicated TAM, premium support, and custom SLAs.                                                |
