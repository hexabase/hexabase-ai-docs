# Dedicated VM Management

While Hexabase.AI provides a shared node pool for general-purpose workloads, the **Team** and **Enterprise** plans allow you to provision and manage dedicated Virtual Machines (VMs) for your workspaces. Dedicated nodes provide guaranteed resources, enhanced security isolation, and the ability to run specialized workloads.

## Why Use Dedicated Nodes?

- **Guaranteed Performance**: The CPU, memory, and I/O of a dedicated node are reserved exclusively for your workloads, eliminating the "noisy neighbor" problem.
- **Security and Compliance**: Some compliance standards (like PCI-DSS) may require workloads to run on dedicated, isolated hardware.
- **Specialized Hardware**: You can provision nodes with specific hardware, such as GPUs for machine learning, or high-memory instances for in-memory databases.
- **Custom Configurations**: Apply custom kernel settings, install specific drivers, or run privileged daemons that are not allowed on the shared node pool.

## Provisioning a Dedicated Node

Dedicated nodes can be provisioned directly from the Hexabase.AI UI or via the CLI.

### Using the CLI

```bash
# Provision a new dedicated node for your organization
hb node create my-gpu-node-01 \
  --type g5.2xlarge \
  --disk-size 200Gi \
  --region us-east-1 \
  --labels "workload-type=ml,gpu=nvidia-a10g" \
  --taints "gpu=true:NoSchedule"
```

**Key Parameters**:

- `--type`: The instance type/size from the underlying cloud provider (e.g., `m5.xlarge` on AWS).
- `--disk-size`: The size of the root disk.
- `--labels`: Kubernetes labels to apply to the node. This is crucial for scheduling pods to specific nodes.
- `--taints`: Kubernetes taints to apply to the node. Taints prevent general-purpose pods from being scheduled onto the node unless they have a matching "toleration".

## Assigning Nodes to Workspaces

Once a node is provisioned at the organization level, an `organization_admin` can assign it to one or more workspaces.

```bash
# Assign the newly created node to the 'ml-research' workspace
hb node assign my-gpu-node-01 --workspace ml-research
```

A node can be exclusively assigned to one workspace or shared between multiple workspaces within the same organization.

## Scheduling Pods to Dedicated Nodes

To ensure your application's pods land on your dedicated nodes, you use standard Kubernetes scheduling mechanisms: `nodeSelector` or `nodeAffinity`.

### Using `nodeSelector`

This is the simplest method. Add a `nodeSelector` to your pod spec that matches the labels you applied to the node.

```yaml
# pod-with-nodeselector.yaml
apiVersion: v1
kind: Pod
metadata:
  name: cuda-pod
spec:
  containers:
    - name: cuda-container
      image: nvidia/cuda:11.8.0-base-ubuntu22.04
  # This pod will only be scheduled on nodes with this label
  nodeSelector:
    workload-type: ml
```

### Using `nodeAffinity`

Node affinity provides more expressive rules, such as "preferred" scheduling or matching on a set of values.

```yaml
# pod-with-nodeaffinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processing-job
spec:
  # ...
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: workload-type
                operator: In
                values:
                  - data-processing
                  - analytics
```

You must also add a **toleration** to your pod spec to allow it to be scheduled on a tainted node.

```yaml
# Pod spec continued...
tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

## Monitoring Dedicated Nodes

The HKS UI provides a dedicated view for node health and utilization.

- **CPU, Memory, and Disk Usage**: See the real-time and historical resource consumption of your nodes.
- **Pod Density**: View all the pods currently running on a specific node.
- **Node Conditions**: See the status of the node (e.g., `Ready`, `DiskPressure`, `MemoryPressure`).
- **AIOps Insights**: The AIOps engine will provide recommendations for your dedicated nodes, such as rightsizing recommendations if a node is consistently under-utilized.

## Node Maintenance and Upgrades

Hexabase.AI handles the underlying OS patching and security updates for your dedicated VMs. When a major Kubernetes version upgrade is required, the process is managed with zero downtime for your applications.

1.  A new, upgraded node is provisioned.
2.  The old node is **cordoned**, which prevents new pods from being scheduled on it.
3.  Pods from the old node are gracefully **drained** (evicted) and rescheduled by Kubernetes onto the new node.
4.  Once the old node is empty, it is de-provisioned.

This entire process is automated and orchestrated by the HKS control plane.
