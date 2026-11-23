FROM apache/hive:4.0.0@sha256:c0b241c544d341c16a6d8cafcb801a071be9b02054a5add255e9a0e826095e88
USER root
ADD https://repo.maven.apache.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar /opt/hive/lib/mysql-connector-j-8.4.0.jar
COPY entrypoint.sh /opt/metastore-entrypoint.sh
RUN sed -i 's/\r$//' /opt/metastore-entrypoint.sh && chmod 644 /opt/hive/lib/mysql-connector-j-8.4.0.jar && chmod 755 /opt/metastore-entrypoint.sh
ENV HIVE_CONF_DIR=/tmp/hive-conf HADOOP_CONF_DIR=/etc/hadoop-lab HADOOP_LOG_DIR=/tmp/hadoop-logs \
    HOME=/tmp HADOOP_USER_NAME=team
USER 1000:0
ENTRYPOINT ["/opt/metastore-entrypoint.sh"]
