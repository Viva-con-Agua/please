
set_allow_origin(){
    ao="${ALLOW_ORIGINS}, ${1}"
    IFS=', ' read -r -a array <<< $ao
    temp_a=$(echo ${array[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ')
    temp=""
    for v in ${temp_a[@]} 
    do
        temp="${temp}${v},"
    done
    allow_origin="${temp%,}"
    pattern=/ALLOW_ORIGINS=/cALLOW_ORIGINS=${allow_origin}
    sed -i ${pattern} .env
    services=$(ls ${api_repos})
    echo $services
}

case $1 in
    allow_origin) set_allow_origin;;
    *) echo "TODO"
esac
