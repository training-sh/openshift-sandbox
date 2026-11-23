#!/bin/sh
set -eu
umask 077
mkdir -p "$HADOOP_LOG_DIR" "$HIVE_CONF_DIR"
xml_escape() {
  printf '%s' "$1" | sed -e 's/\&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}
cat >"$HIVE_CONF_DIR/hive-site.xml" <<EOF
<configuration>
  <property><name>javax.jdo.option.ConnectionURL</name><value>jdbc:mysql://${MYSQL_HOST:-mysql}:3306/hive_metastore?useSSL=false&amp;allowPublicKeyRetrieval=true&amp;serverTimezone=UTC</value></property>
  <property><name>javax.jdo.option.ConnectionDriverName</name><value>com.mysql.cj.jdbc.Driver</value></property>
  <property><name>javax.jdo.option.ConnectionUserName</name><value>$(xml_escape "$HIVE_DB_USER")</value></property>
  <property><name>javax.jdo.option.ConnectionPassword</name><value>$(xml_escape "$HIVE_DB_PASSWORD")</value></property>
  <property><name>hive.metastore.warehouse.dir</name><value>/user/hive/warehouse</value></property>
  <property><name>hive.metastore.schema.verification</name><value>true</value></property>
  <property><name>datanucleus.schema.autoCreateAll</name><value>false</value></property>
</configuration>
EOF
case "$1" in
  schema)
    exec /opt/hive/bin/schematool -dbType mysql -initOrUpgradeSchema
    ;;
  metastore)
    exec /opt/hive/bin/hive --service metastore
    ;;
  *)
    echo "Expected schema or metastore." >&2
    exit 2
    ;;
esac
