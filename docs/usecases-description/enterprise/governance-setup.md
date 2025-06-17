# Setup Centralized Governance and SSO Integration

## 1. Use Case Name
Setup Centralized Governance and SSO Integration

## 2. Actors
- **Primary Actor:** IT Department Administrator
- **Secondary Actors:** Hexabase.AI System, SSO Provider (Okta/Azure AD), Enterprise Users

## 3. Preconditions
- Enterprise plan is already contracted
- Existing SSO provider (Okta, Azure AD, etc.) is operational
- Company's internal organizational structure and role definitions are clarified
- Personnel with understanding of SAML/OIDC technical specifications are available

## 4. Success Scenario (Basic Flow)
1. IT department administrator logs into Hexabase.AI enterprise dashboard
2. Administrator accesses "Organization Settings" → "SSO Integration" section
3. The system displays SSO configuration wizard
4. Administrator selects SSO provider type (Okta)
5. Administrator enters Okta metadata URL, Entity ID, and certificate information
6. The system executes SSO configuration verification
7. Administrator tests SSO authentication with test user
8. The system confirms SSO authentication success
9. Administrator navigates to "Custom Role Management" section
10. Administrator creates custom roles based on company's organizational structure
11. Administrator defines roles corresponding to each department (Finance, Engineering, Operations)
12. Administrator sets detailed permissions (resource creation, deletion, viewing, etc.) for each role
13. The system applies role configuration to RBAC system
14. Administrator configures SSO attribute mapping, mapping Okta group information to Hexabase roles
15. Administrator configures "Organization Policy" settings including password requirements, session management, etc.
16. The system saves all configurations and enables SSO integration

## 5. Alternative Scenarios (Alternative Flows)
**5a. SSO Authentication Failure**
- 7a. SSO authentication with test user fails
- 7b. The system displays detailed error logs (certificate, metadata errors, etc.)
- 7c. Administrator reviews and corrects SSO provider settings
- 7d. Administrator retests SSO configuration

**5b. Attribute Mapping Error**
- 14a. SSO attribute mapping does not work correctly
- 14b. User is not authenticated with expected role
- 14c. Administrator reviews Okta group settings and mapping configuration
- 14d. Administrator corrects attribute mapping and retests

**5c. Permission Configuration Conflict**
- 12a. Contradictions or conflicts exist in configured permissions
- 12b. The system displays permission conflict warnings
- 12c. Administrator reviews permission settings and resolves conflicts

**5d. Existing User Migration Issues**
- 16a. After SSO enablement, existing non-SSO users cannot access
- 16b. The system presents migration guide and temporary access methods
- 16c. Administrator executes phased migration plan

## 6. Postconditions
- SSO provider and Hexabase.AI are properly integrated
- Custom roles corresponding to company's internal organizational structure are configured
- Users can seamlessly authenticate with company's ID provider
- Fine-grained RBAC permissions are enabled
- Organization-wide security policies are applied
- Centralized organizational management is achieved
- Audit logs are enabled and all activities are recorded 