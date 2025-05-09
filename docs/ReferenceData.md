# Reference Data Highlights

> NOTE: Follow the Quick Start Guides based on your cloud provided for installing the reference data using provided Helm Charts for reference data installation.
[EKS](../charts/eks/reference-data-setup/README.md)|[AKS](../charts/aks/reference-data-setup/README.md)|[GKE](../charts/gke/reference-data-setup/README.md)


Precisely offers a large variety of datasets, which can be utilized depending on the use case.

<details>
<summary>Highlights</summary>

- Highest building level precision. Highest overall building and parcel level precision datasets
- Low Street interpolation percentage.
- Best for address level geocodes for North American and European addresses
- Master Location Data (MLD), our best-in-class, hyper-accurate location reference data with PreciselyID, is now
  available in 11 countries, with more to come!
- Positionally-accurate location datasets delivers highly relevant, consistent context enabling more confident business
  decisions.

</details>

The GeoTax solution relies on reference data stored on mounted file storage for
geotax operations. It's crucial to ensure that this reference data is available in the cluster's mounted
storage before initiating the deployment of the GeoTax Helm Chart.

To accommodate reference data and software upgrades, you should upload newer data to the recommended location or folder
on the mounted storage. The GeoTax Helm Chart can then be rolled out with the new reference data location
seamlessly and with zero downtime.


# Reference Data Structure

As a generalized step, the reference data should exist in the following format only:
<br>`[basePath]/[geotax]/[current-timestamp]/[vintage]/[data]`

NOTE: The current-time folder name should always be in the format: `YYMMDDhhmm` e.g. 202311081159
```
basePath/
├── geotax/
│   │── 202311081159/
│   │   └── 202312/
│   │       ├── USA-GEOTAXPremium/
│   │       └── ...
│   │   └── 122023/
│   │       ├── GEOTAX GEOTAX AUXILIARY FILE ASCII AMER UNITED STATES ALL USA/
│   │       └── ...
│   │   └── 012024/
│   │       ├── GEOTAX-INSURANCE-BOUNDARY-FILE/
│   │       ├── GEOTAX-SOVOS-CORRESPONDENCE-FILE-ASCII/
│   │       └── ...
```

### Helm Values

The following is the summary of some *helm values*
provided by this chart:

> click the `▶` symbol to expand

<details>
<summary><code>image.*</code></summary>

| Parameter          | Description                                              | Default                           |
|--------------------|----------------------------------------------------------|-----------------------------------|
| `image.repository` | the reference-data-extractor container image repository  | `geotax-reference-data-extractor` |
| `image.tag`        | the reference-data-extractor container image version tag | `3.0.2`                           |

<hr>
</details>

<details>
<summary><code>global.*</code></summary>

| Parameter                  | Description                                                | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|----------------------------|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| *`global.pdxApiKey`        | the apiKey of your PDX account                             | `pdx-api-key`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| *`global.pdxSecret`        | the secret key of your PDX account                         | `pdx-api-secret`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `global.dataConfigMap`     | a Map of reference data to be downloaded against countries | `[\"Vertex L-Series ASCII#United States#All USA#Spectrum Platform Data\",\"Payroll Tax Data#United States#All USA#Spectrum Platform Data\",\"Tax Rate Data ASCII#United States#All USA#Spectrum Platform Data\",\"Sovos Correspondence File ASCII#United States#All USA#Spectrum Platform Data\",\"Vertex O-Series ASCII#United States#All USA#Spectrum Platform Data\",\"GeoTAX Auxiliary File ASCII#United States#All USA#Spectrum Platform Data\",\"GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data\",\"Vertex Q-Series ASCII#United States#All USA#Spectrum Platform Data\",\"Insurance Premium Tax Data#United States#All USA#Spectrum Platform Data\",\"Special Purpose District Data#United States#All USA#Spectrum Platform Data\"]` |

<hr>
</details>

[🔗 Return to `Table of Contents` 🔗](../README.md#components)