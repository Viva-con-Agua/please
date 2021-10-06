clear
echo "#################################"
echo "#                               #"
echo "###      Install please       ###"
echo "# viva con agua deployment tool #"
echo "#                               #"
echo "#################################"
echo "--->"
echo "# ask for work_dir path"
read -e -p "Please add a work directory path: " work_dir
echo "# create work_dir folder"
mkdir -p ${work_dir}
echo "work_dir=${work_dir%/}" > ../.env
echo "work_dir=${work_dir%/}" > ../api/.env
echo "work_dir=${work_dir%/}" > ../domain/.env
echo "# ask for deploy_mode"
while true; do
    read -e -i "n" -p "Do you wish to install in live mode [y/N]: " yn
    case $yn in
        [Nn]* ) 
            echo deploy_mode=develop >> ../.env;
            echo deploy_mode=develop >> ../domain/.env;
            echo deploy_mode=develop >> ../api/.env; 
            break;;
        [Yy]* ) 
            echo deploy_mode=live >> ../.env; 
            echo deploy_mode=live >> ../domain/.env;
            echo deploy_mode=live >> ../api/.env;
            break;;
        * ) echo "Please answer y or n.";;
    esac
done
#pattern="/work_dir=/c\work_dir=${work_dir%/}"
#sed -i ${pattern} config/services.ini
echo "# install domain"
cd ../domain && ./please install && cd ../install
echo "# install api"
cd ../api && ./please install && cd ../install
echo "# link domain and api"
cd ../domain && ./please link api && cd ../install
echo please has successfully installed

