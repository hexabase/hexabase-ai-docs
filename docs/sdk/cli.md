# CLI Tool

The Hexabase.AI command-line interface (`hks`) is the primary tool for developers and administrators to interact with the platform. It's a powerful, full-featured client that allows you to manage every aspect of your HKS environment.

## Installation

The `hks` CLI is available for macOS, Linux, and Windows.

### macOS (Homebrew)

```bash
brew install hexabase/tap/hks
```

### Linux

```bash
curl -sSL https://cli.hexabase.ai/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr https://cli.hexabase.ai/install.ps1 -useb | iex
```

## Authentication

The first time you run a command, the CLI will open a browser window to guide you through the authentication process.

```bash
# Run any command, e.g., 'hks get workspaces'
hks get workspaces

# A browser window opens. Log in with your HKS account.
# A token is securely stored in your local config file.
```

Your session token will be automatically refreshed. You only need to log in again if the refresh token expires or is revoked.

For **non-interactive environments** like CI/CD, you use a Service Account API key:

```bash
hks get pods --api-key $HKS_CI_CD_KEY
```

## Key Concepts and Commands

The `hks` CLI follows the structure `hks <verb> <noun> [name] [flags]`. This will be familiar to users of `kubectl`.

### Managing Workspaces and Orgs

- `hks get workspaces`: List all workspaces you have access to.
- `hks config set-workspace <name>`: Set the default workspace for subsequent commands.
- `hks create workspace <name>`: Create a new workspace (Org Admins only).
- `hks list-users`: List all users in your organization.

### Managing Applications

This is the most common set of commands for developers.

- `hks get deployments`: List all application deployments in the current workspace.
- `hks logs -f deployment/<name>`: Stream the logs for a running application.
- `hks describe deployment <name>`: Get detailed information and events for a deployment.
- `hks restart deployment <name>`: Perform a rolling restart of an application.
- `hks exec <pod-name> -- /bin/bash`: Get an interactive shell inside a running pod for debugging.

### Managing Backups and Restores

- `hks get backups`: List all available backups.
- `hks backup create <name> --include-namespaces <ns>`: Create a new backup.
- `hks restore create <name> --from-backup <backup-name>`: Restore from a backup.

### Managing Functions

- `hks function list`: List all deployed serverless functions.
- `hks function deploy`: Deploy a function from the current directory's `function.yaml`.
- `hks function invoke-local <file>`: Test a function locally.
- `hks function logs -f <name>`: View logs for a function.

## `kubectl` Integration

The `hks` CLI is designed to work with `kubectl`, not replace it entirely. HKS automatically manages your `kubeconfig` file to provide seamless access to your workspaces.

### How it Works

1.  When you run `hks config set-workspace <name>`, the CLI fetches temporary, scoped credentials for that workspace.
2.  It then automatically updates your `~/.kube/config` file with a new context for the workspace.
3.  The context is named `hks-<org-name>/<workspace-name>`.

### Using `kubectl`

After setting your workspace with the `hks` CLI, you can immediately use `kubectl` with the correct context.

```bash
# Set the active workspace in HKS
hks config set-workspace production

# Your kubeconfig is now pointing to the 'production' workspace.
# You can use kubectl as you normally would.
kubectl get pods
kubectl apply -f my-deployment.yaml
```

This integration provides the best of both worlds: the high-level, user-friendly management of the `hks` CLI, and the low-level, powerful capabilities of `kubectl` when you need them.

## Output Formats

You can change the output format for most `get` commands.

- `-o yaml`: Output the full resource definition in YAML.
- `-o json`: Output the full resource definition in JSON.
- `-o wide`: Output additional columns of information in a table view.

```bash
# Get the full YAML for a deployment
hks get deployment my-app -o yaml
```

## Shell Completion

To make the CLI easier to use, you can enable shell completion for `bash` or `zsh`.

```bash
# Add to your .bashrc or .zshrc
source <(hks completion zsh)
```

This will enable tab-completion for commands, nouns, and even resource names.
