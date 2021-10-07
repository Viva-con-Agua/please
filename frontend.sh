#!/bin/bash
# ###
# DOMAIN DEPLOYMENT
source .env
source config/helper

current=${PWD}


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

# ###
# install_service
install_service() {
    load_ini_file 'config/frontend.ini' && section_ini $1
    current=${PWD}
    cd ${frontend_repos} && 
    if ! [ -d $repo_name ] ; then
        git clone $repo
    fi
    cd $repo_name
    cp .env .env.bak
    cp example.env .env
    edit_config "docker_ip" ${docker_ip} .env
    edit_config "VUE_APP_BACKEND_URL" ${api_subdomain} .env
    docker-compose up -d --build
    cd $current
    link_service $1
}

# ###
# link_service
link_service() {
    # loads config.ini and section $1 
    load_ini_file 'config/frontend.ini' && section_ini $1
    # store current directory
    current=${PWD}
    cd docker/frontend
    # create new nginx config
    case $deploy_mode in
        # in case $deploy_mode == live:
        live) 
            # create a new nginx config in subdomain directory.
            cp ./default.live.conf ${frontend_subdomain}/${route}.${domain}.conf;
            # change current directory to subdomain
            cd ${subdomain};
            # sed certificate in nginx config
            sed -i s/{cretificate}/${certificate}/g ${route}.${domain}.conf;;
        # else:    
        *)  
            # create a new nginx config in subdomain directory.
            cp ./default.dev.conf ${frontend_subdomain}/${route}.${domain}.conf;
            # change current directory to subdomain
            cd ${frontend_subdomain};
    esac
    # sed subdomain route in nginx config
    sed -i s/{subdomain}/${route}.${domain}/g ${route}.${domain}.conf
    # sed proxy_pass in nginx config
    sed -i s/{proxy_pass}/${docker_ip}/g ${route}.${domain}.conf
    # change directory to current
    cd $current
    echo $1 is successfully link to domain ${route} with IP: ${docker_ip}.
    cd docker/frontend && docker-compose restart nginx
    # restart_service
}
# ###
# up_service 
up_service() {
    case $deploy_mode in
        live) docker-compose -f docker-compose.yml -f docker-compose.live.yml up -d ;;
        *) docker-compose up -d
    esac
}

# ###
# restart_service
restart_service(){
    case $deploy_mode in
        live) docker-compose -f docker-compose.yml -f docker-compose.live.yml restart ;;
        *) docker-compose restart
    esac
}
# ###
# down_service
down_service(){
    case $deploy_mode in
        live) docker-compose -f docker-compose.yml -f docker-compose.live.yml down ;;
        *) docker-compose down
    esac

}
# ###
# logs_service
logs_service() {
    case $deploy_mode in
        live) docker-compose -f docker-compose.yml -f docker-compose.live.yml "${@:1}" ;;
        *) docker-compose logs "${@:1}"
    esac

}

case $1 in
    install)
        install_service "${@:2}";;
    link)
        link_service "${@:2}";;
    up)
        up_service ;;
    restart)
        restart_service;;
    down)
        down_service;;
    logs)
        logs_service "${@:2}";;
    help)
        print_help;;
    *)
        print_help
esac
