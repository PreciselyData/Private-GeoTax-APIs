# Installing GeoTax Helm Chart on AKS

## Step 1: Before You Begin

To deploy the GeoTax application in AKS, install the following client tools:

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm3](https://helm.sh/docs/intro/install/)
-

##### Azure Kubernetes Service (AKS)

- [az](https://learn.microsoft.com/en-us/cli/azure/)

The GeoTax Helm Chart on Microsoft AKS requires access
to [Azure Files Storage](https://azure.microsoft.com/en-in/services/storage/files/), [Azure Container Registry (ACR)](https://azure.microsoft.com/en-us/services/container-registry/)
and [Azure Blob Storage](https://azure.microsoft.com/en-in/services/storage/blobs/). Azure Blob Storage is used to store
the reference datasets in .spd file format, and the ACR repository contains the GeoTax Docker Images
which is used for the deployment.

Running the GeoTax Helm Chart on AKS requires permissions on these Microsoft's Azure Cloud resources along with
some others listed below.

- `Contributor` role to create AKS cluster
- `Azure Blob Storage Reader`  role to download .spd files from Azure Blob Storage
- `Storage File Data SMB Share Contributor` role to read, write, and delete files from Azure Storage file shares over
  SMB/NFS

##### Authenticate to Azure using Azure Cli

Azure CLI supports multiple authentication methods; use any authentication method to sign in. For details about
Microsoft
authentication types see their [documentation](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli).

  ```shell 
  az login 
  ``` 

If your Azure account has multiple subscription IDs then set one ID as default subscription ID, that will be used for
all `azure CLI` commands, otherwise you will have to provide this subscription ID in each command.

  ```shell
  az account set --subscription "<SUBSCRIPTION_ID>"
  ```

Configure your resource group, this will be used to create all resources-cluster and storage account, otherwise you
will have to provide it in each command.

  ```shell
  az configure --defaults group=<RESOURCE_GROUP>
  ```

## Step 2: Create the AKS Cluster

You can create the AKS cluster or use existing AKS cluster.

- If you DON'T have AKS cluster, we have provided you with few
  sample cluster installation commands. Run the following sample commands to create the cluster:
  > NOTE: You need to create an Azure Container Registry first before starting a cluster.
  Commands to create and maintain azure container registry are
  mentioned [here](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli).
    ```shell
    az aks create --name geotax --generate-ssh-keys --attach-acr <your-acr-name> --enable-cluster-autoscaler --node-count 1 --min-count 1 --max-count 10 --node-osdisk-type Managed --node-osdisk-size 100 --node-vm-size Standard_D8_v3 --location eastus --nodepool-labels node-app=geotax --zones 1 2 3
    az aks nodepool add --name ingress --cluster-name geotax --node-count 1 --node-osdisk-size 100 --labels node-app=geotax-ingress --zones 1 2 3
    az aks get-credentials --name geotax --overwrite-existing
    ```

- If you already have an AKS cluster, make sure you have the following driver related to it installed on the
  cluster:
  ```shell
  helm repo add azurefile-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts
  helm repo update
  helm install azurefile-csi-driver azurefile-csi-driver/azurefile-csi-driver --namespace kube-system --set cloud=AzureStackCloud
  ```
  > Note: From AKS 1.21, Azure Disk and Azure File CSI drivers would be installed by default, so you can directly move
  on to the next step.
- The geotax service requires ingress controller setup. Run the following command for setting up NGINX ingress
  controller:
  ```shell
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install nginx-ingress ingress-nginx/ingress-nginx -f ./cluster-sample/aks/ingress-values.yaml
  ```

*Note: You can update the nodeSelector according to your cluster's ingress node.*

Once ingress controller setup is completed, you can verify the status and get the ingress URL by using the following
command:

  ```shell
  kubectl get services -o wide    
  ```

## Step 3: Download GeoTax Docker Images

The geotax helm chart relies on the availability of Docker images for the microservices, which are conveniently
obtainable from Precisely Data Experience. The required docker images include `GeoTax Service Docker Image` tar file.

> [!NOTE] =>
> Contact Precisely or visit [Precisely Data Experience](https://data.precisely.com/) for buying subscription to docker
> image `GEOTAX DOCKER IMAGE`

Once you have purchased a subscription to Precisely Data Experience (PDX), you can directly download Docker images.
Afterward, you can easily load these Docker images into your Docker environment.

You can run the following commands after extracting the zipped docker image:

```shell
cd ./geotax-images
az acr login --name <registry-name> --subscription <subscription-id>
docker load -i ./geotax-service.tar
docker tag geotax-service:latest <your-container-registry-name>.azurecr.io/geotax-service:3.0.1
docker push <your-container-registry-name>.azurecr.io/geotax-service:3.0.1
```

## Step 4: Create and Configure Azure Files Share

The GeoTax Application requires reference data for it's working. This reference data should be
deployed using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent
volume is backed by Azure File Share so that the data is ready to use immediately when the volume is
mounted to the pods.

If you have already created & configured an instance of the Azure Files share, and it is accessible from your AKS
cluster, then you can ignore this step and move to the next step.

- Register/Enable the NFS 4.1 protocol for your Azure subscription
  ```shell
  az feature register --name AllowNfsFileShares --namespace Microsoft.Storage
  az provider register --namespace Microsoft.Storage
  ```
  Registration approval can take up to an hour. To verify that the registration is complete, use the following commands:
  ```shell
  az feature show --name AllowNfsFileShares --namespace Microsoft.Storage
  ```

- Create a FileStorage storage account by using following command, only `FileStorage` type storage account has support
  of [NFS protocol](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-how-to-create-nfs-shares?tabs=azure-portal).

  ```shell
  az storage account create --name geotax --location eastus --sku Premium_LRS --kind FileStorage --https-only false
  ```

- Create an NFS share
  ```shell
  az storage share-rm create --storage-account geotaxshare --name geotax --quota 100 --enabled-protocol NFS 
  ```

- Grant access of FileStorage from your
  cluster's [virtual network](https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-cli).

    - Find node resource group of your AKS cluster -
      ```shell
      az aks show --name geotax --query "nodeResourceGroup"
      ```
      Output:
      ```shell
      "MC_geotax-aks-deployment-sample_geotax_eastus"
      ```
    - Find name of your AKS cluster's virtual network by using node resource group.
      ```shell
      az network vnet list --resource-group MC_geotax-aks-deployment-sample_geotax_eastus --query "[0].name"
      ```
      Output:
      ```shell
      "aks-vnet-21040294"
      ```
    - Find subnets of your AKS cluster by using node resource group.
      ```shell
      az network vnet show --resource-group MC_geotax-aks-deployment-sample_geotax_eastus --name aks-vnet-21040294 --query "subnets[*].name"
      ```
      Output:
      ```shell
      [
        "aks-subnet"
      ]
      ```
    - Enable service endpoint for Azure Storage on your cluster's virtual network and subnet.
      ```shell
      az network vnet subnet update --resource-group MC_geotax-aks-deployment-sample_geotax_eastus --vnet-name "aks-vnet-21040294" --name "aks-subnet" --service-endpoints "Microsoft.Storage"
      ```
    - Find id of your AKS cluster's subnets
      ```shell
      az network vnet show --resource-group MC_geotax-aks-deployment-sample_geotax_eastus --name aks-vnet-21040294 --query "subnets[*].id"
      ```
      Output:
      ```shell
      "/subscriptions/385ad333-7058-453d-846b-6de1aa6c607a/resourceGroups/MC_geotax-aks-deployment-sample_geotax_eastus/providers/Microsoft.Network/virtualNetworks/aks-vnet-21040294/subnets/aks-subnet"
      ```
    - Add a network rule for your cluster's virtual network and subnet.
      ```shell
      az storage account network-rule add --account-name geotax --subnet "/subscriptions/385ad333-7058-453d-846b-6de1aa6c607a/resourceGroups/MC_geotax-aks-deployment-sample_geotax_eastus/providers/Microsoft.Network/virtualNetworks/aks-vnet-21040294/subnets/aks-subnet"
      az storage account update --name geotax --default-action Deny
      ```

## Step 5: Installation of Reference Data

The GeoTax Application relies on reference data for performing GeoTax operations.
If you don't have reference data installed in your mounted file storage:
- Refer to [this guide](../../ReferenceData.md) for more information about reference data, and it's recommended structure.
- Refer to [this quickstart guide](./QuickStartReferenceDataAKS.md) for installing reference data using Helm Chart.

## Step 6: Installation of GeoTax Helm Chart

After installing the reference data, to install/upgrade the geotax helm chart, use the following command:

```shell
helm upgrade --install geotax-application ./charts/aks/geotax-application \
--dependency-update \
--set "global.nfs.shareName=[shareName]" \
--set "global.nfs.storageAccount=[storageAccount]" \
--set "geotax.ingress.hosts[0].host=[ingress-host-name]" \ 
--set "geotax.ingress.hosts[0].paths[0].path=/precisely/geotax" \
--set "geotax.ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
--set "global.nodeSelector.node-app=[node-selector-label]" \
--set "geotax.image.repository=[azure-acr-name].azurecr.io/geotax-service" \
--namespace geotax-application --create-namespace
```

> NOTE: By default, the geotax helm chart runs a hook job, which identifies the latest reference-data vintage
> mount path.
>
> To override this behaviour, you can disable the geotax-hook by `geotax.geotax-hook.enabled` and provide manual
> reference data configuration using `global.manualDataConfig`.
>
> Refer [helm values](../../../charts/component-charts/geotax-generic/README.md#helm-values) for the parameters related
> to `global.manualDataConfig.*` and `geotax.geotax-hook.*`.
>
> Also, for more information, refer to the comments in [values.yaml](../../../charts/component-charts/geotax-generic/values.yaml)

#### Mandatory Parameters

* ``global.nfs.shareName``: The Azure File ShareName
* ``global.nfs.storageAccount``: The Azure File StorageAccount
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