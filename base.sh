#!/bin/bash
env_file=.env
source config/helper

initial_print(){
    clear
    echo "#################################"
    echo "#                               #"
    echo "###      Install please       ###"
    echo "# viva con agua deployment tool #"
    echo "#                               #"
    echo "#################################"
    echo "--->"
}

create_working_directorys(){
    # define working directory 
    echo "# ask for work_dir path"
    read -e -p "Please add a work directory path: " work_dir_input
    echo "# create work_dir folder"
    work_dir=${work_dir_input%/}
    mkdir -p ${work_dir}
    echo "work_dir=${work_dir}" > $env_file
    
    # create working directory for frontend
    mkdir -p ${work_dir}/frontend/subdomain
    # set .env param subdomain.
    echo frontend_subdomain=${work_dir}/frontend/subdomain >> $env_file
    # create subdomain working directory.
    mkdir -p ${work_dir}/frontend/repos
    # set .env param subdomain.
    echo frontend_repos=${work_dir}/frontend/repos >> $env_file
    #define working directory for api  repos databases routes
    mkdir -p ${work_dir}/api/repos
    echo api_repos=${work_dir}/api/repos >> $env_file
    mkdir -p ${work_dir}/api/databases
    echo api_databases=${work_dir}/api/databases >> $env_file
    mkdir -p ${work_dir}/api/routes
    echo api_routes=${work_dir}/api/routes >> $env_file
}

set_deploy_mode(){
    echo ALLOW_ORIGINS= >> $env_file
    echo "# ask for deploy_mode"
    while true; do
        read -e -i "n" -p "Do you wish to install in live mode [y/N]: " yn
        case $yn in
            [Nn]* ) 
                echo domain=localhost >> $env_file
                echo deploy_mode=develop >> $env_file;
                echo COOKIE_SECURE=false >> $env_file
                echo SAME_SITE=none >> $env_file
                break;;
            [Yy]* ) 
                read -e -p "domain: " domain
                echo domain=${domain} >> $env_file; 
                read -e -p "path: " cert_path
                echo "certs="${certs} >> $env_file
                echo COOKIE_SECURE=false >> $env_file
                echo SAME_SITE=none >> $env_file
                break;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

set_docker_ip(){
    load_ini_file './config/frontend.ini' && section_ini default
    echo frontend_nginx_ip=${docker_ip} >> $env_file
    section_ini api
    echo frontend_api_ip=${docker_ip} >> $env_file
    echo api_subdomain=${route} >> $env_file
    load_ini_file './config/api.ini' && section_ini default
    echo api_nginx_ip=${nginx_ip} >> $env_file
    echo api_nats_ip=${nats_ip} >> $env_file
    echo api_logs_ip=${logs_ip} >> $env_file
}

set_logging_service(){
    while true; do
        read -e -i "y" -p "Do you wish logs via nats [y/N]: " yn
        case $yn in
            [Nn]*)
                echo LOGGER_OUTPUT=IO >> $env_file
                break;;
            [Yy]*)
                echo LOGGER_OUTPUT=nats >> $env_file
                break;;
        esac
    done
}
set_idjango(){
    while true; do
        read -e -i "n" -p "Do you wish idjango export [y/N]: " yn
        case $yn in
            [Nn]*)
                echo IDJANGO_EXPORT=false >> $env_file
                break;;
            [Yy]*)
                #pattern="/IDJANGO_EXPORT=/c\IDJANGO_EXPORT=${idjango_export}"
                #sed -i ${pattern} ../api/$env_file
                echo IDJANGO_EXPORT=true >> $env_file
                read -p "IDJANGO_URL: " idjango_url
                echo IDJANGO_URL=${idjango_url} >> $env_file
                #pattern="/IDJANGO_EXPORT=/c\IDJANGO_EXPORT=${idjango_export}"
                #sed -i ${pattern} ../api/.env
                read -p "IDJANGO_KEY: " idjango_key
                echo IDJANGO_KEY=${idjango_key} >> $env_file
                break;;
        esac
    done
}

setup_env_frontend(){
    d_env=docker/frontend/.env
    source ${env_file}
    echo subdomain=${frontend_subdomain} > $d_env
    echo docker_ip=${frontend_nginx_ip} >> $d_env
    if ! [ $deploy_mode == "develop" ]; then
        echo "# TODO: COOKIE_SECURE and SAME_SITE for live mode"
        echo CERT_PATH=${certs} >> $env_file
    fi
}

setup_env_backend(){
    d_env=docker/api/.env
    source ${env_file}
    echo nginx_ip=${api_nginx_ip} > $d_env
    echo domain_ip=${frontend_api_ip} >> $d_env
    echo logs_ip=${api_logs_ip} >> $d_env
    echo nats_ip=${api_nats_ip} >> $d_env
    echo NATS_HOST=${api_nats_ip} >> $env_file
    echo databases=${api_databases} >> $d_env
    echo routes=${api_routes} >> $d_env
    if ! [ $deploy_mode == "develop" ]; then
        echo "# TODO: COOKIE_SECURE and SAME_SITE for live mode"
        echo CERT_PATH=${certs} >> $env_file
    fi
}

start_base(){
    source ${env_file}
    cd docker/api
    docker-compose up -d
    cd ../frontend
    if ! [ $deploy_mode == "develop" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.live.yml up -d
    else
        docker-compose up -d
    fi
}

down_base(){
    source ${env_file}
    cd docker/api
    docker-compose down -d
    cd ../frontend
    if ! [ $deploy_mode == "develop" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.live.yml down
    else
        docker-compose down
    fi

}
setup_base(){
initial_print
create_working_directorys
set_deploy_mode
set_docker_ip
set_logging_service
set_idjango
setup_env_frontend
setup_env_backend
./frontend.sh link api
start_base

}
case $1 in 
    install)
        setup_base;;
    down)
        down_base;;
    *)
esac

##pattern="/work_dir=/c\work_dir=${work_dir%/}"
##sed -i ${pattern} config/services.ini
#
#source $env_file
#
#echo "# install frontend"
## load config.ini and get default section.
#load_ini && section_ini default
## create subdomain working directory.
#mkdir -p ${work_dir}/frontend/subdomain
## set .env param subdomain.
#echo subdomain=${work_dir}/frontend/subdomain >> $env_file
## ask for a path to an if the deploy mode is live.
#echo "#Path to Cert: only used in live mode"
#if [ ${deploy_mode} == "live" ]; then 
#    read -e -p "path: " cert_path
#    echo "certs="${certs} >> $env_file
#fi
## set .env param docker_ip.
#
#
## install api
#mkdir -p ${work_dir}/api/repos
#echo repos=${work_dir}/api/repos >> $env_file
#mkdir -p ${work_dir}/api/databases
#echo databases=${work_dir}/api/databases >> $env_file
#mkdir -p ${work_dir}/api/routes
#echo routes=${work_dir}/api/routes >> $env_file
#cp default.conf ${work_dir}/api/routes/default.conf
#echo frontend_api_ip=${domain_ip} >> $env_file
#echo api_nginx_ip=${nginx_ip} >> $env_file
#echo api_nats_ip=${nats_ip} >> $env_file
#echo NATS_HOST=${nats_ip} >> $env_file
#echo logs_ip=${logs_ip} >> $env_file
#echo ALLOW_ORIGINS= >> $env_file
#echo DB_NAME=db >> $env_file
#if [ $deploy_mode == "develop" ]; then
#    echo COOKIE_SECURE=false >> $env_file
#    echo SAME_SITE=none >> $env_file
#else
#    echo "# TODO: COOKIE_SECURE and SAME_SITE for live mode"
#    echo COOKIE_SECURE=false >> $env_file
#    echo SAME_SITE=none >> $env_file
#fi
#while true; do
#    read -e -i "y" -p "Do you wish logs via nats [y/N]: " yn
#    case $yn in
#        [Nn]*)
#            echo LOGGER_OUTPUT=IO >> $env_file
#            break;;
#        [Yy]*)
#            echo LOGGER_OUTPUT=nats >> $env_file
#            break;;
#    esac
#done
#while true; do
#    read -e -i "n" -p "Do you wish idjango export [y/N]: " yn
#    case $yn in
#        [Nn]*)
#            echo IDJANGO_EXPORT=false >> $env_file
#            break;;
#        [Yy]*)
#            #pattern="/IDJANGO_EXPORT=/c\IDJANGO_EXPORT=${idjango_export}"
#            #sed -i ${pattern} ../api/$env_file
#            echo IDJANGO_EXPORT=true >> $env_file
#            read -p "IDJANGO_URL: " idjango_url
#            echo IDJANGO_URL=${idjango_url} >> $env_file
#            #pattern="/IDJANGO_EXPORT=/c\IDJANGO_EXPORT=${idjango_export}"
#            #sed -i ${pattern} ../api/.env
#            read -p "IDJANGO_KEY: " idjango_key
#            echo IDJANGO_KEY=${idjango_key} >> $env_file
#            break;;
#    esac
#done
#up_service
#
##cd ../domain && ./please install && cd ../install
##echo "# install api"
#cd ../api && ./please install && cd ../install
#echo "# link domain and api"
#cd ../domain && ./please link api && cd ../install
#echo please has successfully installed

