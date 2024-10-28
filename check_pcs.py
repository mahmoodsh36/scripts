#!/usr/bin/env python
import os
import re
import subprocess

MYCOMPUTERS = os.environ['MYCOMPUTERS']
KEY = os.environ['MAIN_KEY']

def get_local_ip():
    out = subprocess.check_output(['ip', 'addr'])
    matches = re.search("inet (.*)/24", out.decode()).groups()
    return [match for match in matches if match != "127.0.0.1"][0]

local_ip = get_local_ip()
print(f'local ip {local_ip}')

def run_remote_command(ip, cmd):
    out = subprocess.check_output(['ssh', '-i', KEY, ip, cmd])
    return out.decode()

def get_ip_using_mac(mac):
    out = subprocess.check_output(['ip', 'neigh']).decode()
    for line in out.splitlines():
        tokens = line.split(' ')
        if tokens[0].contains('.'): # ipv4
            if tokens[4] == mac:
                return tokens[4]

machines = []
for line in MYCOMPUTERS.split('::'):
    tokens = line.split(',')
    mac, name = tokens[0], tokens[1]
    is_main_storage = tokens[2] if tokens[2:] else None
    machines.append({
        'mac': mac,
        'name': name,
        'is_main_storage': is_main_storage,
        'ip': get_ip_using_mac(mac)
    })

for machine in machines:
    print(machine)