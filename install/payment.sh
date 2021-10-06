echo "# Install donation backend"
if ! grep -q "\[donation-backend\]" ../api/config.ini; then
    cat ../config/api.donation-backend.ini >> ../api/config.ini
    vim ../api/config.ini
fi
cd ../api; 
./please add donation-backend;

cd  ../install
