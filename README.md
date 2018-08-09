# ViaBTC Exchange Server

ViaBTC Exchange Server is a trading backend with high-speed performance, designed for cryptocurrency exchanges. It can support up to 10000 trades every second and real-time user/market data notification through websocket.

## Architecture

![Architecture](https://user-images.githubusercontent.com/1209350/32476113-5ffc622a-c3b0-11e7-9755-924f17bcc167.jpeg)

For this project, it is marked as Server in this picture.

## Code structure

**Required systems**

* MySQL: For saving operation log, user balance history, order history and trade history.

* Redis: A redis sentinel group is for saving market data.

* Kafka: A message system.

**Base library**

* network: An event base and high performance network programming library, easily supporting [1000K TCP connections](http://www.kegel.com/c10k.html). Include TCP/UDP/UNIX SOCKET server and client implementation, a simple timer, state machine, thread pool. 

* utils: Some basic library, including log, config parse, some data structure and http/websocket/rpc server implementation.

**Modules**

* matchengine: This is the most important part for it records user balance and executes user order. It is in memory database, saves operation log in MySQL and redoes the operation log when start. It also writes user history into MySQL, push balance, orders and deals message to kafka.

* marketprice: Reads message(s) from kafka, and generates k line data.

* readhistory: Reads history data from MySQL.

* accesshttp: Supports a simple HTTP interface and hides complexity for upper layer.

* accwssws: A websocket server that supports query and pushes for user and market data. By the way, you need nginx in front to support wss.

* alertcenter: A simple server that writes FATAL level log to redis list so we can send alert emails.

## Compile and Install

**Operating system**

Ubuntu 14.04 or Ubuntu 16.04. Not yet tested on other systems.

**Requirements**

See [requirements](https://github.com/viabtc/viabtc_exchange_server/wiki/requirements). Install the mentioned system or library.

You MUST use the depends/hiredis to install the hiredis library. Or it may not be compatible.

**Compilation**

Compile network and utils first. The rest all are independent.

**Deployment**

One single instance is given for matchengine, marketprice and alertcenter, while readhistory, accesshttp and accwssws can have multiple instances to work with loadbalancing.

Please do not install every instance on the same machine.

Every process runs in deamon and starts with a watchdog process. It will automatically restart within 1s when crashed.

The best practice of deploying the instance is in the following directory structure:

```
matchengine
|---bin
|   |---matchengine.exe
|---log
|   |---matchengine.log
|---conf
|   |---config.json
|---shell
|   |---restart.sh
|   |---check_alive.sh
```

## API

[HTTP Protocol](https://github.com/viabtc/viabtc_exchange_server/wiki/HTTP-Protocol) and [Websocket Protocol](https://github.com/viabtc/viabtc_exchange_server/wiki/WebSocket-Protocol) documents are available in Chinese. Should time permit, we will have it translated into English in the future.</br>
[Python3 API realisation](https://github.com/grumpydevelop/viabtc_exchange_server_tools/blob/master/api/api_exchange.py)


## Websocket authorization

The websocket protocol has an authorization method (`server.auth`) which is used to authorize the websocket connection to subscribe to user specific events (trade and balance events).

To accomodate this method your exchange frontend will need to supply an internal endpoint which takes an authorization token from the HTTP header named `Authorization` and validates that token and returns the user_id.

The internal authorization endpoint is defined by the `auth_url` setting in the config file (`accessws/config.json`).

Example response: `{"code": 0, "message": null, "data": {"user_id": 1}}`

## Donation
1、Use apt-get install to install following packages: libev-dev, libmpdec-dev, libssl-dev, libmysqlclient-dev, libtool, autoconf, gcc, g++, build-essential, mysql-server, mysql-client,liblz4-dev,libhiredis-dev.

2、Install Oracle JDK8
  add-apt-repository ppa:webupd8team/java
  apt-get update
  apt-get install oracle-java8-installer
  apt-get install oracle-java8-set-default

3、Create a folder XXX to place everything required, including this project.

4、Clone project and create new folders "log", "libs".

5、Install Kafka
  Download package from http://archive.apache.org/dist/kafka/0.11.0.0/kafka_2.11-0.11.0.0.tgz, run "tar xfv filename" to unpackage it.

6、create new folders "logs" and "zkData"

7、Enter conf folder, edit server.properties
  broker.id=1
  port=9092 # The following 2 lines maybe not in the file, just add it.
  host.name=localhost
  log.dirs=/home/trader/Documents/tldae/kafka_2.11-0.11.0.0/logs # It's OK to any folder you like

8、edit zookeeper.properties
  dataDir=/home/trader/Documents/tldae/kafka_2.11-0.11.0.0/zkData

9、Start Zookeeper: 
  bin/zookeeper-server-start.sh config/zookeeper.properties & (Use & to run at background)

10、Start Kafka: 
  bin/kafka-server-start.sh config/server.properties

11、Build jansson
 Clone code from https://github.com/akheron/jansson
 autoreconf -i (if configure not found), ./configure, make, make install.

12、Build librdkafka
 Clone code from https://github.com/edenhill/librdkafka
 ./configure, make, make install.

13、Build libcurl
 Get code from http://curl.haxx.se/download/curl-7.45.0.tar.gz, run "tar zxfv filename" to unpackage it.
 Run "./configure --disable-ldap --disable-ldaps" first, or you'll hit lots link errors in future.
 make, make install

14、Redis
 Enter folder "redis.conf"
 Run "sudo redis-server redis.conf.6381" (Same for 6382 and 6383)
 Run "redis -p 6382", run "SLAVEOF 127.0.0.1 6381" (Same for 6383)
 Run "sudo redis-sentinel sentinel.conf.26381" (Same for 6382 and 6383)
 How to verify?
 redis-cli -p 26381 (Same check for 26382 and 26383)
 run "SENTINEL get-master-addr-by-name mymaster", you should see 2 lines: "127.0.0.1" and "6381".

15、MySQL
#Use root to login and create 2 database: trade_history and trade_log
 Create a user "trader" (or any name you like) and grant privileges
 create user trader@localhost identified by "Abcd1234";
 grant all privileges on trade_history.* to trader@localhost identified by 'Abcd1234';
 grant all privileges on trade_log.* to trader@localhost identified by 'Abcd1234';
 flush privileges;
 Enter folder "sql", and execute
 mysql -h localhost -u trader -p trade_history < create_trade_history.sql
 mysql -h localhost -u trader -p trade_log < create_trade_log.sql

16、Build project
 Make sure jansson, librdkafka, curl and the project under the same folder.
 Build "depends/hiredis", "network" and "utils", copy the corresponding libxxx.a files to "libs" folder.
 For "config.json", please modify log.path and db_xxx information accordingly.
 Run "sudo ./xxx.exe config.json" to start the service (accessws need more things, not fixed yet), remember run "marketprice" after    "matchengine".
