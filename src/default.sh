up_service() {
    cd $docker
    docker-compose up -d
}

restart_service() {
    cd $docker
    docker-compose restart
}

logs_service(){
    cd $docker
    docker-compose logs "${@}"
}

case $1 in
    up)
        up_service; exit;;
    restart)
        restart_service; exit;;
    logs)
        logs_service "${@:2}"; exit;;
esac
