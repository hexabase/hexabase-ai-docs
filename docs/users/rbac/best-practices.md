# RBAC Best Practices

This guide provides comprehensive best practices for implementing and maintaining Role-Based Access Control in Hexabase.AI, ensuring security, scalability, and operational efficiency.

## Design Principles

### Principle of Least Privilege

```yaml
# least-privilege-example.yaml
apiVersion: rbac/v1
kind: BestPractice
metadata:
  name: least-privilege
spec:
  # Bad Practice - Too Permissive
  avoid:
    - role: developer-all-access
      rules:
        - resources: ["*"]
          verbs: ["*"]

  # Good Practice - Specific Permissions
  recommended:
    - role: developer-read
      rules:
        - resources: ["deployments", "pods", "services"]
          verbs: ["get", "list", "watch"]

    - role: developer-deploy
      rules:
        - resources: ["deployments"]
          verbs: ["create", "update", "patch"]
          namespaces: ["dev-*", "staging-*"]
```

### Role Granularity

```python
# role-design-analyzer.py
class RoleDesignAnalyzer:
    def __init__(self):
        self.metrics = {
            'optimal_permissions_per_role': (5, 20),
            'optimal_roles_per_user': (1, 5),
            'max_permission_overlap': 0.3
        }

    def analyze_role_design(self, roles):
        """Analyze role design for best practices"""
        issues = []
        recommendations = []

        for role in roles:
            # Check role size
            perm_count = len(role.permissions)
            if perm_count < self.metrics['optimal_permissions_per_role'][0]:
                issues.append({
                    'role': role.name,
                    'issue': 'Role too granular',
                    'recommendation': 'Consider merging with similar roles'
                })
            elif perm_count > self.metrics['optimal_permissions_per_role'][1]:
                issues.append({
                    'role': role.name,
                    'issue': 'Role too broad',
                    'recommendation': 'Consider splitting into multiple roles'
                })

        # Check for permission overlap
        overlap_matrix = self.calculate_overlap(roles)
        for i, role1 in enumerate(roles):
            for j, role2 in enumerate(roles[i+1:], i+1):
                if overlap_matrix[i][j] > self.metrics['max_permission_overlap']:
                    recommendations.append({
                        'type': 'consolidation',
                        'roles': [role1.name, role2.name],
                        'overlap': overlap_matrix[i][j],
                        'suggestion': 'Consider consolidating overlapping roles'
                    })

        return {
            'issues': issues,
            'recommendations': recommendations,
            'metrics': self.calculate_metrics(roles)
        }
```

## Role Design Patterns

### Hierarchical Role Structure

```yaml
# role-hierarchy.yaml
apiVersion: rbac/v1
kind: RoleHierarchy
metadata:
  name: organization-roles
spec:
  # Base roles - building blocks
  baseRoles:
    - name: reader
      description: "Basic read access"
      permissions:
        - resources: ["*"]
          verbs: ["get", "list", "watch"]

    - name: writer
      description: "Write access to non-critical resources"
      permissions:
        - resources: ["configmaps", "services"]
          verbs: ["create", "update", "patch", "delete"]

  # Composite roles - combine base roles
  compositeRoles:
    - name: developer
      description: "Standard developer access"
      includes: ["reader", "writer"]
      additional:
        - resources: ["deployments", "pods"]
          verbs: ["create", "update", "delete"]
          namespaces: ["dev-*", "staging-*"]

    - name: senior-developer
      description: "Senior developer with production read"
      includes: ["developer"]
      additional:
        - resources: ["*"]
          verbs: ["get", "list"]
          namespaces: ["production"]

  # Administrative roles
  administrativeRoles:
    - name: team-lead
      description: "Team management permissions"
      includes: ["senior-developer"]
      additional:
        - resources: ["rolebindings"]
          verbs: ["create", "update", "delete"]
          namespaces: ["team-*"]
```

### Environment-Based Roles

```yaml
# environment-roles.yaml
apiVersion: rbac/v1
kind: EnvironmentRoles
metadata:
  name: environment-separation
spec:
  environments:
    development:
      roles:
        - name: dev-full-access
          permissions:
            - resources: ["*"]
              verbs: ["*"]

    staging:
      roles:
        - name: staging-deployer
          permissions:
            - resources: ["deployments", "services", "configmaps"]
              verbs: ["get", "list", "create", "update", "patch"]
            - resources: ["pods", "logs"]
              verbs: ["get", "list", "watch"]

    production:
      roles:
        - name: prod-viewer
          permissions:
            - resources: ["*"]
              verbs: ["get", "list", "watch"]

        - name: prod-operator
          permissions:
            - resources: ["deployments"]
              verbs: ["get", "update", "patch"]
              conditions:
                - requireApproval: true
                - allowedHours: "09:00-17:00"
```

### Functional Roles

```python
# functional-roles.py
class FunctionalRoleDesigner:
    """Design roles based on job functions"""

    def create_functional_roles(self):
        return {
            'security-auditor': {
                'description': 'Security audit and compliance',
                'permissions': [
                    {
                        'resources': ['*'],
                        'verbs': ['get', 'list'],
                        'scope': 'cluster'
                    },
                    {
                        'resources': ['events', 'audits'],
                        'verbs': ['get', 'list', 'watch'],
                        'scope': 'cluster'
                    }
                ]
            },

            'sre-engineer': {
                'description': 'Site reliability engineering',
                'permissions': [
                    {
                        'resources': ['nodes', 'pods', 'services'],
                        'verbs': ['*'],
                        'scope': 'cluster'
                    },
                    {
                        'resources': ['metrics', 'logs'],
                        'verbs': ['get', 'list'],
                        'scope': 'cluster'
                    }
                ]
            },

            'data-scientist': {
                'description': 'Data analysis and ML workloads',
                'permissions': [
                    {
                        'resources': ['jobs', 'cronjobs'],
                        'verbs': ['*'],
                        'namespaces': ['data-science', 'ml-*']
                    },
                    {
                        'resources': ['persistentvolumeclaims'],
                        'verbs': ['create', 'delete'],
                        'namespaces': ['data-science']
                    }
                ]
            }
        }
```

## Implementation Guidelines

### Role Naming Conventions

```yaml
# naming-conventions.yaml
apiVersion: rbac/v1
kind: NamingConvention
metadata:
  name: role-naming-standards
spec:
  patterns:
    # Environment-based naming
    - pattern: "{environment}-{function}-{permission-level}"
      examples:
        - "prod-database-reader"
        - "staging-api-admin"
        - "dev-frontend-deployer"

    # Team-based naming
    - pattern: "{team}-{role-type}"
      examples:
        - "platform-engineer"
        - "security-auditor"
        - "data-analyst"

    # Service-based naming
    - pattern: "{service}-{action}-role"
      examples:
        - "payment-service-operator-role"
        - "user-api-viewer-role"
        - "notification-manager-role"

  rules:
    - "Use lowercase with hyphens"
    - "Be descriptive but concise"
    - "Include scope indicators (cluster-, namespace-)"
    - "Avoid generic names (admin, user)"
```

### Role Documentation

```markdown
# Role Documentation Template

## Role: production-deployment-manager

### Purpose

Manages production deployments with approval workflow

### Permissions

- **Read**: All resources in production namespace
- **Write**: Deployments (with approval)
- **Execute**: Rollback operations

### Assigned To

- Groups: `sre-team`, `senior-developers`
- Service Accounts: `ci-cd-prod`

### Conditions

- MFA required
- Business hours only (Mon-Fri 9AM-5PM UTC)
- Requires approval from 2 team leads

### Dependencies

- Inherits from: `production-viewer`
- Required roles: `mfa-authenticated`

### Audit Requirements

- All actions logged to security SIEM
- Monthly access review required
```

## Security Best Practices

### Regular Audits

```python
# rbac-auditor.py
import datetime
from typing import List, Dict

class RBACSecurityAuditor:
    def __init__(self):
        self.audit_checks = [
            self.check_over_privileged_users,
            self.check_stale_permissions,
            self.check_service_account_usage,
            self.check_dangerous_permissions,
            self.check_separation_of_duties
        ]

    def run_security_audit(self) -> Dict:
        """Run comprehensive RBAC security audit"""
        audit_results = {
            'timestamp': datetime.datetime.now(),
            'findings': [],
            'metrics': {},
            'recommendations': []
        }

        for check in self.audit_checks:
            result = check()
            audit_results['findings'].extend(result['findings'])
            audit_results['metrics'].update(result['metrics'])

        audit_results['risk_score'] = self.calculate_risk_score(
            audit_results['findings']
        )

        return audit_results

    def check_over_privileged_users(self) -> Dict:
        """Identify users with excessive permissions"""
        findings = []

        # Query users with admin roles
        admin_users = self.get_users_with_role('*-admin')

        for user in admin_users:
            usage = self.get_permission_usage(user, days=90)

            if usage['used_permissions_ratio'] < 0.1:
                findings.append({
                    'severity': 'HIGH',
                    'type': 'over-privileged',
                    'user': user['email'],
                    'message': f"User has admin access but only uses {usage['used_permissions_ratio']*100:.1f}% of permissions",
                    'recommendation': 'Review and reduce permissions'
                })

        return {
            'findings': findings,
            'metrics': {
                'over_privileged_users': len(findings),
                'admin_user_count': len(admin_users)
            }
        }

    def check_dangerous_permissions(self) -> Dict:
        """Check for dangerous permission combinations"""
        dangerous_combos = [
            (['secrets:delete', 'secrets:create'], 'Can replace secrets'),
            (['rbac:*', 'pods:exec'], 'Can escalate privileges'),
            (['nodes:*', 'pods:create'], 'Can compromise nodes')
        ]

        findings = []

        for user in self.get_all_users():
            user_perms = self.get_effective_permissions(user)

            for perms, risk in dangerous_combos:
                if all(p in user_perms for p in perms):
                    findings.append({
                        'severity': 'CRITICAL',
                        'type': 'dangerous-permissions',
                        'user': user['email'],
                        'permissions': perms,
                        'risk': risk
                    })

        return {'findings': findings, 'metrics': {}}
```

### Separation of Duties

```yaml
# separation-of-duties.yaml
apiVersion: rbac/v1
kind: SeparationOfDuties
metadata:
  name: security-controls
spec:
  incompatibleRoles:
    # Development and Production
    - roles: ["dev-admin", "prod-admin"]
      reason: "Prevent dev changes in production"

    # Approval and Execution
    - roles: ["change-approver", "change-executor"]
      reason: "Ensure two-person control"

    # Audit and Operations
    - roles: ["security-auditor", "system-operator"]
      reason: "Maintain audit independence"

  requiredApprovals:
    - action: "production-deployment"
      approvers:
        - role: "tech-lead"
        - role: "sre-oncall"
      minimumApprovals: 2

    - action: "rbac-modification"
      approvers:
        - role: "security-admin"
        - role: "platform-lead"
      minimumApprovals: 1

  mutualExclusion:
    - name: "billing-separation"
      roles:
        create: "billing-creator"
        approve: "billing-approver"
        execute: "billing-executor"
```

## Operational Best Practices

### Role Lifecycle Management

```python
# role-lifecycle.py
class RoleLifecycleManager:
    def __init__(self):
        self.lifecycle_stages = [
            'proposed',
            'reviewed',
            'approved',
            'active',
            'deprecated',
            'retired'
        ]

    def manage_role_lifecycle(self, role_name: str):
        """Manage the complete lifecycle of a role"""

        role = self.get_role(role_name)

        # Check role usage
        usage_metrics = self.get_usage_metrics(role_name, days=30)

        # Lifecycle decisions
        if role['stage'] == 'active':
            if usage_metrics['user_count'] == 0:
                self.propose_deprecation(role_name,
                    reason="No active users in 30 days")

            elif usage_metrics['permission_usage'] < 0.2:
                self.propose_modification(role_name,
                    reason="Low permission utilization")

        elif role['stage'] == 'deprecated':
            if usage_metrics['user_count'] == 0:
                self.retire_role(role_name)

    def automated_review_schedule(self):
        """Schedule for automated role reviews"""
        return {
            'daily': [
                'check_critical_roles',
                'verify_emergency_access'
            ],
            'weekly': [
                'audit_privileged_roles',
                'review_service_accounts'
            ],
            'monthly': [
                'full_permission_audit',
                'role_usage_analysis'
            ],
            'quarterly': [
                'role_consolidation_review',
                'compliance_audit'
            ]
        }
```

### Emergency Access Procedures

```yaml
# emergency-access.yaml
apiVersion: rbac/v1
kind: EmergencyAccess
metadata:
  name: break-glass-procedure
spec:
  triggers:
    - type: "manual"
      authorizedBy: ["security-team", "platform-lead"]

    - type: "automatic"
      conditions:
        - "critical-incident-active"
        - "on-call-engineer-present"

  procedure:
    - step: "authenticate"
      requirements:
        - mfa: required
        - justification: required

    - step: "grant-access"
      role: "emergency-responder"
      duration: "4h"
      permissions:
        - resources: ["*"]
          verbs: ["*"]
          namespaces: ["*"]

    - step: "audit"
      actions:
        - log_all_actions: true
        - notify: ["security-team", "compliance-team"]
        - require_report: true

  post-incident:
    - revoke_access: "automatic"
    - review_actions: "required"
    - update_runbook: "if-needed"
```

## Monitoring and Metrics

### RBAC Metrics Dashboard

```yaml
# rbac-metrics.yaml
apiVersion: monitoring/v1
kind: RBACMetrics
metadata:
  name: rbac-dashboard
spec:
  metrics:
    # Usage metrics
    - name: "rbac_role_assignments_total"
      type: gauge
      labels: ["role", "namespace"]

    - name: "rbac_permission_checks_total"
      type: counter
      labels: ["user", "resource", "verb", "allowed"]

    - name: "rbac_role_binding_changes_total"
      type: counter
      labels: ["action", "role", "user"]

    # Security metrics
    - name: "rbac_privileged_users_count"
      type: gauge
      labels: ["role_type"]

    - name: "rbac_failed_access_attempts"
      type: counter
      labels: ["user", "resource", "reason"]

    # Operational metrics
    - name: "rbac_evaluation_duration_seconds"
      type: histogram
      buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1.0]

  alerts:
    - name: "HighPrivilegedUserCount"
      expr: "rbac_privileged_users_count > 50"
      severity: warning

    - name: "UnusedRoleDetected"
      expr: "rbac_role_assignments_total == 0"
      for: "7d"
      severity: info

    - name: "FrequentAccessDenials"
      expr: "rate(rbac_failed_access_attempts[5m]) > 10"
      severity: warning
```

### Compliance Reporting

```python
# compliance-reporter.py
class RBACComplianceReporter:
    def generate_compliance_report(self, standard='SOC2'):
        """Generate compliance report for RBAC controls"""

        report = {
            'standard': standard,
            'period': self.get_reporting_period(),
            'controls': {}
        }

        # Access Control
        report['controls']['AC-2'] = {
            'title': 'Account Management',
            'status': self.check_account_management(),
            'evidence': [
                self.get_user_provisioning_logs(),
                self.get_access_reviews(),
                self.get_termination_procedures()
            ]
        }

        # Least Privilege
        report['controls']['AC-6'] = {
            'title': 'Least Privilege',
            'status': self.check_least_privilege(),
            'evidence': [
                self.get_permission_analysis(),
                self.get_role_assignments(),
                self.get_privilege_usage_stats()
            ]
        }

        # Separation of Duties
        report['controls']['AC-5'] = {
            'title': 'Separation of Duties',
            'status': self.check_separation_of_duties(),
            'evidence': [
                self.get_incompatible_roles(),
                self.get_approval_workflows(),
                self.get_dual_control_procedures()
            ]
        }

        return report
```

## Migration Strategies

### Legacy System Migration

```yaml
# migration-strategy.yaml
apiVersion: rbac/v1
kind: MigrationPlan
metadata:
  name: legacy-rbac-migration
spec:
  phases:
    - name: "assessment"
      duration: "2w"
      tasks:
        - "Inventory existing permissions"
        - "Map users to roles"
        - "Identify permission gaps"
        - "Plan role hierarchy"

    - name: "pilot"
      duration: "4w"
      tasks:
        - "Migrate test environment"
        - "Create initial roles"
        - "Test with pilot users"
        - "Gather feedback"

    - name: "rollout"
      duration: "8w"
      strategy: "phased"
      tasks:
        - "Migrate by department"
        - "Implement dual-running period"
        - "Monitor for issues"
        - "Provide training"

    - name: "cleanup"
      duration: "2w"
      tasks:
        - "Remove legacy permissions"
        - "Audit final state"
        - "Document changes"
        - "Archive old system"

  rollback:
    enabled: true
    checkpoints: ["after-pilot", "50%-rollout", "pre-cleanup"]
```

## Troubleshooting Guide

### Common Issues and Solutions

```yaml
# troubleshooting-guide.yaml
apiVersion: rbac/v1
kind: TroubleshootingGuide
metadata:
  name: rbac-issues
spec:
  issues:
    - symptom: "User cannot access resource despite having role"
      causes:
        - "Namespace mismatch"
        - "RoleBinding not created"
        - "Cache not updated"
      solutions:
        - "Verify namespace in RoleBinding"
        - "Check RoleBinding exists: kubectl get rolebinding -A | grep <user>"
        - "Clear RBAC cache: hxb rbac cache clear"

    - symptom: "Permission denied after role change"
      causes:
        - "Token not refreshed"
        - "Propagation delay"
        - "Conflicting deny rules"
      solutions:
        - "Re-authenticate to get new token"
        - "Wait 30-60 seconds for propagation"
        - "Check for explicit deny rules"

    - symptom: "Service account cannot authenticate"
      causes:
        - "Token expired"
        - "Secret not mounted"
        - "RBAC not configured"
      solutions:
        - "Recreate service account token"
        - "Verify secret mount in pod spec"
        - "Create appropriate RoleBinding"
```

## Automation Tools

### RBAC Management Scripts

```python
# rbac-automation.py
class RBACAutomation:
    def __init__(self):
        self.templates = self.load_templates()

    def onboard_new_team(self, team_name, team_members):
        """Automated team onboarding"""

        # Create namespace
        namespace = f"team-{team_name}"
        self.create_namespace(namespace)

        # Create team roles
        roles = [
            self.create_role_from_template('team-developer', namespace),
            self.create_role_from_template('team-viewer', namespace)
        ]

        # Create group
        group = self.create_group(f"{team_name}-team", team_members)

        # Bind roles
        self.create_rolebinding(
            name=f"{team_name}-developers",
            role='team-developer',
            group=group,
            namespace=namespace
        )

        # Set up monitoring
        self.configure_monitoring(namespace)

        # Send welcome email
        self.send_onboarding_email(team_members, namespace)

        return {
            'namespace': namespace,
            'roles': roles,
            'group': group,
            'status': 'completed'
        }
```

## Related Documentation

- [RBAC Overview](overview.md)
- [Permission Model](permission-model.md)
- [Role Mappings](role-mappings.md)
- [Security Architecture](../../security/architecture.md)
