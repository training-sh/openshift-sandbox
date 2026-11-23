# OpenShift sandbox

Open the [GitHub repository](https://github.com/training-sh/openshift-sandbox) and navigate to [manifests](manifests). The guides below show which YAML files to import into your assigned OpenShift project and how to verify each deployment in the web console.

1. [00-get-started](00-get-started/README.md) — sign in, select your project, and learn to import YAML.
2. [20-mysql](20-mysql/README.md) — deploy and verify an independent MySQL database.
3. [00-setup](00-setup/README.md) — deploy PostgreSQL, SeaweedFS, and Polaris, then open the HTTPS Routes for JupyterLab, SeaweedFS Admin, and Spark Master.
4. [01-spark-basic](01-spark-basic/README.md) — run a Spark DataFrame and SQL notebook in JupyterLab.
5. [02-spark-icebeg-polaris](02-spark-icebeg-polaris/README.md) — write and read an Iceberg table from a notebook using Spark and Polaris.

The [manifests directory](manifests) contains one OpenShift resource per YAML file. Follow each guide's import order. MySQL is independent. Before using JupyterLab or Spark, [build the Spark image from GitHub](spark-image/README.md). The full stack uses four PVCs totaling 6 GiB, including 1 GiB for notebooks.
