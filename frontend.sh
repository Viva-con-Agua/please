#!/bin/bash
# ###
# Frontend DEPLOYMENT
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
    #load frontend.ini config file and select service
    load_ini_file 'config/frontend.ini' && section_ini $1
    # store current directory in current variable
    current=${PWD}
    # change directory to frontend_repos
    cd ${frontend_repos} && 
    # check if the repo exists and clone it from github in case it isn't.
    if ! [ -d $repo_name ] ; then
        git clone $repo
    fi
    # change directory to repo
    cd $repo_name
    # backup the old and initial a new .env
    cp .env .env.bak
    cp example.env .env
    # edit .env 
    edit_config "docker_ip" ${docker_ip} .env
    edit_config "VUE_APP_BACKEND_URL" ${api_subdomain} .env
    # build docker and start
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
    # load frontend.ini config file and select service $1
    load_ini_file 'config/frontend.ini' && section_ini $1
    # store current directory in current variable
    current=${PWD}
    # change directory to frontend_repos/repo_name
    cd ${frontend_repos}/${repo_name} 
    # change directory to frontend_repos/repo_name
    docker-compose up -d --build
    cd $current
}

# ###
# restart_service
restart_service(){ 
    # load frontend.ini config file and select service $1
    load_ini_file 'config/frontend.ini' && section_ini $1
    # store current directory in current variable
    current=${PWD}
    # change directory to frontend_repos/repo_name
    cd ${frontend_repos}/${repo_name} 
    # looking for deploy_mode and restart services
    docker-compose restart
    cd $current
}

# ###
# restart_service
update_service(){ 
    # load frontend.ini config file and select service $1
    load_ini_file 'config/frontend.ini' && section_ini $1
    # store current directory in current variable
    current=${PWD}
    # change directory to frontend_repos/repo_name
    cd ${frontend_repos}/${repo_name} 
    # pull repo
    git pull
    # change directory to $current
    cd $current
    # up_service
    up_service $1
}


# ###
# down_service
down_service(){
    # load frontend.ini config file and select service $1
    load_ini_file 'config/frontend.ini' && section_ini $1
    # store current directory in current variable
    current=${PWD}
    # change directory to frontend_repos/repo_name
    cd ${frontend_repos}/${repo_name} 
    docker-compose down
    cd $current

}
# ###
# logs_service
logs_service() {
    # load frontend.ini config file and select service $1
    load_ini_file 'config/frontend.ini' && section_ini $1
    # store current directory in current variable
    current=${PWD}
    # change directory to frontend_repos/repo_name
    cd ${frontend_repos}/${repo_name}
    docker-compose logs "${@:2}"
    # change directory to $current
    cd $current
}

case $1 in
    install)
        install_service "${@:2}";;
    link)
        link_service "${@:2}";;
    up)
        up_service "${@:2}";;
    update)
        update_service "${@:2}";;
    restart)
        restart_service "${@:2}";;
    down)
        down_service "${@:2}";;
    logs)
        logs_service "${@:2}";;
    help)
        print_help;;
    *)
        print_help
esac
