#!/bin/bash

source .env
source config/helper
docker=./docker/api
print_help(){
    echo help
}

# echo install $1=deploy_mode $2=work_dir $3=domain_net_ip
install_service() {
    load_config_service api
    cd $docker
    echo deploy_mode=${1} > .env
    mkdir -p ${work_dir}/api_v1
    cp ./default.conf ${work_dir}/api_v1/default.conf
    echo api_v1_path=${work_dir}/api_v1 >> .env
    mkdir -p ${repos_dir}/api
    echo api_v1_repos=${repos_dir}/api >> .env
    echo domain_net_ip=${domain_net_ip} >> .env
    echo api_net_ip=${api_net_ip} >> .env
    docker-compose up -d
}

# $1 == name, $2 == domain_net_ip, $3 == route
link_service() {
    load_config_service $1
    cd $docker
    current=${PWD}
    cp default.location ${api_v1_path}/${1}_${route}.location
    cd ${api_v1_path}
    sed -i s/{location}/${route}/g ${1}_${route}.location
    sed -i s/{proxy_pass}/${api_net_ip}/g ${1}_${route}.location
    cd $current
    echo $1 is successfully link to domain ${route} with IP: ${api_net_ip}.
    docker-compose restart
}

up_service() {
    cd $docker
    docker-compose up -d
}

restart_service() {
    cd $docker
    docker-compose restart
}

logs_service(){
    cd $docker
    if [ -z ${1} ]; then
        docker-compose logs
    else 
        docker-compose logs --tail $1
    fi
}

case $1 in
    install)
        install_service "${@:2}";;
    link)
        link_service "${@:2}";;
    logs)
        logs_service;;
    *) print_help
esac
