# Build the Spark image

Build this image once in your assigned OpenShift project before running the Spark labs. OpenShift fetches the Dockerfile and build context from the [GitHub repository](https://github.com/training-sh/openshift-sandbox).

1. Use [Import YAML](../00-get-started/README.md#import-a-manifest) to create the [Spark ImageStream](../manifests/07-spark-imagestream.yaml).
2. Import the [Spark BuildConfig](../manifests/08-spark-build.yaml). It points to the `spark-image` directory in this repository. If access to the repository requires authentication, configure a Git source Secret and set `spec.source.sourceSecret.name` before importing.
3. In the **Administrator** perspective, open **Builds → BuildConfigs → dataeng-spark**. Select **Start Build** from **Actions**. Use the build's **Logs** tab to check progress and wait for **Complete**.
4. Under **Builds → ImageStreams → dataeng-spark**, confirm the `3.5.9-5` tag appears. JupyterLab, Spark Master, and the Spark Jobs use this same-project image tag.

The build uses the pinned Spark 3.5.9 base from the CRC image, the same JAR versions (including Iceberg 1.10.0), and the CRC entrypoint. The sandbox lab Jobs call Spark directly so that the CRC storage and cluster defaults do not affect them. The build needs access to Docker Hub, Maven Central, PyPI, and the GitHub repository. Start the build from the console.

[OpenShift BuildConfig reference](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html-single/builds_using_buildconfig/index)
