# Reference Data

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

# Reference Data Installation

To download the reference data and all the required components for running the Helm Chart,
visit [Precisely Data Portfolio](https://dataguide.precisely.com/) where you can also sign up for a free account and
access files available in [Precisely Data Experience](https://data.precisely.com/).

Additionally, we have provided a miscellaneous helm chart which will download the required reference data SPDs from Precisely Data Experience and extract it to the necessary reference data structure.
Please visit the [reference-data-setup helm chart](../charts/reference-data-setup/README.md).

[🔗 Return to `Table of Contents` 🔗](../README.md#components)