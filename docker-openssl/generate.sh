if [ "$1" == "--inter" ]
then
    echo "*** USING INTERMEDIATE CA ***"
    use_inter=true
else
    echo "*** USING ONLY ROOT CA ***"
fi


CMD="docker run --rm -v `pwd`/workdir:/workdir docker-openssl"

rm -rf workdir
mkdir -p workdir

echo -n > workdir/rootca_certindex
echo 1000 > workdir/rootca_certserial
echo 1000 > workdir/rootca_crlnumber

echo -n > workdir/interca_certindex
echo 1000 > workdir/interca_certserial
echo 1000 > workdir/interca_crlnumber

cp config/* workdir/

#################################################################

C="US"
ST="Some_State"
L="Some_Locality"
O="Some_Organization"
OU="Some_Organizational_Unit"

ROOT_CN=root_ca
ROOT_SUBJ="/C=$C/ST=$ST/L=$L/O=$O/CN=$ROOT_CN"

INTER_CN=inter_ca
INTER_SUBJ="/C=$C/ST=$ST/L=$L/O=$O/CN=$INTER_CN"

SERVER_CN=zabbix
SERVER_SUBJ="/C=$C/ST=$ST/L=$L/O=$O/CN=$SERVER_CN"

HOST_CN=dummy
HOST_SUBJ="/C=$C/ST=$ST/L=$L/O=$O/CN=$HOST_CN"

#################################################################

echo "*** Generating root ca key ***"
$CMD genrsa -out rootca.key 8192 

echo "*** Creating self-signed root CA certificate ***"
$CMD req -sha256 -new -x509 -days 3650 -key rootca.key -out rootca.crt -subj "$ROOT_SUBJ"

if [ "$use_inter" = true ]
then
    echo "*** Generating intermediate ca key ***"
    $CMD genrsa -out interca.key 8192

    echo "*** Creating intermediate CA CSR ***"
    $CMD req -sha256 -new -key interca.key -out interca.csr -subj "$INTER_SUBJ"

    echo "*** Signing intermediate csr with root ca key ***"
    $CMD ca -batch -notext -in interca.csr -out interca.crt -config rootca.cnf
fi

echo "*** Generating server key ***"
$CMD genrsa -out server.key 4096

echo "*** Creating server csr ***"
$CMD req -new -sha256 -key server.key -out server.csr -subj "$SERVER_SUBJ"

if [ "$use_inter" = true ]
then
    echo "*** Signing server csr with intermediate ca key ***"
    $CMD ca -batch -notext -in server.csr -out server.crt -config interca.cnf
else    
    echo "*** Signing server csr with root ca key ***"
    $CMD ca -batch -notext -in server.csr -out server.crt -config rootca.cnf
fi


echo "*** Generating host key ***"
$CMD genrsa -out host.key 4096

echo "*** Creating host csr ***"
$CMD req -new -sha256 -key host.key -out host.csr -subj "$HOST_SUBJ"

if [ "$use_inter" = true ]
then
    echo "*** Signing host csr with intermediate ca key ***"
    $CMD ca -batch -notext -in host.csr -out host.crt -config interca.cnf
else    
    echo "*** Signing host csr with root ca key ***"
    $CMD ca -batch -notext -in host.csr -out host.crt -config rootca.cnf
fi
