# GeoTax Application Helm Charts

## Motivation

1. **Simplify Deployment:**
    - Streamline the GeoTax SDK deployment process.
    - Ensure an effortless deployment experience.
    - Eliminate complexities for users when setting up the SDK.

2. **Seamless Updates:**
    - Guarantee seamless updates for both data and software.
    - Aim for zero downtime during updates, ensuring uninterrupted service.

3. **Hassle-Free Deployments:**
    - Prioritize user-centric deployment experiences.
    - Minimize potential deployment challenges and issues.

4. **Ready-Made Solution:**
    - Develop a plug-and-play solution for immediate use.
    - Minimize the need for extensive setup or configuration.

5. **Language-Barrier Elimination:**
    - Expose all SDK functionalities as REST endpoints.
    - Allow consumption of these endpoints by any type of client.
    - Eliminate language barriers, enabling broader compatibility.

6. **Microservices Deployment for Scalability:**
    - Create multiple microservices around the SDK.
    - Move away from building a single monolithic application for each SDK functionality.
    - Enhance scalability and flexibility by adopting a microservice architecture.

> This solution is specifically for users who are looking for REST interface to interact with GeoTax SDK and Kubernetes
> based deployments.


> [!IMPORTANT]
> 1. Please consider these helm charts as recommendations only. They come with predefined configurations that may not be
     the best fit for your needs. Configurations can be tweaked based on the use case and requirements.
> 2. These charts can be taken as a reference on how one can take advantage of the Precisely Data ecosystem and build a
     number of services around the same piece of software, creating a collection of microservices that can scale on a
     need basis.

## Architecture

![geotax_architecture](./images/geotax_architecture.png)

<br>The core of the GeoTax helm-chart-based solution relies on the GeoTax SDK. The robust
functionality of GeoTax SDK forms the backbone of our GeoTax solution, empowering it to deliver accurate and efficient
GeoTax services while maintaining data integrity and usability.

The GeoTax application is designed as a robust microservice-based architecture, utilizing a modular approach to
provide highly optimized, scalable and precise geotax solutions.

### Capabilities

GeoTax Service will provide geographical-based determinations, to determine in which tax jurisdiction a given address is
located, and which current tax codes apply.

## Getting Started

#### 1. Prepare your environment

Install Client tools required for installation. Follow the guides to get the steps for specific cloud
platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-1-prepare-your-environment)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-1-before-you-begin)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-1-before-you-begin)

#### 2. Create Kubernetes Cluster

Create or use an existing K8s cluster. Follow the guides to get the steps for specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-2-create-the-eks-cluster)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-2-create-the-aks-cluster)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-2-create-the-gke-cluster)

#### 3. Download GeoTax Docker Images

Download docker images and upload to your own container registry. Follow the guides to get the steps for specific cloud
platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-3-download-geotax-docker-images)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-3-download-geotax-docker-images)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-3-download-geotax-docker-images)

#### 4. Create a Persistent Volume

Create or user an existing persistent volume for storing geotax reference-data. Follow the guides to get the
steps for specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-4-create-elastic-file-system-efs)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-4-create-and-configure-azure-files-share)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-4-create-and-configure-google-filestore)

#### 5. Installation of GeoTax reference data

Download and install the geotax reference data in the persistent volume. Follow the guides to get the steps for
specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-5-installation-of-reference-data)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-5-installation-of-reference-data)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-5-installation-of-reference-data)

#### 6. Deploy the GeoTax application

Deploy the geotax application using helm. Follow the guides to get the steps for specific cloud platform:
[EKS](docs/guides/eks/QuickStartEKS.md#step-6-installation-of-geotax-helm-chart)
| [AKS](docs/guides/aks/QuickStartAKS.md#step-6-installation-of-geotax-helm-chart)
| [GKE](docs/guides/gke/QuickStartGKE.md#step-6-installation-of-geotax-helm-chart)

## Components

- [Reference Data Structure](docs/ReferenceData.md)
- [Pushing Docker Images (AWS ECR)](docs/guides/eks/QuickStartEKS.md#step-3-download-geotax-docker-images)
- [Pushing Docker Images (Microsoft ACR)](docs/guides/aks/QuickStartAKS.md#step-3-download-geotax-docker-images)
- [Pushing Docker Images (Google Artifact Registry)](docs/guides/gke/QuickStartGKE.md#step-3-download-geotax-docker-images)

## Guides

- [Reference Data Installation Helm Chart](charts/component-charts/reference-data-setup-generic/README.md)
- [Quickstart Guide For AWS EKS](docs/guides/eks/QuickStartEKS.md)
- [Quickstart Guide For Microsoft AKS](docs/guides/aks/QuickStartAKS.md)
- [Quickstart Guide For Google GKE](docs/guides/gke/QuickStartGKE.md)

## Setup

- [Local Setup](docker-desktop/README.md)
- [Kubernetes Setup](charts/component-charts/geotax-generic/README.md)

> NOTE: As of now, GeoTax helm chart is only supported for AWS Elastic Kubernetes Service, Azure Kubernetes Service and
> Google Kubernetes Engine.

## GeoTax Helm Version Chart

Following is the helm version chart against GeoTax PDX docker image version and Helm Release Version.

| Helm Chart Version → <br> Geotax Docker Image Version (Version/Vintage/ReleaseDate) ↓ | `1.0.0` | `2.0.0` |
|---------------------------------------------------------------------------------------|---------|---------|
| `1.0.0/2024.1/Jan 22, 2024`                                                           | ✔️      | ❌       |
| `1.0.0/2024.4/Apr 18, 2024`                                                           | ✔️      | ✔️      |

Refer Downloading GeoTax Docker Images
for [[EKS](docs/guides/eks/QuickStartEKS.md#step-3-download-geotax-docker-images) |[AKS](/docs/guides/aks/QuickStartAKS.md#step-3-download-geotax-docker-images) |[GKE](/docs/guides/gke/QuickStartGKE.md#step-3-download-geotax-docker-images)]
for more information.

## Miscellaneous

- [Metrics](docs/MetricsAndTraces.md#generating-insights-from-metrics)
- [Application Tracing](docs/MetricsAndTraces.md#generating-insights-from-metrics)
- [Logs and Monitoring](docs/MetricsAndTraces.md#generating-insights-from-metrics)
- [FAQs](docs/faq/FAQs.md)

## References

- [Releases](https://github.com/PreciselyData/cloudnative-geocoding-helm/releases)
- [Helm Values](charts/eks/geotax-application/README.md#helm-values)
- [Environment Variables](charts/component-charts/geotax-generic/README.md#environment-variables)
- [GeoTax Service API Usage](charts/component-charts/geotax-generic/README.md#geotax-service-api-usage)

## Links

- [Helm Chart Tricks](https://helm.sh/docs/howto/charts_tips_and_tricks/)
- [Nginx Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/)
