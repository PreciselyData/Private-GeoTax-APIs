[🔗 Return to `Table of Contents` 🔗](../../README.md#guides)

# Uninstall Guide

To uninstall the GeoTax helm chart, run the following command:

```shell
## set the release-name & namespace (must be same as previously installed)
export RELEASE_NAME="geotax-application"
export RELEASE_NAMESPACE="geotax-application"

## uninstall the chart
helm uninstall \
  "$RELEASE_NAME" \
  --namespace "$RELEASE_NAMESPACE"
```