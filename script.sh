#!/bin/bash

source .env

if [ -v ip ] && ! [ -z "$ip" ];
then
echo "ip: $ip"
else
echo "ip in .env wasn't found"
exit 0
fi

if [ -v serverpublickey ] && ! [ -z "$serverpublickey" ];
then
echo "Server pub key: $serverpublickey"
else
echo "Server pub key in .env wasn't found"
exit 0
fi

wg genkey | tee keys/client/private/$1_privatekey |
wg pubkey | tee keys/client/public/$1_publickey
# wg genkey | tee $1_privatekey |
# wg pubkey | tee $1_publickey
# echo "private: " $(cat keys/client/private/$1_privatekey)
# echo "public: " $(cat keys/client/public/$1_publickey)

privatekey=$(cat "keys/client/private/$1_privatekey")
publickey=$(cat "keys/client/public/$1_publickey")


echo '[Interface]
Address = 10.0.0.'$2'/32
DNS = 8.8.8.8 
PrivateKey = '$privatekey'

[Peer]
PublicKey = '$serverpublickey'
Endpoint = '$ip'
AllowedIPs = 0.0.0.0/0
PersistentkeepAlive = 20' >> "client/$1.conf"

echo '
[Peer]
#'$1'
PublicKey = '$publickey'
AllowedIPs = 10.0.0.'$2'/32
' >> wg0.conf

qrencode -t ansiutf8 < "client/$1.conf"