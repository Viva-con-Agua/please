#!/bin/bash
docker=./docker/nats
source ./config/helper
source .env
source src/default.sh


print_help(){
    echo "Commands: "
    echo "  install        # install nats-deploy."
    echo "  up             # handles docker-compose up." 
    echo "  help           # print this page."
}

install_service(){
    load_config_service nats
    cd $docker
    echo deploy_mode=${api_net_ip} > .env
    echo api_net_ip=${api_net_ip} >> .env
    docker-compose up -d
}



case $1 in 
    install) 
        install_service "${@:2}";;
    *) print_help
esac
