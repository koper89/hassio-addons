#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

SERVER_IP=$(jq --raw-output '.server_ip' $CONFIG_PATH)
AUTH_TOKEN=$(jq --raw-output '.auth_token // empty' $CONFIG_PATH)
SERVER_PORT=$(jq --raw-output '.server_port' $CONFIG_PATH)
LOCAL_PORT=$(jq --raw-output '.local_port' $CONFIG_PATH)
CUSTOM_DOMAINS=$(jq --raw-output '.custom_domains' $CONFIG_PATH)
PROXY_NAME=$(jq --raw-output '.proxy_name // empty' $CONFIG_PATH)

FRP_PATH=/var/frp
FRPC_CONF=$FRP_PATH/conf/frpc.ini

if [ -f $FRPC_CONF ]; then
  rm $FRPC_CONF
fi

if [ ! $PROXY_NAME ]; then
  PROXY_NAME=web
  echo Using default proxy name $PROXY_NAME
fi

echo "[common]" >> $FRPC_CONF
echo "server_addr = $SERVER_IP" >> $FRPC_CONF
echo "server_port = $SERVER_PORT" >> $FRPC_CONF
if [ $AUTH_TOKEN ]; then
  echo "token = $AUTH_TOKEN" >> $FRPC_CONF
fi
echo "[$PROXY_NAME]" >> $FRPC_CONF
echo "type = http" >> $FRPC_CONF
echo "local_ip = 127.0.0.1" >> $FRPC_CONF
echo "local_port = $LOCAL_PORT" >> $FRPC_CONF
echo "custom_domains = $CUSTOM_DOMAINS" >> $FRPC_CONF


echo Start frp as client

exec $FRP_PATH/frpc -c $FRPC_CONF < /dev/null
