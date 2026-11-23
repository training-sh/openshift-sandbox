# HDFS and Hive Metastore

This setup runs one HDFS pod with a NameNode and a DataNode, backed by a shared 2 GiB PVC. A single Hive Metastore deployment uses the existing MySQL database `hive_metastore`. Spark uses the Hive client bundled in its image to query the metastore over Thrift and data files directly over HDFS.

Complete [MySQL](../20-mysql/README.md) and [build the Spark image](../spark-image/README.md) first. Run the commands below from the cloned repository in OpenShift Web Terminal. Set `PROJECT` to your assigned project, then follow each stage after the previous checks pass.

```bash
PROJECT='your-project-name'
```

## Build the Hadoop and Hive Metastore images

The [Hadoop image directory](../hadoop-image) contains the HDFS build context. The [Hive image directory](../hive-image) contains the metastore build context and downloads only the MySQL JDBC driver. OpenShift fetches each Dockerfile from this GitHub repository.

```bash
oc get imagestreams,imagestreamtags -n "$PROJECT"

oc apply -n "$PROJECT" -f manifests/40-hadoop-imagestream.yaml
oc apply -n "$PROJECT" -f manifests/40-hadoop-build.yaml
oc start-build -n "$PROJECT" dataeng-hadoop --follow --wait

oc apply -n "$PROJECT" -f manifests/41-hive-metastore-imagestream.yaml
oc apply -n "$PROJECT" -f manifests/41-hive-metastore-build.yaml
oc start-build -n "$PROJECT" dataeng-hive-metastore --follow --wait

oc get builds,imagestreams,imagestreamtags -n "$PROJECT"
oc get istag -n "$PROJECT" dataeng-hadoop:3.3.6-1
oc get istag -n "$PROJECT" dataeng-hive-metastore:4.0.0-1
```

In the console, you can import the same ImageStream and BuildConfig files, then open **Builds → BuildConfigs** and select **Start Build** for each image. Wait for both builds to finish.

## Start HDFS

```bash
oc apply -n "$PROJECT" -f manifests/42-hdfs-config.yaml
oc apply -n "$PROJECT" -f manifests/43-hdfs-service.yaml
oc apply -n "$PROJECT" -f manifests/43-hdfs-pvc.yaml
oc apply -n "$PROJECT" -f manifests/43-hdfs.yaml
oc rollout status -n "$PROJECT" statefulset/hdfs --timeout=10m
oc exec -n "$PROJECT" hdfs-0 -c namenode -- hdfs dfsadmin -report
oc exec -n "$PROJECT" hdfs-0 -c namenode -- hdfs dfsadmin -safemode get
```

Confirm the report shows **one live DataNode** and that HDFS has exited safe mode. The in-project HDFS address is `hdfs://namenode:9000`. Keep the `hdfs-data` claim when restarting the pod.

## Initialize the MySQL schema and start the metastore

If `hive-schema` already shows **Complete**, keep it and skip the schema apply command.

```bash
oc rollout status -n "$PROJECT" statefulset/mysql --timeout=10m
oc apply -n "$PROJECT" -f manifests/44-hive-schema.yaml
oc wait -n "$PROJECT" --for=condition=complete job/hive-schema --timeout=10m
oc logs -n "$PROJECT" job/hive-schema

oc apply -n "$PROJECT" -f manifests/45-hive-metastore-service.yaml
oc apply -n "$PROJECT" -f manifests/45-hive-metastore.yaml
oc rollout status -n "$PROJECT" deployment/hive-metastore --timeout=10m
```

Wait for the schema Job to complete before deploying the metastore. Its in-project address is `thrift://hive-metastore:9083`. The setup runs only the Hive Metastore service.

## Verify with Spark

In JupyterLab, upload and run [spark-hdfs-hive.ipynb](spark-hdfs-hive.ipynb) using the Python 3 kernel. If the kernel already has a Spark session, restart the kernel before running the notebook so the Hive settings take effect.

To run the same program as an OpenShift Job:

```bash
oc apply -n "$PROJECT" -f manifests/46-spark-hdfs-hive-code.yaml
oc apply -n "$PROJECT" -f manifests/46-spark-hdfs-hive.yaml
oc logs -n "$PROJECT" -f job/spark-hdfs-hive --pod-running-timeout=5m
oc wait -n "$PROJECT" --for=condition=complete job/spark-hdfs-hive --timeout=10m
```

Look for `SPARK_HDFS_HIVE_PASS`. The example writes and reads Parquet in HDFS, registers `hdfs_demo.orders` in Hive Metastore, and checks that the table reads back one row from HDFS.

To rerun the verification Job, delete the completed `spark-hdfs-hive` Job in your project, then apply its Job YAML again.
