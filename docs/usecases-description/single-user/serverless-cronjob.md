# Create Serverless Functions and CronJobs

## 1. Use Case Name
Create Serverless Functions and CronJobs

## 2. Actors
- **Primary Actor:** Individual Developer
- **Secondary Actors:** Hexabase.AI System, Email Service, Kubernetes Scheduler

## 3. Preconditions
- The developer owns a workspace
- The developer has Function creation permissions
- Business logic for summary email sending is prepared
- External service configuration for email sending (SMTP or API) is available

## 4. Success Scenario (Basic Flow)
1. The developer accesses the "Functions" section of the Hexabase.AI dashboard
2. The developer clicks the "Create New Function" button
3. The system displays the Function creation screen
4. The developer enters the Function name (e.g., `daily-summary-email`)
5. The developer selects the runtime (Node.js)
6. The developer enters the email sending business logic in the code editor
7. The developer configures environment variables (SMTP settings, API keys, etc.)
8. The developer clicks the "Create Function" button
9. The system deploys the Function and makes it executable
10. The developer navigates to the "CronJobs" section
11. The developer clicks the "Create New CronJob" button
12. The developer enters the schedule (e.g., daily at 9 AM) in cron format
13. The developer selects the previously created Function as the Function to execute
14. The developer clicks the "Create CronJob" button
15. The system registers the CronJob with the scheduler
16. The system displays setup completion message and next execution time

## 5. Alternative Scenarios (Alternative Flows)
**5a. Function Execution Error**
- 9a. An error occurs during Function deployment
- 9b. The system displays detailed error logs
- 9c. The developer checks code syntax errors or dependencies
- 9d. The developer fixes the code and redeploys

**5b. Environment Variable Configuration Issue**
- 7a. Required environment variables are not configured
- 7b. An error occurs during Function execution
- 7c. The system displays environment variable-related error messages
- 7d. The developer adds or corrects environment variables

**5c. CronJob Execution Failure**
- 15a. The Function fails during the first scheduled execution
- 15b. The system logs the error in execution logs
- 15c. The developer checks execution logs to identify the error cause
- 15d. The developer fixes the Function or CronJob configuration

**5d. Schedule Format Error**
- 12a. The entered cron format is invalid
- 12b. The system displays a validation error message
- 12c. The developer re-enters in correct cron format

## 6. Postconditions
- A serverless Function is created and deployed
- A CronJob is registered with the specified schedule
- The Function is configured to automatically execute at the specified time daily
- Function execution logs are available for review
- Alert settings for execution failures are enabled 