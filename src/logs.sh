#!/bin/bash
source ./config/helper
source .env

print_help(){
    echo "Commands: "
    echo "  install        # install nats-deploy."
    echo "  up             # handles docker-compose up." 
    echo "  help           # print this page."
}

install_service(){
    load_config_service logs
    cd docker/logs
    echo deploy_mode=${deploy_mode} > .env
    echo database_dir=${work_dir}/databases >> .env
    echo api_net_ip=${api_net_ip} >> .env
    echo NATS_HOST=${nats_net_ip} >> .env
    echo DB_HOST=db >> .env
    echo DB_PORT=27017 >> .env
    up_service
}

up_service(){
    docker-compose up -d
}


case $1 in 
    install) 
        install_service "${@:2}";;
    up)
        up_service;;
    *) print_help
esac
