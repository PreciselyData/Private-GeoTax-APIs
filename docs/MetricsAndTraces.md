# Configurations for Metrics, Traces and Dashboard

## Generating Insights from Metrics

The GeoTax application microservices expose metrics which can be used for monitoring and troubleshooting the
performance and behavior of the GeoTax application.

Depending on your alerting setup, you can set up alerts based on these metrics to proactively respond to the issues in
your application.

### Exposed Metrics

Following are the metrics exposed by Regional-Addressing Application:

> click the `▶` symbol to expand

<details>
<summary><code>jvm_*</code></summary>

| Metric Name                          | Type    | Description                                                                                            |
|--------------------------------------|---------|--------------------------------------------------------------------------------------------------------|
| `jvm_threads_daemon_threads`         | gauge   | The current number of live daemon threads in the Java Virtual Machine.                                 |
| `jvm_classes_loaded_classes`         | gauge   | The number of classes that are currently loaded in the Java Virtual Machine.                           |
| `jvm_threads_peak_threads`           | gauge   | The peak live thread count since the Java Virtual Machine started or the peak was reset.               |
| `jvm_classes_unloaded_classes_total` | counter | The total number of classes unloaded since the Java Virtual Machine started execution.                 |
| `jvm_threads_live_threads`           | gauge   | The current number of live threads, including both daemon and non-daemon threads.                      |

<hr>
</details>

<details>
<summary><code>executor_*</code></summary>

|  Metric Name                         | Type    | Description                                                                                            |
|--------------------------------------|---------|--------------------------------------------------------------------------------------------------------|
| `executor_completed_tasks_total`     | counter | The total number of tasks completed in different thread pools.                                         |
| `executor_seconds`                   | summary | Summary metrics for task execution time in different thread pools, including counts and sums.          |
| `executor_seconds_max`               | gauge   | Maximum task execution time in different thread pools.                                                 |
| `executor_active_threads`            | gauge   | The approximate number of threads actively executing tasks in different thread pools.                  |
| `executor_pool_max_threads`          | gauge   | The maximum allowed number of threads in different thread pools (e.g., "io" and "scheduled").          |
| `executor_queued_tasks`              | gauge   | The number of tasks currently queued for execution in different thread pools.                          |
| `executor_pool_size_threads`         | gauge   | The current number of threads in different thread pools.                                               |
| `executor_pool_core_threads`         | gauge   | The core number of threads in different thread pools.                                                  |
| `executor_queue_remaining_tasks`     | gauge   | The number of tasks that can be added to the queue without blocking in different thread pools.         |

<hr>
</details>

<details>
<summary><code>process_*</code></summary>

|  Metric Name                         | Type    | Description                                                                                            |
|--------------------------------------|---------|--------------------------------------------------------------------------------------------------------|
| `process_files_max_files`            | gauge   | The maximum file descriptor count.                                                                     |
| `process_files_open_files`           | gauge   | The open file descriptor count.                                                                        |
| `process_uptime_seconds`             | gauge   | The uptime of the Java Virtual Machine process.                                                        |
| `process_cpu_usage`                  | gauge   | The "recent cpu usage" of the Java Virtual Machine process.                                            |
| `process_start_time_seconds`         | gauge   | The start time of the Java Virtual Machine process since the Unix epoch.                               |

<hr>
</details>

<details>
<summary><code>system_*</code></summary>

|  Metric Name                         | Type    | Description                                                                                            |
|--------------------------------------|---------|--------------------------------------------------------------------------------------------------------|
| `system_cpu_count`                   | gauge   | The number of processors available to the Java Virtual Machine.                                        |
| `system_cpu_usage`                   | gauge   | The "recent cpu usage" of the system the application is running in.                                    |
| `system_load_average_1m`             | gauge   | The 1-minute load average of the system.                                                               |

<hr>
</details>

<details>
<summary><code>http_*</code></summary>

|  Metric Name                         | Type    | Description                                                                                            |
|--------------------------------------|---------|--------------------------------------------------------------------------------------------------------|
| `http_server_requests_seconds`       | summary | Metrics related to HTTP server requests, including counts, sums, and max response times.               |
| `http_client_requests_seconds`       | summary | Summary metrics for HTTP client requests, including counts and sums.                                   |
| `http_client_requests_seconds_max`   | gauge   | Maximum execution time for HTTP client requests.                                                       |

<hr>
</details>



### Configuring Metrics Monitoring

You can also set up metrics monitoring to gain insights and trigger alerts. Tools like [Prometheus](https://prometheus.io/), [Datadog](https://www.datadoghq.com/), [Dyntrace](https://www.dynatrace.com/) can be configured to analyze the metrics generated by the services within the GeoTax Application. These tools are capable of providing valuable insights based on the metrics data and can be instrumental in maintaining the health and performance of your application.

This section describes how to configure Prometheus for generating insights from the metrics.

Run the below commands to install prometheus and generating insights from the metrics: (Refer to open-source [prometheus helm chart](https://github.com/prometheus-community/helm-charts))
```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus
```

You can then view the Prometheus-UI for visualization, run the queries and generate the alerts.

## Application Tracing
Application tracing is a technique for troubleshooting cross-application traces in more depth than a regular log.

By default, GeoTax generates, collects and exports the traces
using [OpenTelemetry Instrumentation](https://opentelemetry.io/).

These traces can then be easily monitored using Microservice Trace Monitoring tools
like [Jaeger](https://www.jaegertracing.io/docs/1.49/), [Zipkin](https://zipkin.io/)
, [Datadog](https://www.datadoghq.com/).


This section describes usage of application tracing using **_Jaeger_**. Please run the below command for installing Jaeger:
```shell
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm install jaeger jaegertracing/jaeger --set "allInOne.enabled=true" --set "query.enabled=false" --set "agent.enabled=false" --set "collector.enabled=false"
```

You can then run the Jaeger UI for visualization and viewing the traces.

## Logs and Monitoring

The GeoTax Application generates logs for all its services, outputs them in JSON format to stdout.

For logs management and analysis, you have the option to configure Microservice Log Analysis tools like [Datadog](https://www.datadoghq.com/), [ELK Stack](https://www.elastic.co/elastic-stack/), [SumoLogic](https://www.sumologic.com/), [New Relic](https://newrelic.com/), and more.

Additionally, you can set up tools like [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) or [K8s Lens](https://k8slens.dev/) for monitoring your kubernetes resources and logs easily.

These recommendations are not exhaustive, and you have the flexibility to use any Microservice Log Analysis tool that supports log scraping from stdout within your GeoTax Application Deployment.

[🔗 Return to `Table of Contents` 🔗](../README.md#miscellaneous)