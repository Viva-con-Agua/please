source .env
source config/helper


set_allow_origin(){
    echo $1
    ao="${ALLOW_ORIGINS}, ${1}"
    IFS=', ' read -r -a array <<< $ao
    temp_a=$(echo ${array[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ')
    temp=""
    for v in ${temp_a[@]} 
    do
        temp="${temp}${v},"
    done
    allow_origin="${temp%,}"
    edit_config "ALLOW_ORIGINS" $allow_origin .env
    edit_config "ALLOW_ORIGINS" $allow_origin docker/api/.env
    ./base.sh restart api
    services=$(ls ${api_repos})
    for v in ${services[@]}
    do
        edit_config "ALLOW_ORIGINS" $allow_origin ${api_repos}/${v}/.env
        ./api.sh restart $v
    done
}

case $1 in
    allow_origin) set_allow_origin $2;;
    *) echo "TODO"
esac
