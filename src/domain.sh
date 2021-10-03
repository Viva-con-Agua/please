
#!/bin/bash
docker=./docker/domain
source ./config/helper
source .env
source src/default.sh

current=${PWD}


# $1=deploy_mode $2=work_dir $3=domain_net_ip
install_service() {
    load_config_service domain
    cd $docker
    echo deploy_mode=${deploy_mode} > .env
    mkdir -p ${workdir}/subdomain
    echo subdomain_path=${work_dir}/subdomain >> .env
    echo "#Path to Cert: only used in live mode"
    if [ ${deploy_mode} == "live" ]; then 
        read -e -p "path: " cert_path
        echo "cert_path="${cert_path} >> .env
    fi
    echo domain_net_ip=${domain_net_ip} >> .env
    docker-compose up -d
}

# $1 == service_name, $2 == domain_net_ip, $3 == route
link_service() {
    load_config_service $1
    cd $docker
    source .env
    current=${PWD}
    case $deploy_mode in
        live) 
            cp ./default.conf ${subdomain_path}/${2}.conf && cd ${subdomain_path};
            sed -i s/{cretificate}/${cert_path}/g ${2}.conf;;
        *) cp ./default.dev.conf ${subdomain_path}/${2}.conf && cd ${subdomain_path}
    esac
    sed -i s/{subdomain}/${2}/g ${2}.conf
    sed -i s/{proxy_pass}/${domain_net_ip}/g ${2}.conf
    cd $current
    echo $1 is successfully link to domain ${2} with IP: ${domain_net_ip}.
    restart_service
}




case $1 in
    install)
        install_service "${@:2}";;

    link)
        link_service "${@:2}";;

    *)
        echo"TODO"
esac
