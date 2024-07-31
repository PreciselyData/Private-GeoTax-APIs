# GeoTax Helm Chart For EKS

## Helm Values

The `geotax` helm chart follows [Go template language](https://pkg.go.dev/text/template) which is driven
by [values.yaml](values.yaml) file. The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>global.*</code></summary>

| Parameter                 | Description               | Default        |
|---------------------------|---------------------------|----------------|
| `global.awsRegion`        | The AWS Region of AWS EFS | `us-east-1`    |
| `global.nfs.fileSystemId` | The EFS fileSystemId      | `fileSystemId` |

<hr>
</details>

<details>
<summary><code>geotax.*</code></summary>

| Parameter  | Description                   | Default             |
|------------|-------------------------------|---------------------|
| `geotax.*` | The generic geotax helm chart | `see <values.yaml>` |

<hr>
</details>

> NOTE: For more details of GeoTax Helm Chart, see
> the [geotax component helm chart](../../component-charts/geotax-generic/README.md)

[🔗 Return to `Table of Contents` 🔗](../../../README.md#components)
