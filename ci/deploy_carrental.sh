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

    if [[ "${CLEANUP_NAMESPACE}" == "true" ]]; then
        kubectl delete ns ${NS} --ignore-not-found
        kubectl create ns ${NS}
    fi

    # install_zookeeper_kafka

    deploy_postgres_ha

    deploy_carrental_chart

    echo "====================================="

    AUTH_API_ADMIN_USERNAME=$(kubectl -n ${NS} get secret admin-secret -o go-template="{{ .data.auth_api_admin_user | base64decode }}")
    AUTH_API_ADMIN_PASSWORD=$(kubectl -n ${NS} get secret admin-secret -o go-template="{{ .data.auth_api_admin_user_password | base64decode }}")

    jq -n \
        --arg uu "http://localhost:3000" \
        --arg u "${AUTH_API_ADMIN_USERNAME}" \
        --arg pw "${AUTH_API_ADMIN_PASSWORD}" \
        --arg dt "$(date -Iseconds)" \
        '{ui_url: $uu, admin_user: $u, admin_password: $pw, deployed: $dt}' > carrental_deployment.json

    echo "Application has been deployed successfully..."
}

main "${@}"
