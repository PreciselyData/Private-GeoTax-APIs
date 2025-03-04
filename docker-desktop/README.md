# Precisely GeoTax Service Setup on Local Docker Desktop

The GeoTax application can be setup locally for test purpose.

## Step 1: Download Reference Data and Required Docker Images

To run the docker images locally, reference data and docker images should be downloaded from Precisely Data Experience.
> For more information on downloading the docker images, follow [this section](../scripts/eks/images-to-ecr-uploader/README.md#download-and-upload-docker-images-to-ecr).
> 
> For more information on reference data and downloading docker images, follow [this section](../docs/ReferenceData.md).
>

## Step 2: Running Service Locally

**Note:** ***Local application setup is only supported on machines with an amd64 chipset and Docker Desktop installed.***


Modify the below variables in ****.env**** file and run the mentioned command.

_DATA_PATH -> path to the **extracted** data

_SERVICE_PORT -> port at which service should be started (Example 8080)

***Sample Values:***

 ```shell
 _DATA_PATH=/data/geotax
 _SERVICE_PORT=8080
 ```

    ```shell
    docker compose -p [PROJECT_NAME] -f ./docker-compose.yml up -d
    ```

    *Example:*
    ```shell
    docker compose -p geotax-application -f ./docker-compose.yml up -d
    ```

    After executing the above command the service will start at http://localhost:[_SERVICE_PORT]

## Cleanup of local services

    Regardless of any above method of running the services locally below cleanup command will be same.

    ```shell
    docker compose -p [PROJECT_NAME] down
    ```

    *Example:*
    ```shell
    docker compose -p geotax-application down
    ```

## References

- [Sample API Usage](../charts/eks/geotax-application/README.md#geotax-service-api-usage)

[🔗 Return to `Table of Contents` 🔗](../README.md#setup)