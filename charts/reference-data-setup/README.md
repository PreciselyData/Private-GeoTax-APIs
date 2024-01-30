# Reference Data Setup

The GeoTax Application requires reference data installed in the worker nodes for running geotax
capabilities. This reference data should be deployed
using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent volume is
backed by Amazon Elastic File System (EFS) so that the data is ready to use immediately when the volume is mounted to
the pods.

For more information on reference data and reference data structure, please
visit [this link](../../docs/ReferenceData.md).

Follow the aforementioned steps for installation of the reference data in the EFS:

## Step 1: Getting Access to Reference Data

To download the geotax reference data,
visit [Precisely Data Portfolio](https://dataguide.precisely.com/) where you can also sign up for a free account and
access files available in your [Precisely Data Experience](https://data.precisely.com/) account.

## Step 2: Creating and Pushing Docker Image

This helm chart requires a `geotax-reference-data-extractor` docker image to be available in Elastic Container Registry (ECR).
Follow the below steps to create and push the docker image to ECR:

```shell
cd ./charts/reference-data-setup/image
docker build . -t geotax-reference-data-extractor:1.0.0
```

```shell
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com

aws ecr create-repository --repository-name geotax-reference-data-extractor --image-scanning-configuration scanOnPush=true --region [AWS-REGION]

docker tag geotax-reference-data-extractor:1.0.0 [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com/geotax-reference-data-extractor:1.0.0

docker push [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com/geotax-reference-data-extractor:1.0.0
```

## Step 3: Creating EFS

We already have scripts to create EFS and link to the current EKS cluster. Please follow the steps
mentioned [here](../../scripts/efs-creator/README.md) to create EFS.

## Step 4: Running the Reference Data Installation Helm Chart

Run the below command for installation of reference data in EFS:

```shell
helm install geotax-reference-data ./charts/reference-data-setup/ \
--set "global.pdxApiKey=[your-pdx-key]" \
--set "global.pdxSecret=[your-pdx-secret]" \
--set "global.efs.fileSystemId=[fileSystemId]" \
--set "dataDownload.image.repository=[reference-data-image-repository]" \
--set "global.dataConfigMap=[\"Vertex L-Series ASCII#United States#All USA#Spectrum Platform Data\",\"Payroll Tax Data#United States#All USA#Spectrum Platform Data\",\"Tax Rate Data ASCII#United States#All USA#Spectrum Platform Data\",\"Sovos Correspondence File ASCII#United States#All USA#Spectrum Platform Data\",\"Vertex O-Series ASCII#United States#All USA#Spectrum Platform Data\",\"GeoTAX Auxiliary File ASCII#United States#All USA#Spectrum Platform Data\",\"GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data\",\"Vertex Q-Series ASCII#United States#All USA#Spectrum Platform Data\",\"Insurance Premium Tax Data#United States#All USA#Spectrum Platform Data\",\"Special Purpose District Data#United States#All USA#Spectrum Platform Data\"]" \
--dependency-update --timeout 60m
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
| `image.tag`        | the reference-data-extractor container image version tag | `1.0.0`                           |

<hr>
</details>

<details>
<summary><code>global.*</code></summary>

| Parameter                  | Description                                                | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|----------------------------|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| *`global.pdxApiKey`        | the apiKey of your PDX account                             | `pdx-api-key`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| *`global.pdxSecret`        | the secret key of your PDX account                         | `pdx-api-secret`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `global.awsRegion`         | the aws region of created EFS                              | `us-east-1`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| *`global.efs.fileSystemId` | the EFS Id                                                 | `fileSystemId`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `global.dataConfigMap`     | a Map of reference data to be downloaded against countries | `[\"Vertex L-Series ASCII#United States#All USA#Spectrum Platform Data\",\"Payroll Tax Data#United States#All USA#Spectrum Platform Data\",\"Tax Rate Data ASCII#United States#All USA#Spectrum Platform Data\",\"Sovos Correspondence File ASCII#United States#All USA#Spectrum Platform Data\",\"Vertex O-Series ASCII#United States#All USA#Spectrum Platform Data\",\"GeoTAX Auxiliary File ASCII#United States#All USA#Spectrum Platform Data\",\"GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data\",\"Vertex Q-Series ASCII#United States#All USA#Spectrum Platform Data\",\"Insurance Premium Tax Data#United States#All USA#Spectrum Platform Data\",\"Special Purpose District Data#United States#All USA#Spectrum Platform Data\"]` |

<hr>
</details>

### Providing Information of Reference Data to be Downloaded

You can provide the information about the reference data to be downloaded in the format of Map/Dictionary. Below is an
example of default reference data map:

```shell
[
  "Vertex L-Series ASCII#United States#All USA#Spectrum Platform Data",
  "Payroll Tax Data#United States#All USA#Spectrum Platform Data",
  "Tax Rate Data ASCII#United States#All USA#Spectrum Platform Data",
  "Sovos Correspondence File ASCII#United States#All USA#Spectrum Platform Data",
  "Vertex O-Series ASCII#United States#All USA#Spectrum Platform Data",
  "GeoTAX Auxiliary File ASCII#United States#All USA#Spectrum Platform Data",
  "GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data",
  "Vertex Q-Series ASCII#United States#All USA#Spectrum Platform Data",
  "Insurance Premium Tax Data#United States#All USA#Spectrum Platform Data",
  "Special Purpose District Data#United States#All USA#Spectrum Platform Data"
]
```

<br>The reference data key is in the format:

`[ProductName#Geography#RoasterGranularity#DataFormat]`

e.g. `GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data`

> NOTE: If you want to download a specific vintage of data always, you can pass the vintage parameter as follows:
>
> [ProductName#Geography#RoasterGranularity#DataFormat#Vintage]
>
> e.g. `GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data#2023.11`


## Monitoring the Helm Chart

After running the helm chart command, the reference data installation step might take a couple of minutes to download
and extract the reference data in the EFS. You can monitor the progress of the reference data downloads using following
commands:

```shell
kubectl get pods -w
kubectl logs -f -l "app.kubernetes.io/name=geotax-reference-data"
```

[🔗 Return to `Table of Contents` 🔗](../../README.md#guides)