# Node Scaling Strategies

Scaling your node infrastructure is essential for handling variable application load while optimizing for cost. Hexabase.AI provides several strategies for both horizontal and vertical scaling of your dedicated nodes.

## Horizontal Scaling (Scaling Out)

Horizontal scaling involves adding more nodes to or removing nodes from your cluster. This is the most common scaling strategy for handling changes in application traffic.

### Node Pool Autoscaling

The primary mechanism for horizontal scaling is the **Node Pool Autoscaler**. As described in the [Node Configuration](./configuration.md) guide, you can enable autoscaling when you create a node pool.

```bash
# Create an autoscaling node pool
hks nodepool create web-workers \
  --node-type m5.large \
  --enable-autoscaling \
  --min-nodes 3 \
  --max-nodes 20
```

**How it works:**
The cluster autoscaler, managed by HKS, monitors for pods in the `Pending` state that cannot be scheduled due to a lack of resources (CPU, memory, or GPU).

- **Scale-Up**: If pending pods exist, and adding a new node to the pool would allow them to be scheduled, a new node is provisioned (up to the `max-nodes` limit).
- **Scale-Down**: The autoscaler periodically checks for nodes that are significantly under-utilized. If a node's workloads can be safely moved to other nodes in the pool, the node is cordoned, drained, and terminated (down to the `min-nodes` limit).

### AIOps-Powered Predictive Scaling (Enterprise Plan)

For workloads with predictable, cyclical traffic patterns (e.g., an e-commerce site with a daily traffic spike), the AIOps engine can enable predictive scaling.

1.  **Learning Phase**: The AIOps engine analyzes the historical resource usage of your node pool.
2.  **Prediction**: It builds a model to predict future demand.
3.  **Proactive Scaling**: It proactively scales up the node pool _before_ the anticipated traffic spike, ensuring that resources are available when needed and avoiding the slight delay of reactive scaling.

```yaml
# Enable predictive scaling on a node pool
apiVersion: hks.io/v1
kind: NodePool
metadata:
  name: web-workers
spec:
  # ... other node pool config ...
  autoscaling:
    enabled: true
    min: 3
    max: 20
    # Enable the AI-powered predictive mode
    mode: predictive
    learningPeriod: "14d" # Analyze the last 14 days of data
```

## Vertical Scaling (Scaling Up)

Vertical scaling involves increasing the resources (CPU, memory) of your existing nodes. This is less common than horizontal scaling for stateless applications but can be useful for specific stateful workloads like large databases.

### Manually Resizing a Node or Node Pool

You can manually change the instance type of a dedicated node or a node pool.

```bash
# Change the instance type for an entire node pool
hks nodepool update database-workers --node-type r5.2xlarge
```

**Process**:
Hexabase.AI will perform a **rolling replacement** to apply the change without downtime.

1.  A new node with the larger instance type (`r5.2xlarge`) is added to the pool.
2.  One of the old, smaller nodes is cordoned and drained.
3.  Its pods are rescheduled onto the new, larger node.
4.  The old node is terminated.
5.  This process repeats until all nodes in the pool have been replaced with the new instance type.

## Best Practices for Node Scaling

1.  **Prefer Horizontal Scaling**: For most web applications and microservices, horizontal scaling is more resilient and cost-effective than vertical scaling. Design your applications to be stateless so they can be scaled out easily.
2.  **Use Homogeneous Node Pools**: It is generally better to have separate, autoscaling node pools for different workload types (e.g., a pool for general-purpose web apps, a pool for GPU workloads) rather than a single, large pool of mixed instance types.
3.  **Configure Pod Disruption Budgets (PDBs)**: A PDB tells the cluster autoscaler how many of your application's pods must be running at all times. This prevents the autoscaler from draining too many nodes at once during a scale-down event and causing an outage for your application.
    ```yaml
    apiVersion: policy/v1
    kind: PodDisruptionBudget
    metadata:
      name: my-app-pdb
    spec:
      minAvailable: 2 # Always keep at least 2 pods running
      selector:
        matchLabels:
          app: my-app
    ```
4.  **Set Appropriate Resource Requests**: The autoscaler's decisions are based on the resource `requests` of your pods. If your pods don't have accurate requests set, the autoscaler will not function correctly. Use the HKS AIOps recommendations to rightsize your pod requests.
5.  **Use Taints for Special Workloads**: Ensure that your specialized, non-autoscaled nodes (e.g., for databases) are tainted so that the autoscaler doesn't try to schedule general-purpose pods onto them.
