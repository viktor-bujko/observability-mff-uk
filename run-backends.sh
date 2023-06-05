#!/bin/bash 

set -eu

# TODO Modify following *_HOME variables to your environment. (*_HOME variable has a value of installation directory of the specific backend.)
LOKI_HOME="./libs/loki-linux-amd64" #"${HOME}/dev/loki"
PROMETHEUS_HOME="./libs/prometheus-2.37.8.linux-amd64" #"${HOME}/dev/prometheus"
JAEGER_HOME="./libs/jaeger-1.33.0-linux-amd64" #"${HOME}/dev/jaeger"
GRAFANA_HOME="./libs/grafana-9.5.2" #"${HOME}/dev/grafana"
PWD=$(pwd)

./kill-backends.sh

# TODO Modify following binary names according your environment.
echo "Starting Loki in the background..."
"${LOKI_HOME}/loki-linux-amd64" -config.file "${PWD}/_config/loki/loki-local-config.yaml" > /dev/null 2>&1 &

echo "Starting Promtail in the background..."
"${LOKI_HOME}/promtail-linux-amd64" -config.file "${PWD}/_config/loki/promtail-local-config.yaml" > /dev/null 2>&1 &

echo "Starting Prometheus in the background..."
"${PROMETHEUS_HOME}/prometheus" --config.file "${PWD}/_config/prometheus/prometheus.yml" --storage.tsdb.path="_tmp/prometheus/data/" > /dev/null 2>&1 &

echo "Starting Jaeger in the background..."
"${JAEGER_HOME}/jaeger-all-in-one" --collector.zipkin.host-port=:9411 > /dev/null 2>&1 &

echo "Starting Grafana in the background..."
"${GRAFANA_HOME}/bin/grafana" -homepath "${GRAFANA_HOME}" > /dev/null 2>&1 &

echo "Starting downstream services in the background..."
./observability -p 5050 -n downstream-1 -d "http://localhost:6060" &
./observability -p 6060 -n downstream-2 &
