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
    mkdir -p ${work_dir%/}/volumes ${work_dir%/}/repos ${work_dir%/}/databases ${work_dir%/}/frontend 
    echo "work_dir=${work_dir%/}" > .env
    echo "volumes_dir=${work_dir%/}/volumes" >> .env
    echo "repos_dir="${work_dir%/}/repos >> .env
    echo "frontend_dir="${work_dir%/}/frontend >> .env
   
    echo # ask for deploy_mode
    while true; do
        read -e -i "n" -p "Do you wish to install in live mode [y/N]: " yn
        case $yn in
            [Nn]* ) echo deploy_mode=develop >> .env; break;;
            [Yy]* ) echo deploy_mode=live >> .env; break;;
            * ) echo "Please answer y or n.";;
        esac
    done
    #pattern="/work_dir=/c\work_dir=${work_dir%/}"
    #sed -i ${pattern} config/services.ini
    echo please has successfully installed
}

install_please

