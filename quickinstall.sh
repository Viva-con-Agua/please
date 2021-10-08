donation_install(){
    ./please api install donation-backend && ./please frontend install donation-form
}

case $1 in
    donation) donation_install;;
    *) echo "TODO"
esac
