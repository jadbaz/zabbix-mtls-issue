# ZABBIX TLS "unknown CA" issue reproducer for [ZBX-17604](https://support.zabbix.com/browse/ZBX-17604)
## Description
The aim of this repository is to aid in debugging a Zabbix TLS issue where the server rejects client certificates with "unknown CA" when connections are made from agent-active agents signed by intermediate CAs.

This issue seems to happen when using an intermediate CA. The issue does not happen when using a root CA only.

### Error message
#### Agent
```active check configuration update from [zabbix-server:10051] started to fail (TCP successful, cannot establish TLS to [[zabbix-server]:10051]: invalid CA certificate: SSL_connect() set result code to SSL_ERROR_SSL: file ssl/statem/statem_clnt.c line 1913: error:1416F086:SSL routines:tls_process_server_certificate:certificate verify failed: TLS write fatal alert "unknown CA")```
#### Server
```failed to accept an incoming connection: from <IP>: TLS handshake set result code to 1: file ssl/record/rec_layer_s3.c line 1543: error:14094418:SSL routines:ssl3_read_bytes:tlsv1 alert unknown ca: SSL alert number 48: TLS read fatal alert "unknown CA"```

## Reproducer description
This project is an [MCVE](https://stackoverflow.com/help/minimal-reproducible-example) that can be run in one step.

There are 2 modes this can be run in: root and intermediate CA.

When ran with no argument, the scrit will create a root CA only which will sign both agent and server certificates.

When ran with --inter argument, the script will create a root CA and an intermediate CA that will sign both the server and agent certificates.

What the script does (in both modes) is the following:
- Create server and agent certificates and place them in `enc` directory
- Bring up the environment with both server and agent-active connected to that server
- Wait for the server to start up
- Create the agent-active host on the server with encryption enabled for "connections from host"
- Restart the agent so it quickly takes its configuration
- Tail agent and server logs

In the case of the root CA, the logs should not show any error. In the case of an intermediate CA, the logs will show the error message above.

## Try it yourself
### Prerequisites
- [Docker](https://www.docker.com/) (and make sure the daemon is started)
- [Docker-compose](https://docs.docker.com/compose/install/)
- [git](https://git-scm.com/downloads) (to clone this repo)

### Download
- `git clone https://github.com/jadbaz/zabbix-tls-unknown-ca-issue-reproducer`
- `cd zabbix-tls-unknown-ca-issue-reproducer`

### Run with root CA
- Run the following command: `sh run.sh`
- Make yourself a cuppa and come back in a few

### Run with intermediate CA
- Run the following command `sh run.sh --inter`
- (This will clear previous runs so no need to bring down the environment or anything)


