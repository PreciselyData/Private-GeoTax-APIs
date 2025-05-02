# Installing GeoTax Helm Chart on Google Kubernetes Engine (GKE)

## Step 1: Before You Begin

To deploy the GeoTax application in GKE, install the following client tools:

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm3](https://helm.sh/docs/intro/install/)
-

##### Google Kubernetes Engine (GKE)

- [gcloud cli](https://cloud.google.com/cli)

The GeoTax Helm Chart on GKE requires access
to [Google Filestore](https://cloud.google.com/filestore?hl=en), [Google Artifact Registry (GCR)](https://cloud.google.com/artifact-registry).
Google Filestore is used to store
the reference datasets in .spd file format, and the GCR repository contains the GeoTax Docker Images
which is used for the deployment.

The GeoTax Helm Chart on Google GKE requires access to Cloud Storage buckets and GCR. Google Cloud Storage (GS)
is used to store the reference datasets, and the GCR repository contains the GeoTax
application's Docker images which will be used for the deployment.

Running the geotax helm chart on GKE requires permissions on these Google Cloud resources along with some others
listed below.

##### GCP IAM Permissions

To deploy the geotax application on a GKE cluster, make sure you have the following IAM roles and permissions:

- roles/container.admin - to create and manage a GKE cluster
- roles/iam.serviceAccountUser - to assign a service account to Nodes
- roles/storage.admin - to read/write data in Google Storage
- roles/file.editor - to read/write data from Google Filestore

For more details about IAM roles and permissions, see
Google's [documentation](https://cloud.google.com/iam/docs/understanding-roles).

##### Authenticate and configure gcloud

Replace the path parameter with the absolute path to your service account key file, and run the command below. For
more options for authentication, refer to
the [Google Cloud documentation](https://cloud.google.com/sdk/gcloud/reference/auth).

  ```shell 
  gcloud auth activate-service-account  --key-file=<path-to-key-file>  
  ``` 

Configure a GCP project ID to create the Filestore instance; otherwise, you will have to provide this project ID in each
command.

  ```shell
  gcloud config set project <project-name>
  ```

## Step 2: Create the GKE Cluster

You can create the GKE cluster or use existing GKE cluster.

- If you DON'T have GKE cluster, we have provided you with few
  sample cluster installation commands. Run the following sample commands to create the cluster:
    ```shell
    gcloud container clusters create <cluster-name> --disk-size=200G --zone <zone-name> --node-locations <zone-name> --machine-type n1-standard-8 --num-nodes 2 --no-enable-autoupgrade --min-nodes 1 --max-nodes 2 --node-labels=node-app=<node-app-label>

    gcloud container node-pools create ingress-pool --cluster <cluster-name> --machine-type n1-standard-4 --num-nodes 1 --no-enable-autoupgrade --zone <zone-name> --node-labels=node-app=<node-app-label>

    gcloud container clusters get-credentials <cluster-name> --zone <zone-name>
    ```

- If you already have a GKE cluster, make sure you have the following driver related to it enabled on the
  cluster:
  ```shell
  gcloud container clusters update <cluster-name> --update-addons=GcePersistentDiskCsiDriver=ENABLED
  ```
- The geotax service requires ingress controller setup. Run the following command for setting up NGINX ingress
  controller:
  ```shell
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install nginx-ingress ingress-nginx/ingress-nginx -f ./cluster-sample/gke/ingress-values.yaml
  ```

*Note: You can update the nodeSelector according to your cluster's ingress node.*

Once ingress controller setup is completed, you can verify the status and get the ingress URL by using the following
command:

  ```shell
  kubectl get services -o wide    
  ```

## Step 3: Download GeoTax Docker Images

The geotax helm chart relies on the availability of Docker images for several essential microservices which are
conveniently obtainable from Precisely Data Experience. The required docker images include `GeoTax Docker Image`

> [!NOTE] =>
> Contact Precisely or visit [Precisely Data Experience](https://data.precisely.com/) for buying subscription to docker
> image

Once you have purchased a subscription to Precisely Data Experience (PDX), you can directly download Docker images.
Afterward, you can easily load these Docker images into your Docker environment.

You can run the following commands after extracting the zipped docker images:

```shell
cd ./geotax-images
gcloud auth configure-docker --quiet
docker load -i ./geotax-service.tar
docker tag geotax-service:latest us.gcr.io/<project-name>/geotax-service:3.0.2
docker push us.gcr.io/<project-name>/geotax-service:3.0.2
```

## Step 4: Create and Configure Google Filestore

The GeoTax Application requires reference data for geotax capabilities. This reference data should be
deployed using [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). This persistent
volume is backed by Google Filestore so that the data is ready to use immediately when the volume is
mounted to the pods.

If you have already created & configured an instance of the Google Filestore, and it is accessible from your GKE
cluster, then you can ignore these steps and move to the next step.

> Note: This process for configuring Google Filestore needs to be executed only once for the GeoTax Application
> deployment.

Follow the following steps to create a Filestore instance for the GeoTax Application:

#### 1. Create the Filestore Instance

- Configure the GCP project ID that will be used to create the Filestore instance; otherwise, you will need to provide
  this project ID in every command:
  ```
  gcloud config set project <project-id>
  ```

- Locate the VPC network of your cluster - the Filestore instance and GKE cluster must be in the same network to access
  the data from them in the cluster:
  ```
  gcloud container clusters describe <cluster-name> --zone us-east1-c --format="value(network)"
  ```
  Your output should be similar to this:
  ```
  default
  ```
- Locate the compute zone of your cluster, this is also required to create a Filestore instance:
  ```
  gcloud container clusters describe <cluster-name> --zone <zone-name> --format="value(location)"
  ```
  Output
  ```
  us-east1-c
  ```

- Create the Filestore instance using the retrieved values:
  ```
  gcloud filestore instances create <filestore-instance-name> --zone <zone-name> --network=name=default --file-share=name=<filestore-instance-name-with-underscore>,capacity=1TB 
  ```
  **Note:** Uppercase and hyphen ('-') are not allowed values for `--file-share`; however, using an underscore ('_') is
  supported. Google requires a minimum capacity of 1 TB.
  Creating the Filestore instance takes a few minutes. When the command completes, you can verify that your Filestore
  instance was created:
  ```
  gcloud filestore instances describe <filestore-instance-name> --zone <zone-name>
  ```
  Your output should be similar to this:
  ```
   createTime: '2020-08-18T10:13:20.387685657Z'
   fileShares:
   - capacityGb: '1024'
     name: <filestore-instance-name-with-underscore>
   name: projects/<project-id>/locations/<zone-name>/instances/<filestore-instance-name>
   networks:
   - connectMode: DIRECT_PEERING
   - ipAddresses:
     - 10.x.x.x
     network: default
     reservedIpRange: 10.x.x.x/29
   state: READY
   tier: BASIC_HDD
   ```

#### 2. Update the persistent volume resource definition

- Locate the IP address of your Filestore instance:
   ```
   gcloud filestore instances describe <filestore-instance-name> --zone <zone-name> --format="value(networks[0].ipAddresses[0])"
   ```
- Locate the NFS path (the name) of your Filestore instance:
  ```
  gcloud filestore instances describe <filestore-instance-name> --zone <zone-name> --format="value(fileShares[0].name)"
  ```

**Note:** The path of the data that you are going to use must exist on Filestore.

## Step 5: Installation of Reference Data

The GeoTax Application relies on reference data for performing GeoTax operations.
If you don't have reference data installed in your mounted file storage:
- Refer to [this guide](../../ReferenceData.md) for more information about reference data, and it's recommended structure.
- Refer to [this quickstart guide](./QuickStartReferenceDataGKE.md) for installing reference data using Helm Chart.

## Step 6: Installation of GeoTax Helm Chart

After installing the reference data, to install/upgrade the geotax helm chart, use the following command:

```shell
helm upgrade --install geotax-application ./charts/gke/geotax-application \
--dependency-update \
--set "global.nfs.path=/<filestore-instance-name-with-underscore>" \
--set "global.nfs.server=<filestoreServerIP>" \
--set "geotax.ingress.hosts[0].host=[ingress-host-name]" \ 
--set "geotax.ingress.hosts[0].paths[0].path=/precisely/geotax" \
--set "geotax.ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
--set "global.nodeSelector.node-app=<node-selector-label>" \
--set "geotax.image.repository=[e.g. us.gcr.io/<project-id>/geotax-service]" \
--namespace geotax-application --create-namespace
```

> NOTE: By default, the geotax helm chart runs a hook job, which identifies the latest reference-data vintage
> mount path.
>
> To override this behaviour, you can disable the geotax-hook by `geotax.geotax-hook.enabled` and
> provide manual
> reference data configuration using `global.manualDataConfig`.
>
> Refer [helm values](../../../charts/component-charts/geotax-generic/README.md#helm-values) for the parameters
> related
> to `global.manualDataConfig.*` and `geotax.geotax-hook.*`.
>
>
> NOTE: `geotax-hook` job not applicable to geotax-express service.
>
> Also, for more information, refer to the comments
> in [values.yaml](../../../charts/component-charts/geotax-generic/values.yaml)

#### Mandatory Parameters

* ``global.nfs.path``: The Path to Google Filestore Instance
* ``global.nfs.server``: The IP of your Google Filestore Instance server
* ``geotax.image.repository``: The image repository for the geotax image
* ``global.nodeSelector``: The node selector to run the geotax solutions on nodes of the cluster.

For more information on helm values,
follow [this link](../../../charts/component-charts/geotax-generic/README.md#helm-values).

## Step 7: Monitoring GeoTax Helm Chart Installation

Once you run the geotax helm install/upgrade command, it might take a couple of seconds to trigger the
deployment. You can run the following command to check the creation of pods. Please wait until all the pods are in
running state:

```shell
kubectl get pods -w --namespace geotax
```

When all the pods are up, you can run the following command to check the ingress service host:

```shell
kubectl get services --namespace geotax
```

## Next Sections

- [GeoTax API Usage](../../../charts/component-charts/geotax-generic/README.md#geotax-service-api-usage)
- [Metrics, Traces and Dashboard](../../MetricsAndTraces.md)
- [FAQs](../../faq/FAQs.md)

[🔗 Return to `Table of Contents` 🔗](../../../README.md#guides)
 