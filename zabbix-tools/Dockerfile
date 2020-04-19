FROM python
RUN pip install pyzabbix
RUN mkdir -p /var/local/zabbix-tools
RUN mkdir -p /var/local/zabbix-tools/templates
RUN mkdir -p /var/local/zabbix-tools/hosts

COPY src /var/local/zabbix-tools

WORKDIR /var/local/zabbix-tools
