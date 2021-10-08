#!/bin/bash

touch .env
source .env
source config/helper


print_help() {
    echo   " Commands: install, link, up, restart, down, logs "
    echo   "     install         install domain_service"
    echo   "     link            service_name  connect an service and domain"
    echo   "     up              create and start service"
    echo   "     restart         restarts service"
    echo   "     down            delete service docker"
    echo   "     logs            get docker logs"
    echo   "     help            print this page"
}



edit_config(){
    case $2 in
        .env)
            echo $1;;
        *)
            pattern="/${1}=/c${1}=${2}"
            sed -i ${pattern} ${3}
    esac

}

install_service(){
    load_ini_file 'config/api.ini' && section_ini $1
    current=${PWD}
    cd ${api_repos} && 
    if ! [ -d $repo_name ] ; then
        git clone $repo
    fi
    cd $repo_name
    cp .env .env.bak
    cp example.env .env
    edit_config "docker_ip" ${docker_ip} .env
    edit_config "databases" ${api_databases} .env
    #edit_config "version" "stage" .env
    edit_config "NATS_HOST" $NATS_HOST .env
    edit_config "ALLOW_ORIGINS" $ALLOW_ORIGINS .env
    edit_config "COOKIE_SECURE" $COOKIE_SECURE .env
    edit_config "SAME_SITE" $SAME_SITE .env
    edit_config "IDJANGO_EXPORT" $IDJANGO_EXPORT .env
    edit_config "IDJANGO_KEY" $IDJANGO_KEY .env
    edit_config "IDJANGO_URL" $IDJANGO_URL .env
    edit_config "LOGGER_OUTPUT" $LOGGER_OUTPUT .env
    vim .env
    cd $current
    up_service $1
    link_service $1
}

# $1 == name, $2 == domain_net_ip, $3 == route
link_service() {
    current=${PWD}
    load_ini_file 'config/api.ini' && section_ini $1
    cp default.location ${api_routes}/${1}_${route}.location
    cd ${api_routes}
    sed -i s/{location}/${route}/g ${1}_${route}.location
    sed -i s/{proxy_pass}/${docker_ip}/g ${1}_${route}.location
    cd $current
    echo $1 is successfully link to domain ${route} with IP: ${docker_ip}.
    cd docker/api && docker-compose restart nginx
    cd $current
}

up_service() {
    load_ini_file 'config/api.ini' && section_ini $1
    current=${PWD}
    cd ${api_repos}/${repo_name} 
    make please
    cd $current
}

restart_service() {
    load_ini_file 'config/api.ini' && section_ini $1
    current=${PWD}
    cd ${api_repos}/${repo_name} 
    docker-compose restart
    cd $current
}

down_api_service(){
    load_ini_file 'config/api.ini' && section_ini $1
    current=${PWD}
    cd ${api_repos}/${repo_name} 
    make down
    cd $current
}

down_service() {
    load_ini_file 'config/api.ini' && section_ini $1
    current=${PWD}
    cd ${api_repos}/${repo_name} 
    docker-compose down
    cd $current
}

logs_service(){
    load_ini_file 'config/api.ini' && section_ini $1
    current=${PWD}
    cd ${api_repos}/${repo_name} 
    docker-compose logs "${@:2}"
    cd $current
}

case $1 in
    install)
        install_service "${@:2}";;
    link)
        link_service "${@:2}";;
    add)
        add_service "${@:2}";;
    up)
        up_service ;;
    restart)
        restart_service;;
    down)
        down_api_service "${@:2}";;
    logs)
        logs_service;;
    help)
        print_help;;
    *)
        print_help
esac
