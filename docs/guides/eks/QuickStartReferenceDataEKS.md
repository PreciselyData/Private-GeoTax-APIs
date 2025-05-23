# Reference Data Installation Helm Chart for EKS

## Step 1: Getting Access to Reference Data

To download the geotax reference data,
visit [Precisely Data Portfolio](https://dataguide.precisely.com/) where you can also sign up for a free account and
access files available in your [Precisely Data Experience](https://data.precisely.com/) account.

## Step 2: Creating and Pushing Reference Data Docker Image

This helm chart requires a `geotax-reference-data-extractor` docker image to be available in Elastic Container Registry (ECR).
Follow the below steps to create and push the docker image to ECR:

```shell
cd ./charts/reference-data-setup/image
docker build . -t geotax-reference-data-extractor:3.0.2
```

```shell
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com

aws ecr create-repository --repository-name geotax-reference-data-extractor --image-scanning-configuration scanOnPush=true --region [AWS-REGION]

docker tag geotax-reference-data-extractor:3.0.2 [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com/geotax-reference-data-extractor:3.0.2

docker push [AWS-ACCOUNT-ID].dkr.ecr.[AWS-REGION].amazonaws.com/geotax-reference-data-extractor:3.0.2
```

## Step 3: Prepare the Reference Data Required for Installation (Optional)

You can provide the information about the reference data to be downloaded in the format of Map/Dictionary. 
Below is the default value of reference data config map:

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


The reference data key is in the format: `[ProductName#Geography#RoasterGranularity#DataFormat]` e.g. `GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data`. You can also pass optional vintage parameter (to download the specific vintage data instead of latest): `[ProductName#Geography#RoasterGranularity#DataFormat#Vintage]`

**_If you want to change the default reference data, you need to Prepare the JSON value in above format, Minify and Escape it using any online tools.
Afterward, overwrite the default value of dataConfigMap section in the [values.yaml](../../../charts/eks/reference-data-setup/values.yaml) file of the reference data helm chart._**


## Step 4: Running the Reference Data Installation Helm Chart

Run the below command for installation of reference data:

```shell
helm install geotax-reference-data ./charts/aks/reference-data-setup/ \
--set "global.pdxApiKey=<your-pdx-key>" \
--set "global.pdxSecret=<your-pdx-secret>" \
--set "global.nfs.fileSystemId=<FileSystemId>" \
--set "global.awsRegion=<AWSRegion>" \
--set "geotax-reference-data.dataDownload.image.repository=<AWS-ACCOUNT-ID>.dkr.ecr.<AWS-REGION>.amazonaws.com/geotax-reference-data-extractor" \
--set "geotax-reference-data.dataDownload.image.tag=3.0.2" \
--dependency-update --timeout 60m
```

## Step 5: Monitoring the Reference Data Installation 

The above command triggers a Kubernetes Job to install reference data. Once the Job is in active state, following commands will be helpful for monitoring the Job status:

```shell
kubectl get jobs
kubectl get pods -w
```
You will see a Pod for the Job. You can describe the Job, Pod for more details.

Run the following command to get the logs of the reference data pod, once the pod is in running state.
```shell
kubectl logs -f -l "app.kubernetes.io/name=geotax-reference-data"
```

[🔗 Return to `Table of Contents` 🔗](../../../README.md#components)