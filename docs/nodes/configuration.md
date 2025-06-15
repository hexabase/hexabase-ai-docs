# Node Configuration

This guide covers advanced configuration options for dedicated nodes in Hexabase.AI. While default settings are optimized for general use, you may need to customize your nodes for specific workloads.

## Node Labels and Taints

Labels and taints are the primary mechanisms for controlling how pods are scheduled onto your nodes.

- **Labels**: Used with `nodeSelector` and `nodeAffinity` to attract pods to a node.
- **Taints**: Used to repel pods from a node, unless they have a matching `toleration`.

### Common Labeling Schemes

- **By Workload Type**: `workload-type=database`, `workload-type=frontend`, `workload-type=ml`
- **By Environment**: `environment=production`, `environment=staging`
- **By Hardware**: `gpu=nvidia-a10g`, `disk=fast-ssd`
- **By Team**: `team=backend`, `team=data-science`

### Common Taints

- **Dedicated Hardware**: Tainting a GPU node (`gpu=true:NoSchedule`) ensures that only pods specifically requesting a GPU will be scheduled there.
- **Node Maintenance**: Before performing maintenance, you can manually taint a node with `maintenance=true:NoExecute`. The `NoExecute` effect will evict any running pods that do not tolerate the taint.

### Updating Labels and Taints

You can add or remove labels and taints from a node at any time via the HKS UI or CLI.

```bash
# Add a new label to a node
hks node label my-node-01 owner=sre-team

# Add a new taint to a node
hks node taint my-node-01 sensitive=true:NoSchedule

# Remove a taint from a node
hks node taint my-node-01 sensitive:NoSchedule-
```

## Node Pools

A Node Pool is a group of dedicated nodes that share the same configuration (instance type, disk size, labels, taints). Using node pools simplifies management when you need multiple nodes of the same type.

```bash
# Create a node pool with 3 identical nodes
hks nodepool create production-workers \
  --node-type c5.xlarge \
  --node-count 3 \
  --labels "pool=production-workers" \
  --enable-autoscaling --min-nodes 2 --max-nodes 10
```

### Autoscaling Node Pools

When autoscaling is enabled on a node pool, Hexabase.AI will automatically add or remove nodes based on resource demand.

- **Scale-Up**: If there are pending pods that cannot be scheduled due to insufficient resources in the pool, a new node is added (up to `max-nodes`).
- **Scale-Down**: If a node in the pool is under-utilized for a specified period and its pods can be safely rescheduled elsewhere, it is drained and terminated (down to `min-nodes`).

## Custom Node Configuration (Enterprise Plan)

For advanced use cases, Enterprise Plan customers can apply custom configurations to their nodes using a `NodeConfig` resource.

### Custom Kernel Parameters

You can tune `sysctl` kernel parameters for specific workloads, such as high-performance networking or database applications.

```yaml
apiVersion: hks.io/v1
kind: NodeConfig
metadata:
  name: high-performance-net
spec:
  # Apply this config to nodes with this label
  nodeSelector:
    workload-type: "real-time-bidding"

  # Kernel settings to apply
  kernel:
    sysctl:
      net.core.somaxconn: "65535"
      net.ipv4.tcp_max_syn_backlog: "16384"
      vm.max_map_count: "262144"
```

### Custom Startup Scripts

Run a custom script on node startup to perform actions like:

- Installing third-party monitoring or security agents.
- Downloading and caching large datasets.
- Performing custom hardware configuration.

```yaml
apiVersion: hks.io/v1
kind: NodeConfig
metadata:
  name: install-custom-agent
spec:
  nodeSelector:
    team: "security"

  startupScript: |
    #!/bin/bash
    set -e
    echo "Installing custom security agent..."
    curl -sSL https://my-agent.com/install.sh | bash
    systemctl enable --now my-custom-agent
```

**Security Note**: All startup scripts are run in a sandboxed environment and are subject to review by the Hexabase.AI security team. Not all actions may be permitted.

## Managing Node Images

Hexabase.AI manages a set of optimized, hardened OS images for dedicated nodes. These images are based on common Linux distributions (like Ubuntu or Bottlerocket) and are pre-configured with the necessary components like the `kubelet`, container runtime, and HKS agents.

- **Automatic Updates**: HKS automatically rolls out new node images to apply security patches and OS updates in a non-disruptive, rolling fashion.
- **Custom Images (Enterprise Plan)**: For organizations with strict requirements to use their own "golden" OS images, HKS can work with you to integrate your custom image into the provisioning pipeline, provided it meets certain security and compatibility standards.
