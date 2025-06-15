# ClickHouse Analytics

While most observability interactions (logs, metrics, traces) happen through the high-level HKS UI and APIs, Hexabase.AI provides direct access to the underlying ClickHouse database for advanced analytics and custom data exploration. This is a powerful feature for data scientists, analysts, and engineers who need to run complex, ad-hoc queries against their observability data.

## Why ClickHouse?

Hexabase.AI uses ClickHouse as the storage backend for logs, traces, and some metric data for several key reasons:

- **Blazing Speed**: ClickHouse is an open-source columnar database designed for Online Analytical Processing (OLAP). It can scan billions of rows and terabytes of data in milliseconds.
- **High Compression**: Its columnar nature allows for excellent data compression, reducing storage costs.
- **SQL Interface**: It uses a familiar SQL dialect, making it accessible to a wide range of users.
- **Scalability**: It is horizontally scalable, capable of handling petabytes of data.

## Connecting to ClickHouse

Direct access to ClickHouse is available on **Enterprise Plans**. You can connect using any standard SQL client that supports the ClickHouse JDBC or HTTP interface.

1.  **Get Credentials**: An Organization Admin can generate read-only database credentials from the HKS settings panel. This will include:
    - Hostname
    - Port
    - Database name
    - Username
    - Password
2.  **Configure Your Client**: Use a tool like DBeaver, DataGrip, or even the `clickhouse-client` CLI to connect to the provided endpoint. It is recommended to connect over a secure connection (e.g., via a VPN or private link established with your HKS environment).

## Key Data Tables

Your observability data is organized into several key tables within the `hks_data` database.

### `logs` table

This table contains all your log data.

| Column       | Type                  | Description                                                   |
| :----------- | :-------------------- | :------------------------------------------------------------ |
| `timestamp`  | `DateTime64(9)`       | The nanosecond-precision timestamp of the log entry.          |
| `trace_id`   | `String`              | The trace ID, if correlated with a distributed trace.         |
| `severity`   | `Enum(...)`           | The log level (e.g., `info`, `warn`, `error`).                |
| `message`    | `String`              | The raw log message.                                          |
| `resource`   | `Map(String, String)` | Kubernetes resource metadata (e.g., `pod_name`, `namespace`). |
| `attributes` | `Map(String, String)` | Structured log attributes parsed from JSON.                   |

**Example Query:**

```sql
-- Count the number of error logs per service in the last 24 hours
SELECT
    resource['k8s.container.name'] AS service,
    count() AS error_count
FROM logs
WHERE timestamp >= now() - INTERVAL 1 DAY
  AND severity = 'error'
GROUP BY service
ORDER BY error_count DESC;
```

### `traces` table

This table contains all the span data from distributed traces.

| Column           | Type                  | Description                                          |
| :--------------- | :-------------------- | :--------------------------------------------------- |
| `timestamp`      | `DateTime64(9)`       | The start time of the span.                          |
| `trace_id`       | `String`              | The ID of the trace this span belongs to.            |
| `span_id`        | `String`              | The unique ID of this span.                          |
| `parent_span_id` | `String`              | The ID of the parent span.                           |
| `service_name`   | `String`              | The name of the service that emitted the span.       |
| `span_name`      | `String`              | The name of the operation (e.g., `HTTP GET /users`). |
| `duration_ms`    | `Int64`               | The duration of the span in milliseconds.            |
| `attributes`     | `Map(String, String)` | Span attributes/tags (e.g., `http.status_code`).     |

**Example Query:**

```sql
-- Find the top 5 slowest API endpoints (p95 latency) in the last hour
SELECT
    service_name,
    span_name,
    quantile(0.95)(duration_ms) AS p95_latency
FROM traces
WHERE timestamp >= now() - INTERVAL 1 HOUR
  AND attributes['span.kind'] = 'server'
GROUP BY service_name, span_name
ORDER BY p95_latency DESC
LIMIT 5;
```

## Use Cases for Direct Analytics

- **Custom Reporting**: Build custom reports and visualizations in external BI tools (like Tableau or PowerBI) by connecting them to ClickHouse.
- **Security Forensics**: Perform deep forensic analysis during a security investigation by running complex queries across logs and network flow data.
- **Business Intelligence**: Correlate application data (like `user_id` or `tenant_id` from your structured logs) with performance metrics to understand how specific customers are experiencing your application.
- **Long-Term Trend Analysis**: Analyze months or years of data to identify long-term performance trends, capacity planning insights, or seasonal patterns.

## Performance Considerations

While ClickHouse is incredibly fast, it's still important to write efficient queries.

- **Filter on `timestamp` first**: Always include a time range filter in your `WHERE` clause. This is the primary partitioning key.
- **Select only the columns you need**: Avoid `SELECT *`. Columnar databases are most efficient when you only read the columns required for your query.
- **Use `SAMPLE` for exploration**: For very large tables, use the `SAMPLE` clause (`... FROM logs SAMPLE 0.1`) to run your query on a 10% sample of the data for faster, exploratory analysis.
