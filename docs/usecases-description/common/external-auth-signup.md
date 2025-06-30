# Sign Up to Hexabase.AI with External Authentication

## 1. Use Case Name
Sign Up to Hexabase.AI with External Authentication

## 2. Actors
- **Primary Actor:** New User
- **Secondary Actors:** Hexabase.AI System, External Authentication Provider (GitHub, Google)

## 3. Preconditions
- User has an account with external authentication provider (GitHub or Google)
- Internet connection is available
- User does not have a Hexabase.AI account

## 4. Success Scenario (Basic Flow)
1. User accesses the Hexabase.AI official website
2. User clicks the authentication provider's sign-up button
3. The system redirects user to external authentication provider
4. User authenticates with external authentication provider
5. User approves access permissions to Hexabase.AI
6. The system returns user to Hexabase.AI site
7. The system displays account setup screen
8. User selects usage plan
9. User agrees to terms of service and privacy policy
10. The system creates the account
11. The system guides user to dashboard

## 5. Alternative Scenarios (Alternative Flows)

### 5.1 Duplicate with Existing Account
- 7.1a. Email address is already registered
- 7.1b. The system displays "This account is already registered"
- 7.1c. User navigates to login page

### 5.2 Authentication Denial or Cancellation
- 5.2a. User cancels authentication with external authentication provider
- 5.2b. The system displays "Authentication was cancelled"
- 5.2c. User returns to sign-up page

### 5.3 External Authentication Service Failure
- 3.3a. External authentication provider service is unavailable
- 3.3b. The system displays "Authentication service is temporarily unavailable"
- 3.3c. User retries later or selects different authentication provider

## 6. Postconditions
- New user account is created in Hexabase.AI
- User is logged in
- Selected plan is applied
- Integration with external authentication provider is enabled
- User can access dashboard

## 7. Additional Notes
- For GitHub: Additional steps may occur due to two-factor authentication or private email settings
- For Google: Additional confirmation may be required for multiple account selection or corporate restrictions 