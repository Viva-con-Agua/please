#!/bin/bash

source ${PWD}/config/helper
source .env

link_service_help() {
    print_help_please(){
    echo "Commands: "
    echo "  api <service>           # link <service> with api."
    echo "  domain <service>        # link <service> with domain." 
    echo "  help           # print this page."
}

}

link_service_api(){
    load_config_service $1
    ip=${api_net_ip}
    rt=${route}
    load_config_service api
    cd $repos_dir/$repo_name &&
    ./please link $1 $ip $rt
}

link_service_domain(){
    load_config_service $1
    ip=${domain_net_ip}
    rt=${route}
    load_config_service domain
    cd $repos_dir/$repo_name &&
    ./please link $1 $ip $rt
}



case $1 in
    api)
        link_service_api $2;;
    domain)
        link_service_domain $2;;
    help)
        link_service_help;;
    *) link_service_help
esac
