# First Login and Workspace Setup

## 1. Use Case Name
First Login and Workspace Setup

## 2. Actors
- **Primary Actor:** Individual Developer
- **Secondary Actors:** Hexabase.AI System

## 3. Preconditions
- The developer has already signed up for a Hexabase.AI account
- Internet connection is available
- Browser or HKS CLI is available

## 4. Success Scenario (Basic Flow)
1. The developer logs into the Hexabase.AI platform
2. The system detects that the user is a new user
3. The system automatically creates a personal workspace (e.g., `dev-workspace`)
4. The system assigns a private Kubernetes namespace to the developer
5. The system displays the workspace initial setup screen
6. The developer confirms or changes the workspace name
7. The system completes workspace setup
8. The system displays the dashboard and shows available resources and quotas

## 5. Alternative Scenarios (Alternative Flows)
**5a. Workspace Creation Failure**
- 4a. Workspace creation fails due to resource shortage in the system
- 4b. The system displays an error message
- 4c. The system provides a retry option
- 4d. The developer retries or contacts support

**5b. Network Connection Issues**
- 1a. Network connection is lost during login
- 1b. The system displays a timeout error
- 1c. The developer checks connection and attempts login again

## 6. Postconditions
- An isolated workspace dedicated to the developer is created
- A private Kubernetes namespace is assigned
- The developer can access the dashboard
- Resource quotas and limits are configured 