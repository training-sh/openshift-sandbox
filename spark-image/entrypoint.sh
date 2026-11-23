#!/usr/bin/env bash
set -euo pipefail
role=${1:-master}
mkdir -p "$SPARK_CONF_DIR" /data/spark-work

cat >"$SPARK_CONF_DIR/core-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>fs.defaultFS</name><value>${HDFS_URI:-hdfs://host.crc.internal:9000}</value></property>
  <property><name>fs.s3a.impl</name><value>org.apache.hadoop.fs.s3a.S3AFileSystem</value></property>
  <property><name>fs.s3a.endpoint</name><value>${S3_ENDPOINT:-http://seaweedfs:8333}</value></property>
  <property><name>fs.s3a.path.style.access</name><value>true</value></property>
  <property><name>fs.s3a.connection.ssl.enabled</name><value>false</value></property>
  <property><name>fs.s3a.aws.credentials.provider</name><value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value></property>
  <property><name>fs.s3a.access.key</name><value>${AWS_ACCESS_KEY_ID:-team}</value></property>
  <property><name>fs.s3a.secret.key</name><value>${AWS_SECRET_ACCESS_KEY:-team1234}</value></property>
</configuration>
EOF

cat >"$SPARK_CONF_DIR/spark-defaults.conf" <<EOF
spark.eventLog.enabled                         true
spark.eventLog.dir                             s3a://warehouse/spark-events
spark.history.fs.logDirectory                  s3a://warehouse/spark-events
spark.history.ui.port                          18080
spark.history.fs.cleaner.enabled               true
spark.history.fs.cleaner.maxAge                7d
spark.worker.cleanup.enabled                   true
spark.worker.cleanup.interval                  1800
spark.local.dir                                /data/spark-work
spark.hadoop.fs.s3a.endpoint                   ${S3_ENDPOINT:-http://seaweedfs:8333}
spark.hadoop.fs.s3a.path.style.access          true
spark.hadoop.fs.s3a.connection.ssl.enabled     false
spark.hadoop.fs.s3a.access.key                 ${AWS_ACCESS_KEY_ID:-team}
spark.hadoop.fs.s3a.secret.key                 ${AWS_SECRET_ACCESS_KEY:-team1234}
spark.sql.extensions                           org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,io.delta.sql.DeltaSparkSessionExtension
spark.sql.catalog.spark_catalog                org.apache.spark.sql.delta.catalog.DeltaCatalog
spark.sql.catalog.polaris                      org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.polaris.type                 rest
spark.sql.catalog.polaris.uri                  ${POLARIS_URI:-http://polaris:8181/api/catalog}
spark.sql.catalog.polaris.warehouse            training
spark.sql.catalog.polaris.credential           ${POLARIS_CLIENT_ID:-team}:${POLARIS_CLIENT_SECRET:-team1234}
spark.sql.catalog.polaris.scope                PRINCIPAL_ROLE:ALL
spark.sql.catalog.polaris.oauth2-server-uri    ${POLARIS_URI:-http://polaris:8181/api/catalog}/v1/oauth/tokens
spark.sql.catalog.polaris.io-impl              org.apache.iceberg.aws.s3.S3FileIO
spark.sql.catalog.polaris.s3.endpoint          ${S3_ENDPOINT:-http://seaweedfs:8333}
spark.sql.catalog.polaris.s3.path-style-access true
spark.sql.catalog.polaris.s3.access-key-id     ${AWS_ACCESS_KEY_ID:-team}
spark.sql.catalog.polaris.s3.secret-access-key ${AWS_SECRET_ACCESS_KEY:-team1234}
spark.sql.catalog.polaris.client.region        us-east-1
EOF

export HADOOP_CONF_DIR="$SPARK_CONF_DIR"
case "$role" in
  master)
    exec /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master \
      --host "${POD_IP:-0.0.0.0}" --port 7077 --webui-port 8080
    ;;
  worker)
    exec /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker \
      --cores "${SPARK_WORKER_CORES:-1}" --memory "${SPARK_WORKER_MEMORY:-1g}" \
      --webui-port 8081 spark://spark-master:7077
    ;;
  history)
    exec /opt/spark/bin/spark-class org.apache.spark.deploy.history.HistoryServer
    ;;
  jupyter)
    export HOME=/workspace
    export JUPYTER_RUNTIME_DIR=/tmp/jupyter-runtime
    mkdir -p "$JUPYTER_RUNTIME_DIR"
    export PYSPARK_PYTHON=python3
    export PYSPARK_DRIVER_PYTHON=python3
    export PYSPARK_SUBMIT_ARGS="--master spark://spark-master:7077 --conf spark.driver.host=${POD_IP:-spark-master-0.spark-master.bigdata.svc.cluster.local} --conf spark.driver.bindAddress=0.0.0.0 --conf spark.driver.memory=512m pyspark-shell"
    exec python3 -m jupyter lab \
      --ip=0.0.0.0 --port=8888 --no-browser \
      --ServerApp.root_dir=/workspace \
      --ServerApp.allow_remote_access=True \
      --IdentityProvider.token="${JUPYTER_TOKEN:-team1234}"
    ;;
  submit)
    shift
    exec /opt/spark/bin/spark-submit "$@"
    ;;
  *) echo "Unknown Spark role: $role" >&2; exit 2 ;;
esac
