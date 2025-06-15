# Authentication and Authorization

Security is paramount in a multi-tenant environment. Hexabase.AI implements robust, standards-based authentication and authorization mechanisms to ensure that only legitimate users and services can access your resources.

## Authentication (AuthN) - Who are you?

Authentication is the process of verifying the identity of a user or service. HKS supports multiple authentication methods.

### 1. User Authentication via OAuth 2.0 and OIDC

- **Mechanism**: All user-facing interactions with HKS (UI and CLI) are authenticated using the OAuth 2.0 Authorization Code Flow with PKCE. HKS acts as an OAuth 2.0 client, and it integrates with an OIDC (OpenID Connect) provider for identity verification.
- **Default Provider**: Hexabase.AI provides a built-in OIDC provider for new organizations.
- **Single Sign-On (SSO)**: For Enterprise plans, you can integrate your own identity provider (IdP) like **Okta, Azure Active Directory, or Google Workspace**. This allows your users to log in using their existing corporate credentials.

**SSO Configuration Example (for Org Admins):**

```yaml
apiVersion: hks.io/v1
kind: AuthProvider
metadata:
  name: okta-sso
spec:
  type: oidc
  config:
    issuerUrl: "https://my-org.okta.com"
    clientId: "hks-client-id"
    clientSecretRef:
      name: okta-secret
      key: clientSecret
    scopes:
      - openid
      - profile
      - email
      - groups
    groupClaim: "groups"
```

### 2. Service Account Authentication (for Machines)

- **Mechanism**: For programmatic access (e.g., in CI/CD pipelines or scripts), HKS uses Service Accounts. These are non-user accounts that can be granted specific permissions.
- **Authentication Method**: Service Accounts authenticate using signed JSON Web Tokens (JWTs). These tokens are short-lived for enhanced security.

**Creating a Service Account and API Key:**

```bash
# Create a service account
hks create service-account cicd-agent --description "For CI/CD pipeline"

# Create an API key (JWT) for the service account
hks create api-key --service-account cicd-agent --duration 24h
```

The output of this command is a JWT that can be used as a Bearer token in API requests.

## Authorization (AuthZ) - What can you do?

Authorization is the process of determining what an authenticated user or service is allowed to do. HKS uses a sophisticated Role-Based Access Control (RBAC) model.

### The HKS RBAC Model

The authorization model has two main layers:

1.  **Organization RBAC**: Defines roles at the organization level (`org_admin`, `org_user`). Org Admins can manage billing, users, and workspaces.
2.  **Workspace RBAC**: Defines roles within a specific workspace (`workspace_admin`, `developer`, `viewer`). These roles grant permissions to interact with Kubernetes resources (Deployments, Pods, etc.) within that workspace.

For more details, see the dedicated [RBAC documentation](../rbac/index.md).

### How Authorization Works

1.  A user or service makes a request to the HKS API with a valid JWT.
2.  The API gateway validates the token.
3.  The AuthZ service extracts the user/service identity and their associated roles/groups from the token.
4.  It checks the requested action (e.g., `create Deployment in 'prod-workspace'`) against the RBAC policies defined for that user/role.
5.  If the policy allows the action, the request is forwarded to the appropriate backend service.
6.  If not, a `403 Forbidden` error is returned.

### Kubernetes RBAC Integration

- HKS RBAC seamlessly integrates with the underlying Kubernetes RBAC.
- When you assign a user the `developer` role in a workspace, HKS automatically creates a corresponding `Role` and `RoleBinding` in the underlying Kubernetes namespace for that workspace.
- This ensures that when the user interacts with the Kubernetes API server directly (e.g., via `kubectl`), the same permissions are enforced.

**Example of a generated Kubernetes Role:**

```yaml
# This role is automatically created and managed by HKS
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: hks-developer-role
  namespace: prod-workspace-ns
rules:
  - apiGroups: ["", "apps", "batch"]
    resources: ["pods", "deployments", "services", "jobs", "cronjobs"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get", "list", "watch"]
```

## Security Best Practices

1.  **Principle of Least Privilege**: Always grant users and service accounts the minimum permissions they need to perform their jobs. Avoid using highly privileged roles like `workspace_admin` for daily tasks.
2.  **Use SSO**: For organizations, always integrate your corporate IdP using SSO. This centralizes user management and enforces your company's authentication policies (like MFA).
3.  **Short-Lived Tokens**: For service accounts, generate short-lived API keys (e.g., `1h` or `8h`) specific to the task at hand, especially in automated environments like CI/CD.
4.  **Regularly Audit Permissions**: Org Admins should regularly review user roles and permissions to remove stale access.
5.  **Secure `clientSecret`**: When configuring an SSO provider, store the `clientSecret` in a secure Kubernetes secret, not in plain text.
