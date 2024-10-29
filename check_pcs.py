#!/usr/bin/env python
import os
import re
import subprocess

MYCOMPUTERS = os.environ['MYCOMPUTERS']
KEY = os.environ['MAIN_KEY']
DIFF_CMD = """rsync --progress -a -n ~/brain {}:/home/mahmooz/ -e 'ssh -i ~/brain/keys/hetzner1' --exclude '.git'"""

def get_local_ip():
    out = subprocess.check_output(['ip', 'addr'])
    matches = re.search("inet (.*)/24", out.decode()).groups()
    return [match for match in matches if match != "127.0.0.1"][0]

local_ip = get_local_ip()
print(f'local ip {local_ip}')

def run_remote_command(ip, cmd):
    out = subprocess.check_output(['ssh', '-i', KEY, ip, cmd]).decode()
    out_no_newline = out[:-1]
    return out_no_newline

def get_ip_using_mac(mac):
    out = subprocess.check_output(['ip', 'neigh']).decode()
    for line in out.splitlines():
        tokens = line.split(' ')
        if '.' in tokens[0]: # ipv4
            if tokens[4] == mac:
                return tokens[0]

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
    if machine['ip']:
        out = subprocess.check_output(DIFF_CMD.format(machine['ip']), shell=True).decode()
        print(f'{machine["name"]}: {out}')