# Hexabase KaaS Service Scope of Services and Responsibility Boundary

Hexabase KaaS (Kubernetes as a Service) is a platform that facilitates the operation of container applications with an intuitive UI and auxiliary functions that are fully compatible with Kubernetes and can be operated even by those without specialized knowledge.
The purpose of this document is to clarify the scope of service provision and the boundary of responsibility between our company (Hexabase) and the customer when using Hexabase KaaS.

## 1. Summary of Responsibility Boundary Points

The scope of liability in Hexabase KaaS follows the general cloud service liability sharing model. The table below summarizes the responsibility boundary for each type of service provision.

| Layer | Content | KaaS version | Other company's cloud version | On-premise version |
| :--- | :--- | :---: | :---: | :---: |
| **Application** | Application itself, data, security measures, container image management | **Customer** | **Customer** | **Customer** |
| **Kubernetes infrastructure** | Container orchestration, monitoring and logging capabilities, resource management, access control | **Hexabase** | **Hexabase** | **Hexabase** |
| **Virtual Infrastructure** | Virtual machines, virtual networks, virtual storage | **Hexabase** | **Customer (*1)** | **Customer (*1)** |
| **Physical Infrastructure** | Physical Servers, Network Devices, Data Center | **Hexabase** | **Customer (*1)** | **Customer (*1)** |

---
**(*1) For other companies' cloud and on-premise versions of infrastructure**

* **Cloud version of other companies:** The customer is responsible for managing the account of the cloud service (AWS, Azure, GCP, etc.) that the customer subscribes to and the Kubernetes (EKS, AKS, GKE, etc.) running on that account.
* **On-Premise Version:** You are responsible for managing your physical servers and virtualization infrastructure (Proxmox, etc.).

**[Construction and operation support]**
For the scope of the above (*1), Hexabase can also perform construction and operation on behalf of the customer by separately contracting for Hexabase's **Initial Construction Service** or **Managed Service**. Please contact us for details.

---

## 2. Details of Responsibility Boundary Points at Each Layer

### 2.1. Application Layer (Scope of Customer's Responsibility)

Hexabase provides a powerful platform and functionality to run your application, but is not responsible for managing the application itself.

| Item | Scope of Customer Responsibility |
| :--- | :--- |
| **Application Operation Assurance** | Ensuring the proper operation, performance, and quality of the application developed and deployed by the customer. |
| **Application Security** | Vulnerability countermeasures for application code, use of appropriate libraries, and container image vulnerability scanning and countermeasures. |
| **Data Backup and Restoration** | Development of backup plans for persistent data used by the application, such as databases and files, execution of such plans on a regular basis, and data restoration work by the customer itself in the event of a failure. |
| **Updating Container Images** | Preparing and deploying (modernizing) new container images with additional application functionality, bug fixes, and security patches applied by the customer itself. |

### 2.2. Kubernetes Platform Layer (Hexabase's Scope of Responsibility)

Hexabase will be responsible for managing and operating the complex Kubernetes environment so that the customer can focus on operating the application.

| Item | Scope of Hexabase Offerings |
| :--- | :--- |
| **Container Orchestration** | Provides automated container deployment, scaling, and lifecycle management capabilities. |
| **Resource Management and Optimization** | Provision of functions to efficiently manage and optimize CPU, memory, storage, and other resources required by containers. |
| **Platform Monitoring and Logging** | Provides integrated functionality for monitoring, logging, and analyzing the availability and performance of Kubernetes clusters and containers. |
| **Networking and Storage Management** | Provides networking capabilities for secure communication between containers and storage capabilities for data persistence. |
| **Security and Compliance** | Provides functions for maintaining security of the Kubernetes cluster itself, access control, network policies, and resource isolation in multi-tenant environments. |
| **Platform Updates** | Platform maintenance, such as upgrading Kubernetes itself and applying security patches. |
| **VM/Container Integration Management** | Provides the ability to centrally manage virtual machines (VMs) and containers on Kubernetes. |
| **Support and Documentation** | Provision of technical support and various documentation to ensure smooth use of the service by customers. |

### 2.3. Infrastructure Layer (divided by type of provision)

The division of responsibility for the infrastructure layer depends on the type of provision chosen by the customer.

#### **If you use the KaaS version (Hexabase's area of responsibility)**
Hexabase provides the physical servers, network, storage, and the infrastructure to virtualize them, all fully managed by Hexabase. Customers can use the service as if it were serverless, without being aware of the existence of infrastructure.

#### **In case of using another company's cloud or on-premise version (customer's responsibility)**
As mentioned above, the construction, management, and operation of the underlying cloud environment or on-premise physical/virtual environment is the responsibility of the customer.