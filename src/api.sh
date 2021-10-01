#!/bin/bash

source .env
print_help(){
    echo help
}

# echo install $1=deploy_mode $2=work_dir $3=domain_net_ip
install_service() {
    load_config_service api
    cd .docker/api
    echo deploy_mode=${1} > .env
    mkdir -p ${work_dir}/api_v1
    cp ./default.conf ${work_dir}/api_v1/default.conf
    echo api_v1_path=${work_dir}/api_v1 >> .env
    mkdir -p ${repos_dir}/api
    echo api_v1_repos=${repos_dir}/api >> .env
    echo domain_net_ip=${domain_net_ip} >> .env
    echo api_net_ip=${api_net_ip} >> .env
    up_service
}

# $1 == name, $2 == domain_net_ip, $3 == route
link_service() {
    current=${PWD}
    cp default.location 
    cd ${api_v1_path}
    sed -i s/{location}/${3}/g ${3}.conf
    sed -i s/{proxy_pass}/${2}/g ${3}.conf
    cd $current
    echo $1 is successfully link to domain ${3} with IP: $2.
    restart_service
}

up_service() {
    docker-compose up -d
}

restart_service() {
    docker-compose restart
}

logs_service() {
    docker-compose logs
}

case $1 in
    install)
        install_service "${@:2}";;
    link)
        link_service "${@:2}";;
    logs)
        logs_service;;
    *) print_help
