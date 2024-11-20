# GeoTax Helm Chart

## Getting Started

To get started with installation of helm chart, follow:
<br><br>For AWS EKS: [Quick Start Guide for EKS](../../../docs/guides/eks/QuickStartEKS.md)
<br>For Azure's AKS: [Quick Start Guide for AKS](../../../docs/guides/aks/QuickStartAKS.md)
<br>For Google's GKE: [Quick Start Guide for GKE](../../../docs/guides/gke/QuickStartGKE.md)

## Helm charts

The GeoTax helm chart compromises of following components:

- GeoTax Helm Chart
- Ingress
- Horizontal Autoscaler (HPA)
- Persistent Volume

## Helm Values

The `GeoTax` helm chart follows [Go template language](https://pkg.go.dev/text/template) which is driven
by [values.yaml](values.yaml) file. The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>image.*</code></summary>

| Parameter          | Description                            | Default          |
|--------------------|----------------------------------------|------------------|
| `image.repository` | the geotax container image repository  | `geotax-service` |
| `image.tag`        | the geotax container image version tag | `2.0.0`          |

<hr>
</details>

<details>
<summary><code>ingress.*</code></summary>

| Parameter                        | Description                                | Default                |
|----------------------------------|--------------------------------------------|------------------------|
| `ingress.enabled`                | ingress is disabled by default             | `false`                |
| `ingress.hosts[0].host`          | the ingress host url base path             | `geotax.precisely.com` |
| `ingress.hosts[0].paths[0].path` | the base path for accessing geotax service | `/precisely/geotax`    |

<hr>
</details>


<details>
<summary><code>global.*</code></summary>

| Parameter                                              | Description                                                                                                                                                                             | Default                              |
|--------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| `global.nfs.volumeMountPath`                           | the mount path of the geotax data                                                                                                                                                       | `/mnt/data/geotax-data`              |
| `global.nfs.geotaxBasePath`                            | the base path of the folder geotax data is present                                                                                                                                      | `geotax`                             |
| `global.manualDataConfig.enabled`                      | the flag to indicate whether geotax data manual configuration should be enabled. The manualDataConfig disables the geotax hook for automatic identification of the latest vintage data. | `false`                              |
| `global.manualDataConfig.nameOverride`                 | the overridden name of the geotax data config                                                                                                                                           | `geotax-data-mnl-config`             |
| `global.manualDataConfig.configMapData.geotax.vintage` | the actual folder path where geotax-data is present                                                                                                                                     | `/mnt/data/geotax-data/202312181321` |

<hr>
</details>

## Environment Variables

> click the `▶` symbol to expand.

NOTE: `*` indicates that we recommend not to modify those values during installation.

<details>
<summary><code>geotax-service</code></summary>

Refer to [this file](templates/deployment.yaml) for overriding the environment variables for geotax.

| Parameter                      | Description                                                                 | Default                     |
|--------------------------------|-----------------------------------------------------------------------------|-----------------------------|
| `*DATA_PATH`                   | The folder path of the geotax data                                          | `<referred from configmap>` |
| `*AUTH_ENABLED`                | Flag to indicate whether authorization is enabled for the endpoints or not. | `false`                     |
| `*SDK_BLOCKING_THREADS`        | No of blocking threads                                                      | `24`                        |
| `*SDK_BLOCKING_QUEUE_CAPACITY` | The queue capacity of threads                                               | `100000`                    |

<hr>
</details>

## GeoTax Service API Usage

The GeoTax service exposes an API which is `/v1/geo-tax/address` & `/v1/geo-tax/location`

You can use the [postman collection](../../../scripts/GeoTax-Helm.postman_collection.json) provided in the
repository for hitting the APIs.

API and sample request is provided below:

### `/v1/geo-tax/address`:

This endpoint takes a single input address and determines which tax jurisdiction a given address is located in, and which current tax codes apply.

Sample Request:

```curl
curl --location 'http://{{baseUrl}}/v1/geo-tax/address' \
--header 'X-Request-Id: <string>' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data '{
  "address": {
    "addressLines": [
      "<string>",
      "<string>"
    ],
    "admin1": "<string>",
    "admin2": "<string>",
    "city": "<string>",
    "postalCode": "<string>",
    "postalCodeExt": "<string>"
  },
  "preferences": {
    "geocoding": {
      "defaultBufferWidth": 0,
      "latLongOffset": "60",
      "squeeze": "YES",
      "latLongAltFormat": "DecimalDirectional"
    },
    "matching": {
      "matchMode": "RELAXED"
    },
    "output": {
      "taxDistrict": "SPD",
      "salesTaxRateType": "CONSTRUCTION",
      "outputCasing": "UPPER"
    }
  }
}'
```

### `v1/geo-tax/location`:

This endpoint takes a latitude and longitude as input and determines which tax jurisdiction a given address is located in, and which current tax codes apply.

```curl
curl --location 'http://{{baseUrl}}/v1/geo-tax/location' \
--header 'X-Request-Id: <string>' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data '{
  "location": {
    "latitude": "<double>",
    "longitude": "<double>"
  },
  "preferences": {
    "geocoding": {
      "defaultBufferWidth": 0,
      "latLongOffset": "20",
      "squeeze": "YES",
      "latLongAltFormat": "DecimalSign"
    },
    "matching": {
      "matchMode": "EXACT"
    },
    "output": {
      "taxDistrict": "IPD",
      "salesTaxRateType": "NONE",
      "outputCasing": "UPPER"
    }
  }
}'
```

[🔗 Return to `Table of Contents` 🔗](../../../README.md#components)
