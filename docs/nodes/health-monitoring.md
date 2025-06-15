# Node Health Monitoring

Ensuring the health of the underlying nodes is fundamental to cluster stability and application performance. Hexabase.AI provides a comprehensive, automated system for monitoring the health of every node in your cluster, both shared and dedicated.

## Automated Health Checks

The HKS control plane continuously monitors every node for a variety of health signals. It uses a combination of the `kubelet` status and its own node-agent metrics.

### Key Monitored Conditions

- **Node Status**: The primary status reported by Kubernetes. The ideal state is `Ready`.
- **`Ready`**: The node is healthy and can accept new pods.
- **`NotReady`**: The node has failed a health check and cannot accept new pods. HKS will automatically begin investigating the cause.

- **Resource Pressure**: The node is running low on critical resources.
- **`MemoryPressure`**: Available memory on the node is low. Kubernetes will stop scheduling new pods and may begin evicting existing pods.
- **`DiskPressure`**: Available disk space on the root or image volume is low. This can prevent new images from being pulled or new pods from starting.
- **`PIDPressure`**: The number of available process IDs on the node is low.

- **Network Health**:
- **`NetworkUnavailable`**: The network for the node has not been properly configured or is experiencing issues.

## Node Problem Detector

Hexabase.AI runs the **Node Problem Detector** on every node. This is a background service that actively monitors for common node-level issues that might not be immediately visible to Kubernetes, such as:

- Hardware issues (bad disks, CPU faults).
- Kernel deadlocks or panics.
- Corrupted file systems.
- Issues with the container runtime (e.g., Docker or containerd becoming unresponsive).

When the Node Problem Detector finds an issue, it automatically adds a **taint** to the node and reports the condition to the HKS control plane.

## Automated Remediation

When a node is determined to be unhealthy, the HKS AIOps engine initiates an automated remediation process.

### The "Cordon and Drain" Process

1.  **Cordon**: The unhealthy node is immediately marked as "unschedulable" (`cordoned`). This prevents the Kubernetes scheduler from placing any new pods on it.
2.  **Drain**: The system gracefully evicts the existing pods from the unhealthy node.
    - For pods that are part of a `Deployment` or `StatefulSet`, the corresponding controller will automatically create replacement pods on other healthy nodes in the cluster.
    - This process respects `PodDisruptionBudgets` to ensure your application's availability is maintained.
3.  **Investigate/Replace**:
    - For transient issues (like a temporary `MemoryPressure` event), the AIOps engine may simply monitor the node to see if it recovers.
    - For persistent failures (like a `NotReady` status or a hardware issue), the system will automatically provision a new, healthy node and terminate the failing one.

This automated self-healing capability ensures that node-level failures have a minimal impact on your applications.

## Monitoring Node Health in the UI

The Hexabase.AI UI provides a dedicated "Nodes" section where you can view the health of your entire fleet.

- **Node List View**: See a list of all your nodes with their current status, IP addresses, resource allocation (CPU/memory), and the number of pods they are running.
- **Detailed Node View**: Click on any node to see a detailed dashboard with:
  - Time-series graphs of CPU, memory, disk, and network usage.
  - A list of all pods currently scheduled on the node.
  - Any active conditions or taints applied to the node.
  - A log of recent events related to the node, such as health checks and scheduling decisions.

## Configuring Node Health Alerts

You can configure alerts to be notified of node health issues.

```yaml
# alert-rule-node-notready.yaml
apiVersion: hks.io/v1
kind: AlertRule
metadata:
  name: node-not-ready-alert
spec:
  condition:
    type: metric
    # The 'kube_node_status_condition' metric tracks health conditions
    query: 'kube_node_status_condition{condition="Ready",status="false"} == 1'
    for: 5m

  severity: critical
  summary: "Node {{ $labels.node }} is NotReady."
  description: "Node {{ $labels.node }} has been in a NotReady state for over 5 minutes. HKS will begin automated remediation."

  notification:
    channel: "pagerduty-sre-oncall"
```

This alert would notify the on-call SRE team via PagerDuty if any node remains in a `NotReady` state for more than 5 minutes, providing an extra layer of visibility on top of the automated remediation process.
