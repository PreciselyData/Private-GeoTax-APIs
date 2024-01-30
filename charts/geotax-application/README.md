# GeoTax Helm Chart

## Getting Started

To get started with installation of helm chart, follow this [Quick Start Guide](../../docs/guides/eks/QuickStartEKS.md)

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
| `image.tag`        | the geotax container image version tag | `1.0.0`          |

<hr>
</details>

<details>
<summary><code>ingress.*</code></summary>

| Parameter                        | Description                                | Default                       |
|----------------------------------|--------------------------------------------|-------------------------------|
| `ingress.hosts[0].host`          | the ingress host url base path             | `geoaddressing.precisely.com` |
| `ingress.hosts[0].paths[0].path` | the base path for accessing geotax service | `/precisely/geotax`           |

<hr>
</details>


<details>
<summary><code>global.*</code></summary>

| Parameter                                              | Description                                                                                                                                                                             | Default                              |
|--------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| `global.awsRegion`                                     | the region for where elastic file system is present.                                                                                                                                    | `us-east-1`                          |
| `global.efs.fileSystemId`                              | the fileSystemId of the elastic file system (e.g. fs-0d49e756a)                                                                                                                         | `fileSystemId`                       |
| `global.efs.volumeMountPath`                           | the mount path of the geotax data                                                                                                                                                       | `/mnt/data/geotax-data`              |
| `global.efs.geotaxBasePath`                            | the base path of the folder geotax data is present                                                                                                                                      | `geotax`                             |
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

| Parameter                      | Description                                                                 | Default                              |
|--------------------------------|-----------------------------------------------------------------------------|--------------------------------------|
| `*DATA_PATH`                   | The folder path of the geotax data                                          | `<referred from configmap>`          |
| `*AUTH_ENABLED`                | Flag to indicate whether authorization is enabled for the endpoints or not. | `false`                              |
| `*SDK_BLOCKING_THREADS`        | No of blocking threads                                                      | `16`                                 |
| `*SDK_BLOCKING_QUEUE_CAPACITY` | The queue capacity of threads                                               | `100000`                             |

<hr>
</details>

## GeoTax Service API Usage

The GeoTax service exposes an API which is `/v1/geo-tax/address`

You can use the [postman collection](../../scripts/GeoTax-Helm.postman_collection.json) provided in the
repository for hitting the APIs.

API and sample request is provided below:

### `/v1/geo-tax/address`:

This endpoint takes a single input address and determines which tax jurisdiction a given address is located in, and which current tax codes apply.

Sample Request:

```curl
curl --location 'http://[geotax-host-url]/v1/geo-tax/address' --header 'Content-Type: application/json' --data '{
    "preferences": {
        "output": {
            "taxDistrict": "NONE",
            "taxCrossReferenceKey": "NONE",
            "salesTaxRateType": "NONE",
            "outputCasing": "UPPER"
        },
        "geocoding": {
            "defaultBufferWidth": "0",
            "latLongOffset": "NONE",
            "squeeze": "NO",
            "latLongAltFormat": "DecimalSign"
        },
        "matching": {
            "matchMode": "CLOSE"
        }
    },
    "address": {
        "addressLines": [
            "2001 Main St, Eagle Butte, SD 57625"
        ]
    }
}'
```

Response:
```curl
{
    "response": {
        "status": "OK",
        "result": {
            "gnisCode": "001267480",
            "confidence": 100.0,
            "jurisdiction": {
                "state": {
                    "code": "46",
                    "name": "SD"
                },
                "county": {
                    "code": "035",
                    "name": "DAVISON"
                },
                "place": {
                    "name": "MITCHELL",
                    "code": "43100",
                    "gnisCode": "001267480",
                    "classCode": "C5",
                    "incorporatedFlag": "Inc",
                    "lastAnnexedDate": "01/2020",
                    "lastUpdatedDate": "10/2023",
                    "lastVerifiedDate": "09/2023",
                    "pointStatus": "P",
                    "distanceToBorder": "1776"
                },
                "geoTaxKeyMatchCode": " "
            },
            "matchedAddress": {
                "formattedAddress": "2001 N MAIN ST MITCHELL, SD  57301",
                "formattedStreetAddress": "2001 N MAIN ST",
                "formattedLocationAddress": "MITCHELL, SD  57301",
                "addressNumber": "2001",
                "stateName": "SD",
                "countyName": "DAVISON",
                "cityName": "MITCHELL",
                "postalCode": "57301",
                "placeName": "MITCHELL",
                "street": "MAIN",
                "dataTypeName": "TOMTOM STREETS",
                "genRC": "S",
                "locationCode": "AS0",
                "matchCode": "TB21",
                "numCandidates": "0",
                "houseNumber": "2001",
                "preDirectional": "N",
                "streetType": "ST"
            },
            "census": {
                "block": "050",
                "blockGroup": "5",
                "cbsa": {
                    "name": "MITCHELL, SD MICROPOLITAN STATISTICAL AREA",
                    "code": "33580",
                    "metroFlag": "N"
                },
                "matchLevel": "Street",
                "matchCode": "S",
                "tract": "962700",
                "mcd": {
                    "name": "MITCHELL CITY",
                    "code": "43100",
                    "pointStatus": "P",
                    "distanceToBorder": "1776"
                },
                "cbsad": {},
                "csa": {
                    "code": "null"
                }
            },
            "latLongFields": {
                "matchCode": "R",
                "matchLevel": "Rooftop",
                "geometry": {
                    "latLongAltFmt": "DecimalSign",
                    "latLongAltFmtValue": "43.731783-098.025936",
                    "type": "Point",
                    "coordinates": [
                        43.731783,
                        -98.025936
                    ]
                }
            },
            "numTaxDistrictsFound": 0
        }
    }
}
```
[🔗 Return to `Table of Contents` 🔗](../../README.md#components)
