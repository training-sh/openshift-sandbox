#!/bin/sh
set -eu
mkdir -p "$HADOOP_LOG_DIR"
case "$1" in
  namenode)
    mkdir -p /data/namenode
    if [ ! -f /data/namenode/current/VERSION ]; then
      if [ -n "$(ls -A /data/namenode)" ]; then
        echo "NameNode storage contains files but has no VERSION." >&2
        exit 1
      fi
      hdfs namenode -format -nonInteractive
    fi
    exec hdfs namenode
    ;;
  datanode)
    mkdir -p /data/datanode
    exec hdfs datanode
    ;;
  *)
    echo "Expected namenode or datanode." >&2
    exit 2
    ;;
esac
