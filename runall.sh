#!/bin/bash
cd ~/source_code/Couplesystem/matchengine
sudo ./restart.sh

cd ~/source_code/Couplesystem/accesshttp
sudo ./restart.sh

cd ~/source_code/Couplesystem/accessws
sudo ./restart.sh

cd ~/source_code/Couplesystem/alertcenter
sudo ./restart.sh

cd ~/source_code/Couplesystem/readhistory
sudo ./restart.sh

cd ~/source_code/Couplesystem/marketprice
sudo ./restart.sh
