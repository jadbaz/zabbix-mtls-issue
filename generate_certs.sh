wd=`pwd`

cd docker-openssl
sh run.sh "$@"

cd $wd

rm -rf enc
mkdir -p enc


use_inter=false

if [ "$1" == "--inter" ]
then
    use_inter=true
fi


# ca file is root certificate
if [ "$use_inter" = true ]
then
    cat docker-openssl/workdir/rootca.crt docker-openssl/workdir/interca.crt > enc/zabbix_ca_file
else
    cat docker-openssl/workdir/rootca.crt > enc/zabbix_ca_file
fi


# server cert
cp docker-openssl/workdir/server.key enc/zabbix_server.key
# server chain
if [ "$use_inter" = true ]
then
    cat docker-openssl/workdir/server.crt docker-openssl/workdir/interca.crt docker-openssl/workdir/rootca.crt > enc/zabbix_server.crt
else
    cat docker-openssl/workdir/server.crt docker-openssl/workdir/rootca.crt > enc/zabbix_server.crt
fi


# agent cert
cp docker-openssl/workdir/host.key enc/zabbix_agentd.key
# copy chain
if [ "$use_inter" = true ]
then
    cat docker-openssl/workdir/host.crt docker-openssl/workdir/interca.crt docker-openssl/workdir/rootca.crt > enc/zabbix_agentd.crt
else
    cat docker-openssl/workdir/host.crt docker-openssl/workdir/rootca.crt > enc/zabbix_agentd.crt
fi

chmod 744 enc/*
