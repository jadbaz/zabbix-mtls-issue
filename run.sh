echo "Generating certs"
sh ./generate_certs.sh "$@"

echo "Cleaning up"
docker-compose down --remove-orphans

echo "Bringing up environment"
docker-compose up -d -V --remove-orphans --force-recreate

echo -n Waiting for Zabbix to come up

while ! (echo > /dev/tcp/127.0.0.1/10051) >/dev/null 2>&1
do
  echo -n .
  sleep 1
done

echo

echo "Sleeping 30 seconds to allow Zabbix to actually start"
for i in `seq 1 30`; do echo -n .; sleep 1; done
echo

echo "Importing static hosts"
sh import_hosts.sh

echo "Forcing agent to restart to reload configuration"
docker-compose restart zabbix-agent

docker-compose logs -t -f zabbix-agent zabbix-server
