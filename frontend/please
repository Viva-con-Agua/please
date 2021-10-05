#!/bin/bash

source .env
source config/helper
print_help(){
    echo help
}

install_service(){
    load_config_frontend $1
    cd $frontend_dir
    if ! [ -d $repo_name ]; then
        git clone $repo
    fi
    cd $repo_name
    if $deploy_mode = "develop"; then
        ./please env $domain_net_ip http://${api_route}
    else
        ./please env $domain_net_ip https://${api_route}
    fi
}

case $1 in
    install)
        install_service $2;;
    *) print_help
esac
