# Deploy Application

## 1. Use Case Name
Deploy Application

## 2. Actors
- **Primary Actor:** Individual Developer
- **Secondary Actors:** HKS CLI, Hexabase.AI System, Container Registry

## 3. Preconditions
- The developer owns a workspace
- Application (Node.js backend, React frontend) is developed
- HKS CLI is installed and authentication configuration is completed
- Docker container image is created

## 4. Success Scenario (Basic Flow)
1. The developer executes deployment command using HKS CLI
2. The system places the application container in the shared node pool
3. The system pulls the container image from the private registry
4. The system creates Kubernetes deployment and service
5. The developer confirms that a database is needed
6. The developer selects a PostgreSQL instance from the HKS marketplace
7. The system creates persistent storage volume and provisions PostgreSQL
8. The system configures connection between application and database
9. The system displays application URL and access information
10. The developer verifies application operation

## 5. Alternative Scenarios (Alternative Flows)
**5a. Deployment Failure**
- 4a. Container image pull fails
- 4b. The system displays error logs
- 4c. The developer checks image existence and access permissions
- 4d. The developer executes redeployment after correction

**5b. Resource Shortage**
- 2a. Resources are insufficient in the shared node pool
- 2b. The system displays waiting status message
- 2c. The system automatically continues deployment when resources become available

**5c. Storage Limit Exceeded**
- 7a. Persistent storage limit is exceeded
- 7b. The system displays limit exceeded error message
- 7c. The developer deletes unnecessary data or upgrades the plan

## 6. Postconditions
- Application is running in the shared node pool
- PostgreSQL database is provisioned and connected to the application
- Application is accessible via public URL
- Resource usage is being monitored 