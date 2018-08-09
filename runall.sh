#!/bin/bash
cd ~/source_code/viabtc_exchange_server/matchengine
sudo ./restart.sh

cd ~/source_code/viabtc_exchange_server/accesshttp
sudo ./restart.sh

cd ~/source_code/viabtc_exchange_server/accessws
sudo ./restart.sh

cd ~/source_code/viabtc_exchange_server/alertcenter
sudo ./restart.sh

cd ~/source_code/viabtc_exchange_server/readhistory
sudo ./restart.sh

cd ~/source_code/viabtc_exchange_server/marketprice
sudo ./restart.sh
