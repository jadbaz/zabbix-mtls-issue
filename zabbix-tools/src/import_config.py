# https://github.com/lukecyca/pyzabbix/blob/master/examples/import_templates.py
"""
Import Zabbix XML templates
"""
import argparse
import sys
import os
import glob
from pyzabbix import ZabbixAPI, ZabbixAPIException

strippedArgs = sys.argv[(sys.argv.index('--') +1):] if '--' in sys.argv else sys.argv

parser = argparse.ArgumentParser(description='Import templates')
parser.add_argument(
    '--path',
    action="store",
    dest="path",
    help='Template path',
    required=True,
)
parser.add_argument(
    '--zabbix-url',
    action="store",
    dest="zabbixURL",
    help='Zabbix URL',
    required=True,
)
parser.add_argument(
    '--zabbix-username',
    action="store",
    dest="zabbixUsername",
    help='Zabbix Username',
    required=True,
)
parser.add_argument(
    '--zabbix-password',
    action="store",
    dest="zabbixPassword",
    help='Zabbix Password',
    required=True,
)
parser.add_argument(
    '--start',
    action="store",
    dest="start",
    help='Starting number',
    type=int,
    required=False,
)
parser.add_argument(
    '--end',
    action="store",
    dest="end",
    help='Ending number',
    type=int,
    required=False,
)
(args, unknown) = parser.parse_known_args(strippedArgs)
path=args.path
zabbixURL=args.zabbixURL
zabbixUsername=args.zabbixUsername
zabbixPassword=args.zabbixPassword
start=args.start
end=args.end

start=-1
end=-1

if args.start != None:
    start=args.start

if args.end != None:
    end=args.end

zapi = ZabbixAPI(zabbixURL)

# Login to the Zabbix API
#zapi.session.verify = False
zapi.login(zabbixUsername, zabbixPassword)

rules = {
    'applications': {
        'createMissing': True,
    },
    'discoveryRules': {
        'createMissing': True,
        'updateExisting': True
    },
    'graphs': {
        'createMissing': True,
        'updateExisting': True
    },
    'groups': {
        'createMissing': True
    },
    'hosts': {
        'createMissing': True,
        'updateExisting': True
    },
    'images': {
        'createMissing': True,
        'updateExisting': True
    },
    'items': {
        'createMissing': True,
        'updateExisting': True
    },
    'maps': {
        'createMissing': True,
        'updateExisting': True
    },
    'screens': {
        'createMissing': True,
        'updateExisting': True
    },
    'templateLinkage': {
        'createMissing': True,
    },
    'templates': {
        'createMissing': True,
        'updateExisting': True
    },
    'templateScreens': {
        'createMissing': True,
        'updateExisting': True
    },
    'triggers': {
        'createMissing': True,
        'updateExisting': True
    },
    'valueMaps': {
        'createMissing': True,
        'updateExisting': True
    },
}

if os.path.isdir(path):
    #path = path/*.xml
    files = glob.glob(path+'/*.xml')
    for file in files:
        print(file)
        with open(file, 'r') as f:
            template = f.read()
            try:
                zapi.confimport('xml', template, rules)
            except ZabbixAPIException as e:
                print(e)
        print('')
elif os.path.isfile(path):
    files = glob.glob(path)
    for file in files:
        with open(file, 'r') as f:
            template = f.read()
            try:
                if start >= 0 and end >= 0:
                    for i in range(start, end+1):
                        currTemplate = template.replace("{{N}}", str(i))
                        print("#############", i, "#############")
                        zapi.confimport('xml', currTemplate, rules)
                else:
                    zapi.confimport('xml', template, rules)
            except ZabbixAPIException as e:
                print(e)
else:
    print('I need a xml file')

