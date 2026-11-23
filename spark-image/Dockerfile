FROM apache/spark:3.5.9-scala2.12-java11-python3-ubuntu@sha256:af02a459c8706e031c835c16f9db3c463816776e2543dd0f828af65606bcf392

USER root
COPY maven-jars.txt /opt/training/maven-jars.txt
RUN python3 -c 'from pathlib import Path; from urllib.request import urlretrieve; base = "https://repo.maven.apache.org/maven2/"; paths = Path("/opt/training/maven-jars.txt").read_text().splitlines(); [urlretrieve(base + path, "/opt/spark/jars/" + path.rsplit("/", 1)[-1]) for path in paths if path]' \
    && python3 -m pip install --no-cache-dir jupyterlab==4.4.10 ipykernel==6.30.1

COPY entrypoint.sh /opt/training/entrypoint.sh
RUN sed -i 's/\r$//' /opt/training/entrypoint.sh \
    && chmod 755 /opt/training/entrypoint.sh \
    && mkdir -p /data/spark-work /workspace \
    && chown -R 185:0 /data /workspace \
    && chmod -R g=u /data /workspace
USER 185:0

ENV SPARK_HOME=/opt/spark \
    JAVA_HOME=/opt/java/openjdk \
    SPARK_CONF_DIR=/tmp/spark-conf \
    PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9.7-src.zip \
    PATH=/opt/spark/bin:/opt/spark/sbin:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EXPOSE 7077 8080 8081 8888 18080
ENTRYPOINT ["/opt/training/entrypoint.sh"]
CMD ["master"]
