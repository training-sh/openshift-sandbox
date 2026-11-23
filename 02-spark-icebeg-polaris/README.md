# 02 — Spark, Iceberg and Polaris

Complete [00-setup](../00-setup/README.md) and open [JupyterLab](../00-setup/README.md#jupyterlab).

1. Download [spark-iceberg-polaris.ipynb](spark-iceberg-polaris.ipynb) using GitHub’s **Download raw file** button.
2. Upload it into JupyterLab and open it with the **Python 3** kernel.
3. Choose **Run → Run All Cells**. The last query displays `id = 1`.

## Run as an OpenShift Job

Use **Import YAML** for the following files in your assigned project.

1. Import [13-spark-iceberg-code.yaml](../manifests/13-spark-iceberg-code.yaml).
2. Import [13-spark-iceberg.yaml](../manifests/13-spark-iceberg.yaml). The Job uses the Iceberg JARs bundled in the Spark image.
3. In the **Administrator** perspective, open **Workloads → Pods**, select the pod whose name starts with `spark-iceberg-lab-`, and open **Logs**.

From Web Terminal, run these commands in the cloned `openshift-sandbox` directory with `PROJECT` set to your assigned project:

```bash
oc apply -n "$PROJECT" -f manifests/13-spark-iceberg-code.yaml
oc apply -n "$PROJECT" -f manifests/13-spark-iceberg.yaml
oc logs -n "$PROJECT" -f job/spark-iceberg-lab --pod-running-timeout=5m
oc wait -n "$PROJECT" --for=condition=complete job/spark-iceberg-lab --timeout=5m
```

The Job creates the `training` catalog in Polaris and runs this SQL. The first part of the table name, `polaris`, is Spark's alias for that catalog.

```sql
CREATE NAMESPACE IF NOT EXISTS polaris.sandbox;
CREATE TABLE IF NOT EXISTS polaris.sandbox.demo (id BIGINT) USING iceberg;
INSERT OVERWRITE polaris.sandbox.demo SELECT CAST(1 AS BIGINT);
SELECT id FROM polaris.sandbox.demo;
```

The query should return `1`. For the Job, look for `SPARK_ICEBERG_PASS` in the log. Polaris stores catalog state in PostgreSQL. Iceberg uses SeaweedFS for metadata and data files under `s3://warehouse/iceberg`. You can inspect those files in the [SeaweedFS Admin UI](../00-setup/README.md#seaweedfs-admin-ui).

Try changing the inserted number and the expected row in **Workloads → ConfigMaps → spark-iceberg-lab → YAML**. Save, delete the completed `spark-iceberg-lab` Job under **Workloads → Jobs**, and reimport the Job YAML. The table persists between runs.
