#!/bin/bash

function install_zookeeper_kafka {
    echo "================================"
    echo "Deploying Kafka..."

    helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
    helm repo update

    helm install kafka incubator/kafka -f ${WORKSPACE}/kafka/kafka-values.yaml

    echo "kafka deployed..."
}


function deploy_postgres_ha {
    echo "====================================="
    echo "Starting to deploy postgres-ha..."

    helm repo add iomedstolon https://iomedhealth.github.io/helm_stolon/
    helm repo update

    helm -n ${NS} install postgres-ha iomedstolon/stolon --devel \
    --timeout 30m \
    --debug \
    --values ${WORKSPACE}/postgres-ha/postgres-ha-values.yaml

    echo "Postgres-ha has been deployed successfully..."
}

function deploy_carrental_chart {
    echo "====================================="
    echo "Starting to deploy apis..."

    helm -n ${NS} install api ../charts/car-rental --devel \
    --timeout 30m \
    --debug \
    --values ${WORKSPACE}/override.yaml

    echo "apis have been deployed successfully..."
}

function main() {
    echo "====================================="
    echo "auth-api Version: ${AUTH_API_VERSION}"
    echo "cars-api Version: ${CARS_API_VERSION}"
    echo "====================================="
    
    echo "Starting to deploy car rental application..."

    set -e

    # install_zookeeper_kafka

    deploy_postgres_ha

    deploy_carrental_chart

    echo "====================================="

    echo "Application has been deployed successfully..."
}

main "${@}"
