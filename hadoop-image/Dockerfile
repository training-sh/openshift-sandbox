FROM apache/hive:4.0.0@sha256:c0b241c544d341c16a6d8cafcb801a071be9b02054a5add255e9a0e826095e88 AS source
FROM eclipse-temurin:11-jre-jammy

COPY --from=source /opt/hadoop /opt/hadoop
COPY entrypoint.sh /opt/hdfs-entrypoint.sh
RUN sed -i 's/\r$//' /opt/hdfs-entrypoint.sh && chmod 755 /opt/hdfs-entrypoint.sh
ENV HADOOP_HOME=/opt/hadoop HADOOP_CONF_DIR=/etc/hadoop-lab HADOOP_LOG_DIR=/tmp/hadoop-logs \
    PATH=/opt/hadoop/bin:/opt/java/openjdk/bin:/usr/local/bin:/usr/bin:/bin
USER 1000:0
ENTRYPOINT ["/opt/hdfs-entrypoint.sh"]
