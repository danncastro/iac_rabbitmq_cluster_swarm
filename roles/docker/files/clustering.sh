#!/bin/bash
# "Danniel Gutierres de Castro"
# Script to manage the containers clustering

#Clustering node
RABBIT="rabbitmqctl stop_app; rabbitmqctl join_cluster rabbit@rabbitmq1; rabbitmqctl start_app"

node_name=$(docker container list --format {{.Names}})
node_name=$(echo "${node_name%.*}")

container_name1="rabbitmq-cluster_rabbitmq1.1"
container_name2="rabbitmq-cluster_rabbitmq2.1"
container_name3="rabbitmq-cluster_rabbitmq3.1"

if [ $node_name == $container_name2 ]

then
    docker exec -ti $(docker container list --format {{.Names}}) bash -c "$RABBIT"
else
    echo "Proximo container"
fi

if [ $node_name == $container_name3 ]

then
    docker exec -ti $(docker container list --format {{.Names}}) bash -c "$RABBIT"
else
    echo "Proximo container"
fi

if [ $node_name == $container_name1 ]

then
    docker cp /$USER/rabbitmq/definitions.json $(docker container list --format {{.Names}}):/etc/rabbitmq/
    docker cp /$USER/rabbitmq/rabbitmq.conf $(docker container list --format {{.Names}}):/etc/rabbitmq/

    docker exec -ti $(docker container list --format {{.Names}}) bash -c "rabbitmqctl delete_user guest"
    docker exec -ti $(docker container list --format {{.Names}}) bash -c "rabbitmqctl delete_vhost /"
    docker exec -it $(docker container list --format {{.Names}}) bash -c "rabbitmqctl stop_app; rabbitmqctl start_app"
else
    echo "Algo deu errado"
fi