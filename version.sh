if ! printenv |  grep -q please_current_update ; then
    echo $PLEASE_CURRENT_UPDATED
    git remote update > trash
    UPSTREAM='@{u}'
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ $LOCAL = $REMOTE ]; then
        echo "Up-to-date"
    elif [ $LOCAL = $BASE ]; then
        echo "Need to pull"
        while true; do
            read -e -i "Y" -p "Do you want to update please? [Y/n]: " yn
            case $yn in
                [Nn]* ) break;;
                [Yy]* ) git pull; break;;
                * ) echo "Please answer y or n.";;
            esac
        done
    fi
fi
export PLEASE_CURRENT_UPDATED='true'
    echo "Need to push"
else
    echo "Diverged"
fi
