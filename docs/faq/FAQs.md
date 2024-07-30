## FAQs

If you encounter any challenges or have questions during the deployment of the GeoTax helm chart, we recommend
checking the below questions. This resource provides answers to common questions and solutions to known issues, offering
assistance in troubleshooting any deployment-related difficulties you may encounter. If your question is not covered in
the FAQs, feel free to reach out to our support team for personalized assistance.

<br>

1. How can I monitor the GeoTax Helm Chart installation?
   <br><br>
   Once you run the helm chart command, you can monitor the helm chart creation by using the following command:

   ```
   kubectl get pods -n [geotax-application] -w
   ```

2. How to check the logs in case of unsuccessful installation?
   <br><br>
   In case of failure during helm chart installation, you can view the status of the pods by using the following
   command:
   ```
   kubectl get pods -n [geotax-application]
   ```
   For each failed pod, you can check the logs or describe the pods for viewing the failure events with the following
   command:
   ```shell
   kubectl logs -f [pod-name] -n [geotax-application]
   kubectl describe pod [pod-name] -n [geotax-application]
   ```

   The GeoTax helm chart runs few jobs also, in that case, you might also want to check the failed jobs using
   following command:
   ```shell
   kubectl get jobs -n [geotax-application]
   ```
   You can view the logs or describe the job for failure events using following command:
   ```shell
   kubectl logs -f [job-name] -n [geotax-application]
   kubectl describe job [job-name] -n [geotax-application]
   ```

3. How to clean up the resources if the helm-chart installation is unsuccessful?
   <br><br>
   Helm command will fail mostly because of missing mandatory parameters or not overriding few of the default
   parameters. Apart from mandatory parameters, you can always override the default values in
   the [values.yaml](../../charts/eks/geotax-application/values.yaml) file by using the --set parameter.

   However, you can view the logs and fix those issues by cleaning up and rerunning the helm command.
    ```shell
    kubectl describe pod [POD-NAME] -n [geotax-application]
    kubectl logs [POD-NAME] -n [geotax-application]
    ```

   To clean up the resources, use the following commands:
    ```shell
    helm uninstall geotax-application -n [geotax-application]
    kubectl delete job geotax-application-hook-data-vintage -n [geotax-application]
    kubectl delete pvc hook-geotax-application-pvc -n [geotax-application]
    ```

[🔗 Return to `Table of Contents` 🔗](../../README.md#miscellaneous)