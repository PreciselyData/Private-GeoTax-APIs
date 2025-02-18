# Installing GeoTax Helm Chart on AKS

## Step 1: Before You Begin

To deploy the GeoTax application in AKS, install the following client tools:

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm3](https://helm.sh/docs/intro/install/)
- [python](https://www.python.org/downloads/)

##### Azure Kubernetes Service (AKS)

- [az](https://learn.microsoft.com/en-us/cli/azure/)

The GeoTax Helm Chart on Microsoft AKS requires access
to [Azure Container Registry (ACR)](https://azure.microsoft.com/en-us/services/container-registry/)
and [Azure Blob Storage](https://azure.microsoft.com/en-in/services/storage/blobs/). Azure Blob Storage is used to store
the reference datasets in .spd file format, and the ACR repository contains the GeoTax Docker Images
which is used for the deployment.

Running the GeoTax Helm Chart on AKS requires permissions on these Microsoft's Azure Cloud resources along with
some others listed below.

- `Contributor` role to create AKS cluster
- `Azure Blob Storage Reader`  role to download .spd files from Azure Blob Storage
- `NVMe Virtual Machines`. Refer for more information: https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-faqs

## Step 2: Download GeoTax Docker Images

The geotax helm chart relies on the availability of Docker images for the microservices, which are conveniently
obtainable from Precisely Data Experience. The required docker images include `GeoTax Service Docker Image` tar file.

> [!NOTE] =>
> Contact Precisely or visit [Precisely Data Experience](https://data.precisely.com/) for buying subscription to docker
> image `GEOTAX DOCKER IMAGE`

Once you have purchased a subscription to Precisely Data Experience (PDX), you can directly download Docker images.
Afterward, you can easily load these Docker images into your Docker environment.

Refer to the documentation for [Creating Azure Resource Group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups) and [Creating Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli).

You can run the following commands after extracting the zipped docker image:

```shell
cd ./geotax-images
az acr login --name <registry-name> --subscription <subscription-id>
docker load -i ./geotax-service.tar
docker tag geotax-service:latest <your-container-registry-name>.azurecr.io/geotax-service:3.0.0
docker push <your-container-registry-name>.azurecr.io/geotax-service:3.0.0
```

## Step 3: Download Geotax Reference Data from PDX and Upload it to Azure Blob Storage Container

You can run the following commands on any machine to download and upload reference data to the Azure Blob Storage Container:

- Create an Azure Account Storage:
    ```shell
    az storage account create --name geotax --location eastus --sku Premium_LRS --kind FileStorage --https-only false
    ```
- Download python script for Downloading and Uploading Geotax Reference Data:
    ```shell
    curl -o geotax_reference_data_extractor.py "https://raw.githubusercontent.com/PreciselyData/Private-GeoTax-APIs/refs/heads/rc_3.0.0-azure-nvme/charts/component-charts/reference-data-setup-generic/image/geotax_reference_data_extractor.py"
    ```
- Use the script to download the Geotax reference data locally:
    ```shell
    python geotax_reference_data_extractor.py --pdx-api-key '<YOUR-PDX-API-KEY>' --pdx-api-secret '<YOUR-PDX-SECRET>' --local-path '<YOUR LOCAL PATH e.g. /home/ec2-user/geotax>' --dest-path '<YOUR LOCAL PATH FOR EXTRACTION e.g. /home/ec2-user/geotax/extracted>' --data-mapping '["Vertex L-Series ASCII#United States#All USA#Spectrum Platform Data","Payroll Tax Data#United States#All USA#Spectrum Platform Data","Tax Rate Data ASCII#United States#All USA#Spectrum Platform Data","Sovos Correspondence File ASCII#United States#All USA#Spectrum Platform Data","Vertex O-Series ASCII#United States#All USA#Spectrum Platform Data","GeoTAX Auxiliary File ASCII#United States#All USA#Spectrum Platform Data","GeoTAX Premium Masterfile Monthly#United States#All USA#Spectrum Platform Data","Vertex Q-Series ASCII#United States#All USA#Spectrum Platform Data","Insurance Premium Tax Data#United States#All USA#Spectrum Platform Data","Special Purpose District Data#United States#All USA#Spectrum Platform Data"]'
    ```
  Replace the placeholders in the above script for downloading the given SPDs and extracting in the provided location.
  > NOTE: You can provide the data mapping as per your requirement for the reference data that you want to upload. You can also ignore this parameter and change it in the script itself if you face any issues running the command. 

- To upload the reference data to Azure Blob Storage Container, follow the steps:
    ```shell
    az storage account create --name <e.g. geotax> --resource-group <e.g.: cloudnative-geotax-helm> --location <e.g. eastus> --sku Standard_LRS --kind StorageV2
    az storage container create --name <e.g. reference-data> --account-name <e.g. geotax> --auth-mode login
    ```
  Command to upload the geotax reference data:
    ```shell
     az storage blob upload-batch --source </home/ec2-user/geotax/extracted/> --destination <reference-data> --account-name <geotax> --sas-token '<YOUR-SAS-TOKEN>'
    ```
  Replace the placeholders in the above commands, for more information regarding upload-batch, refer to https://learn.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az-storage-blob-upload-batch.

## Step 4: Create the AKS Cluster

You can create the AKS cluster or use existing AKS cluster.

> NOTE: We recommend using NVMe Virtual Machines which are highly optimized for IOPS and throughput. You can visit https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk for more information.
- We have provided you with few sample cluster installation commands. Run the following sample commands to create the cluster:
  
  Commands to create and maintain azure container registry are
  mentioned [here](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli).
    ```shell
    az aks create --name <e.g. geotax> --generate-ssh-keys --attach-acr <your-acr-name> --enable-cluster-autoscaler --node-count 1 --min-count 1 --max-count 10 --node-osdisk-type Managed --node-osdisk-size 100 --node-vm-size Standard_L8s_v3 --location eastus --nodepool-labels node-app=geotax --zones 1 2 3
    az aks nodepool add --name ingress --cluster-name <e.g. geotax> --node-count 1 --node-osdisk-size 100 --labels node-app=geotax-ingress --zones 1 2 3
    az aks get-credentials --name <e.g. geotax> --overwrite-existing
    ```
  > Update the commands accordingly, make sure to use NVMe enabled Virtual machines like `Standard_L8s_v3` as mentioned in the sample commands above.
- The geotax service requires ingress controller setup. Run the following command for setting up NGINX ingress
  controller:
  ```shell
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install nginx-ingress ingress-nginx/ingress-nginx -f ./cluster-sample/aks/ingress-values.yaml
  ```

*Note: Update the nodeSelector according to your cluster's ingress node.*

Once ingress controller setup is completed, you can verify the status and get the ingress URL by using the following
command:

  ```shell
  kubectl get services -o wide    
  ```

## Step 5: Installation of GeoTax Helm Chart

> NOTE: For every helm chart version update, make sure you run
> the [Step 3](#step-2-download-geotax-docker-images) for uploading the docker images with the newest tag.

To install/upgrade the geotax helm chart, use the following command:

```shell
helm upgrade --install geotax-application ./charts/aks/geotax-application \
--dependency-update \
--set "global.nfs.storageAccount=[geotax]" \
--set "global.nfs.containerName=[reference-data]" \
--set "global.nfs.sasToken=[YOUR-AZURE-SAS-TOKEN]"
--set "global.manualDataConfig.configMapData.geotax\.vintage=[e.g. /mnt/data/geotax-data/202502110734]" \
--set "geotax.ingress.hosts[0].host=[ingress-host-name]" \ 
--set "geotax.ingress.hosts[0].paths[0].path=[e.g. /precisely/geotax]" \
--set "geotax.ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
--set "global.nodeSelector.node-app=[node-selector-label]" \
--set "geotax.image.repository=[azure-acr-name].azurecr.io/geotax-service" \
--namespace geotax-application --create-namespace
```

> Refer [helm values](../../../charts/component-charts/geotax-generic/README.md#helm-values) for the parameters related
> to `global.manualDataConfig.*` and `geotax.nfs.*`.
>
> Also, for more information, refer to the comments in [values.yaml](../../../charts/component-charts/geotax-generic/values.yaml)

#### Mandatory Parameters

* ``global.nfs.storageAccount``: The Azure File Storage Account Name
* ``global.nfs.containerName``: The Azure File Storage Container Name
* ``global.nfs.sasToken``: The SAS token required to access the Azure Storage Account
* ``global.manualDataConfig.configMapData.geotax\.vintage``: The folder where reference data is downloaded and synced
* ``geotax.image.repository``: The image repository for the geotax service docker image
* ``global.nodeSelector``: The node selector to run the geotax solutions on nodes of the cluster.

For more information on helm values, follow [this link](../../../charts/component-charts/geotax-generic/README.md#helm-values).

## Step 7: Monitoring GeoTax Helm Chart Installation

Once you run the GeoTax helm install/upgrade command, it might take a couple of seconds to trigger the deployment. You
can run the following command to check the creation of pods. Please wait until all the pods are in running state:

```shell
kubectl get pods -w --namespace geotax-application
```

When all the pods are up, you can run the following command to check the ingress service host:

```shell
kubectl get services --namespace geotax-application
```

## Next Sections

- [GeoTax API Usage](../../../charts/component-charts/geotax-generic/README.md#geotax-service-api-usage)
- [Metrics, Traces and Dashboard](../../MetricsAndTraces.md)
- [FAQs](../../faq/FAQs.md)

[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)