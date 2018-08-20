#!/bin/bash
 killall -9 redis-sentinel
 killall -9 redis-server
sudo killall -9 matchengine.exe
sudo killall -9 marketprice.exe
sudo killall -9 accesshttp.exe
sudo killall -9 accessws.exe
sudo killall -9 alertcenter.exe
sudo killall -9 readhistory.exe
rm -f ../log/*
mysql -h localhost -u root -proot -e "drop database trade_history;drop database trade_log;"
mysql -h localhost -u root -proot -e "create database trade_history;create database trade_log;"
mysql -h localhost -u root -proot -e "grant all privileges on trade_history.* to trader@localhost identified by 'Abcd1234';"
mysql -h localhost -u root -proot -e "grant all privileges on trade_log.* to trader@localhost identified by 'Abcd1234';"
mysql -h localhost -u root -proot -e "flush privileges;"
mysql -h localhost -u trader -pAbcd1234 trade_history < create_trade_history.sql
mysql -h localhost -u trader -pAbcd1234 trade_log < create_trade_log.sql
./init_trade_history.sh
cd ~/thirdpraty/redis-4.0.11/
rm -rf dump.rdb
redis-server redis.conf &
redis-sentinel sentinel.conf &
