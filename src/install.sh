#!/bin/bash
source ${PWD}/config/helper
source .env

install_print_help(){
    echo currently supported services:
    echo    domain, api, nats, logs
}

install_please() {
    clear
    echo "#################################"
    echo "#                               #"
    echo "###      Install please       ###"
    echo "# viva con agua deployment tool #"
    echo "#                               #"
    echo "#################################"
    echo ""
    echo # install please-completion for zsh
    if ! grep -q please-completion.bash ~/.zshrc; then
        cp ~/.zshrc ~/.zshrc.bak-please
        echo source ${PWD}/src/complete/please-completion.bash >> ~/.zshrc
    fi
    echo # ask for work_dir path
    read -e -p "Please add a work directory path: " work_dir
    echo # create work_dir folder
    mkdir -p ${work_dir%/}/volumes ${work_dir%/}/repos ${work_dir%/}/databases
    echo "work_dir=${work_dir%/}" >> .env
    echo "volumes_dir=${work_dir%/}/volumes" >> .env
    echo "repos_dir="${work_dir%/}/repos >> .env   
   
    echo # ask for deploy_mode
    while true; do
        read -e -i "n" -p "Do you wish to install in live mode [y/N]: " yn
        case $yn in
            [Nn]* ) echo deploy_mode=develop > .env; break;;
            [Yy]* ) echo deploy_mode=live > .env; break;;
            * ) echo "Please answer y or n.";;
        esac
    done
    #pattern="/work_dir=/c\work_dir=${work_dir%/}"
    #sed -i ${pattern} config/services.ini
    echo please has successfully installed
}

# $1=repo_dir, $2=repo_name, $3=repo
go_and_get_repo() {
   cd $repos_dir &&
    if ! [ -d $repo_name ] ; then
        git clone $repo
    fi
    cd $repo_name
}


install_domain() {
    load_config_service domain
    go_and_get_repo $repos_dir $repo_name $repo
    ./please install $deploy_mode $work_dir $domain_net_ip
}

install_api() {
    load_config_service api
    go_and_get_repo $repos_dir $repo_name $repo
    ./please install $deploy_mode $work_dir $domain_net_ip $api_net_ip
}

install_nats() {
    load_config_service nats
    go_and_get_repo $repos_dir $repo_name $repo
    ./please install $deploy_mode $nats_net_ip
}

install_logs() {
    load_config_service logs
    go_and_get_repo $repos_dir $repo_name $repo
    ./please install $deploy_mode $nats_net_ip 
}




if [ -z ${1} ]; then
    install_handler
else
    case $1 in 
        domain)
            install_domain;;
        api)
            install_api;;
        nats)
            install_nats;;
        logs)
            install_logs;;
        *) install_print_help
    esac
fi
