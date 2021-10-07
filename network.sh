#!/bin/bash



source config/helper


print_help(){
    echo "Commands: create, delete, info "
    echo "  create              create a network"
    echo "  delete              delete a network"
    echo "  info                show network infos"

}


create_network_function(){
    load_ini_file 'config/network.ini' && section_ini $1
    docker network create -d bridge --subnet ${subnet} ${name} || true
}

create_network(){
    load_ini_file 'config/network.ini'
    if [ -z ${1} ]; then
        for v in ${sections[*]}
        do
            create_network_function $v
        done
    else
        create_network_function $1
    fi

}

delete_network_function(){
    load_ini_file 'config/network.ini' && section_ini $1
    docker network rm ${name}
}

delete_network(){
    load_ini_file 'config/network.ini'
    if [ -z ${1} ]; then
        for v in ${sections[*]}
        do
            delete_network_function $v
        done
    else
        delete_network_function $1
    fi


}


info_print(){
    load_ini_file 'config/network.ini' && section_ini $1
    echo "Name: ";
    docker network inspect ${name} --format "{{.Name}}"; 
    echo "Subnet: ";
    docker network inspect ${name} --format "{{range  .IPAM.Config}}{{println .Subnet}}{{end}}";
    echo "Container Names and IPv4Addresses: ";
    docker network inspect ${name} --format "{{range  .Containers}}{{println .Name .IPv4Address}}{{end}}"; 
}

info_network(){
    load_ini_file 'config/network.ini'
    if [ -z ${1+x} ]; then
        for v in ${sections[*]}
        do
            info_print $v
        done
    else
        info_print $1
    fi
}

case $1 in
    create) create_network $2;;
    delete) delete_network $2;;
    info) info_network $2;;
    help) print_help ;;
    *) print_help
esac


