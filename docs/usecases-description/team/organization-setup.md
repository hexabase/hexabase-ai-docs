# Setup Organization and Team

## 1. Use Case Name
Setup Organization and Team

## 2. Actors
- **Primary Actor:** Organization Administrator
- **Secondary Actors:** Hexabase.AI System, Team Members, Email Delivery System

## 3. Preconditions
- Organization administrator has signed up for the team plan
- Email address list of team members to invite is prepared
- Basic organization information (company name, industry, etc.) is determined

## 4. Success Scenario (Basic Flow)
1. Organization administrator logs into the Hexabase.AI platform
2. The system displays the organization creation wizard
3. Organization administrator enters organization name (e.g., `MyStartupInc`)
4. Organization administrator selects organization industry and size
5. The system creates the organization and grants organization administrator permissions to the administrator
6. The system displays the team member invitation screen
7. Organization administrator enters DevOps engineer's email address
8. Organization administrator sets "Organization Administrator" role for DevOps engineer
9. Organization administrator enters other team members' email addresses
10. Organization administrator sets "Organization User" role for other members
11. Organization administrator clicks the "Send Invitations" button
12. The system sends invitation emails to each member
13. Team members receive invitation emails and click invitation links
14. Team members complete account creation or login
15. The system adds team members to the organization and grants appropriate roles
16. The system displays organization dashboard and confirms member list

## 5. Alternative Scenarios (Alternative Flows)
**5a. Invitation Email Sending Failure**
- 12a. Invitation emails are not sent due to email delivery system issues
- 12b. The system displays sending failure message
- 12c. Organization administrator manually copies invitation links and shares with members
- 12d. Or resends invitations later

**5b. Duplicate Organization Name**
- 5a. Entered organization name is already in use
- 5b. The system displays error message and alternatives
- 5c. Organization administrator enters a different organization name

**5c. Invitation Acceptance Expired**
- 14a. Team member does not access invitation link within validity period
- 14b. Invitation link becomes invalid
- 14c. Organization administrator sends invitation again

**5d. Permission Setting Error**
- 8a. Incorrect permissions are granted in role setting
- 8b. Organization administrator corrects roles in organization settings screen
- 8c. The system applies changed permissions

## 6. Postconditions
- Organization is created and organization administrator is configured
- DevOps engineer has organization administrator permissions
- Other team members have organization user permissions
- RBAC (Role-Based Access Control) is enabled
- All organization members can access the organization dashboard
- Billing management and resource management permissions are appropriately separated 