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




install_service(){
    echo Install Component Service
    current=${PWD}
    source .env
    # initial environment variables and create directories in case they dont exists.
    mkdir -p ${work_dir}/components/repos
    repo_dir=${work_dir}/components/repos
    mkdir -p ${work_dir}/components/routes
    route_dir=${work_dir}/components/routes
    load_ini_file './config/frontend.ini' && section_ini components
    domain_ip=${docker_ip}
    load_ini_file './config/components.ini' && section_ini default
    nginx_ip=${docker_ip}

    cp docker/components/default.conf $route_dir
    
    # edit main .env file
    edit_config "components_repos" ${repo_dir} .env
    edit_config "components_routes" ${route_dir} .env
    edit_config "components_domain_ip" ${domain_ip} .env
    edit_config "components_nginx_ip" ${nginx_ip} .env
    
    # create and edit .env file in docker/components
    cd docker/components
    if [ ! -f .env ]; then
        cp example.env .env
    fi
    edit_config "repos" ${repo_dir} .env
    edit_config "routes" ${route_dir} .env
    edit_config "domain_ip" ${domain_ip} .env
    edit_config "nginx_ip" ${nginx_ip} .env
    
   # echo components_repos=${work_dir}/components/repos >> .env
   # echo repos=${work_dir}/components/repos >> docker/components/.env
   # # create route directory
   # echo components_routes=${work_dir}/components/routes >> .env
   # echo routes=${work_dir}/components/routes >> docker/components/.env
#
 #   echo components_domain_ip=${docker_ip} >> .env
 #   echo domain_ip=${docker_ip} >> docker/components/.env
 #   
 #   echo components_nginx_ip=${docker_ip} >> .env
 #   echo nginx_ip=${docker_ip} >> docker/components/.env
    
    docker-compose up -d --force-recreate
    cd $current
    ./please frontend link "components"
    echo Component Service installed successfully
}



add_service(){
    source .env
    load_ini_file 'config/components.ini' && section_ini $1
    current=${PWD}
    cd ${components_repos} && 
    if ! [ -d $repo_name ] ; then
        git clone $repo
    fi
    cd $repo_name
    cp .env .env.bak
    cp example.env .env
    edit_config "docker_ip" ${docker_ip} .env
    edit_config "VUE_APP_BACKEND_URL" http://${api_subdomain} .env
    # build docker and start
    docker-compose up -d --build
    cd $current

    cd docker/components
    cp default.location ${components_routes}/${1}_${route}.location
    cd ${components_routes}
    sed -i s/{location}/${route}/g ${1}_${route}.location
    sed -i s/{proxy_pass}/${docker_ip}/g ${1}_${route}.location
    cd $current
    echo $1 is successfully link to domain ${route} with IP: ${docker_ip}.
    cd docker/components && docker-compose restart nginx
    cd $current
}

up_service() {
    load_ini_file 'config/components.ini' && section_ini $1
    current=${PWD}
    cd ${components_repos}/${repo_name} 
    make up
    cd $current
}

restart_service() {
    load_ini_file 'config/components.ini' && section_ini $1
    current=${PWD}
    cd ${components_repos}/${repo_name} 
    docker-compose restart
    cd $current
}

down_api_service(){
    load_ini_file 'config/components.ini' && section_ini $1
    current=${PWD}
    cd ${components_repos}/${repo_name} 
    make down
    cd $current
}

down_service() {
    load_ini_file 'config/components.ini' && section_ini $1
    current=${PWD}
    cd ${components_repos}/${repo_name} 
    docker-compose down
    cd $current
}

logs_service(){
    load_ini_file 'config/components.ini' && section_ini $1
    current=${PWD}
    cd ${components_repos}/${repo_name} 
    docker-compose logs "${@:2}"
    cd $current
}



case $1 in
    install)
        install_service "${@:2}";;
    add)
        add_service "${@:2}";;
    link)
        link_service "${@:2}";;
    add)
        add_service "${@:2}";;
    up)
        up_service "${@:2}";;
    restart)
        restart_service "${@:2}";;
    down)
        down_api_service "${@:2}";;
    logs)
        logs_service "${@:2}";;
    set)
        set_allow_origin "${@:2}";;
    help)
        print_help;;
    *)
        print_help
esac
