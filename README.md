# OpenShift sandbox

Open the [GitHub repository](https://github.com/training-sh/openshift-sandbox) and navigate to [manifests](manifests). The guides below show which YAML files to import into your assigned OpenShift project and how to verify each deployment in the web console.

## Update an existing clone

From the `openshift-sandbox` directory, pull the latest changes before using the guides or applying manifests.

```bash
git pull --ff-only origin main
```

## Setup guides

Select the existing project assigned to your account. Skip `manifests/00-project.yaml` in OpenShift Developer Sandbox.

1. [00-get-started](00-get-started/README.md) — sign in, select your project, and learn to import YAML.
2. [20-mysql](20-mysql/README.md) — deploy and verify an independent MySQL database.
3. [Build the Spark image](spark-image/README.md#build-from-web-terminal) — list images and tags, start the build, and verify the published Spark tag.
4. [00-setup](00-setup/README.md) — deploy PostgreSQL, SeaweedFS, and Polaris, then open the HTTPS Routes for JupyterLab, SeaweedFS Admin, and Spark Master.
5. [01-spark-basic](01-spark-basic/README.md) — run a Spark DataFrame and SQL notebook in JupyterLab.
6. [02-spark-icebeg-polaris](02-spark-icebeg-polaris/README.md) — write and read an Iceberg table from a notebook using Spark and Polaris.
7. [HDFS and Hive Metastore](40-hdfs-hive/README.md) — build both images, reuse the MySQL backend, and query HDFS-backed tables from Spark.

The [manifests directory](manifests) contains one OpenShift resource per YAML file. Follow each guide's import order. Before using JupyterLab or Spark, [build the Spark image from GitHub](spark-image/README.md). The base stack uses 6 GiB of persistent storage. HDFS adds one 2 GiB claim, and Hive Metastore reuses the MySQL claim.

Spark can use both storage paths in the same project. Hive Metastore stores table metadata in MySQL and Spark reads the table files from HDFS. Polaris stores catalog metadata in PostgreSQL and Spark reads Iceberg table files from SeaweedFS.

The [setup guide](00-setup/README.md#4-open-the-lab-interfaces) provides HTTPS Routes for JupyterLab, SeaweedFS Admin, and Spark Master. Spark reaches HDFS, Hive Metastore, Polaris, and the SeaweedFS S3 API through internal Services.
