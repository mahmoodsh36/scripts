#!/usr/bin/env python
import os
import re
import subprocess
import sys
import paramiko
import time

job = sys.argv[1] if sys.argv[1:] else None

MYCOMPUTERS = os.environ['MYCOMPUTERS']
KEY = os.environ['MAIN_KEY']
MAIN_SERVER_IP = os.environ['MAIN_SERVER_IP']
DIFF_CMD = """rsync --progress -a -n ~/brain {}:/home/mahmooz/ -e 'ssh -i ~/brain/keys/hetzner1' --exclude '.git'"""
SSH_KEY = os.environ['MAIN_KEY']

# relevant on termux perhaps (since the `ip` command isnt available)
exclude_this_computer = True
check_local_machines = True

def get_local_ip():
    out = subprocess.check_output(['ip', 'addr'])
    matches = re.findall("inet (.*)/", out.decode())
    return [match for match in matches if match != "127.0.0.1"][0]

def get_local_mac():
    rx = re.compile(r"link/ether (.*) brd",re.MULTILINE)
    out = subprocess.check_output(['ip', 'addr']).decode()
    matches = rx.findall(out)
    return matches[0]

local_ip = get_local_ip()
# print(f'local ip {local_ip}')

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

# returns whether a ping succeeded
def try_ping(hostname):
    hostname = addr_remove_port(hostname)
    out = subprocess.run(['ping', '-c', '1', hostname], stdout = subprocess.DEVNULL)
    if out.returncode == 0:
        return True
    return False

def addr_remove_port(myaddr):
    return myaddr.split(':')[0] # get rid of port

def execute_remote_ssh_cmd(addr, port, username, key, cmd):
    try:
        con = paramiko.SSHClient()
        con.load_system_host_keys()
        con.connect(addr, username=username, port=22, key_filename=key)
        stdin, stdout, stderr = con.exec_command(cmd)
        timeout = 3
        endtime = time.time() + timeout
        while not stdout.channel.eof_received:
            time.sleep(1)
            if time.time() > endtime:
                stdout.channel.close()
                break
        out = stdout.read()
        con.close()
        return out.decode()
    except Exception as e:
        print(e)
        return None

def parse_hostname(hostname):
    port = int(hostname.split(':')[1]) if ':' in hostname else 22
    hostname = hostname.split(':')[0]
    return hostname, port

def try_ssh(hostname):
    hostname, port = parse_hostname(hostname)
    return execute_remote_ssh_cmd(hostname, port, 'mahmooz', SSH_KEY, 'ls')

machines = []
for line in MYCOMPUTERS.split('::'):
    tokens = line.split(',')
    possible_addresses = tokens[0].split('|')
    mac = None
    ip = None
    for candidate in possible_addresses:
        if '.' in candidate:
            if try_ssh(candidate):
                ip = candidate
                break
        else:
            ip = get_ip_using_mac(candidate)
            if ip:
                mac = candidate
                break
    name = tokens[1]
    is_main_storage = tokens[2] if tokens[2:] else None
    machines.append({
        'mac': mac,
        'name': name,
        'is_main_storage': is_main_storage,
        'ip': ip,
        'candidate_addresses': possible_addresses
    })

for machine in machines:
    if job == 'diff':
        if machine['ip']:
            if get_local_mac() not in machine['candidate_addresses']:
                out = subprocess.check_output(DIFF_CMD.format(machine['ip']), shell=True).decode()
                print(f'{machine["name"]}: {out}')
    if job == 'print_diff_cmd':
        if machine['ip']:
            if get_local_mac() not in machine['candidate_addresses']:
                print(DIFF_CMD.format(machine['ip']))
    if job == 'print_machines_json':
        if machine['ip']:
            if get_local_mac() not in machine['candidate_addresses']:
                print(f'{machine["name"]}: {out}')
    if job == 'print_machines':
        if machine['ip']:
            if get_local_mac() not in machine['candidate_addresses']:
                print(f'{machine["name"]},{machine["ip"]}')
    if job == 'print_ips':
        if machine['ip']:
            if get_local_mac() not in machine['candidate_addresses']:
                print(machine['ip'])
    if job == 'run':
        if machine['ip']:
            if get_local_mac() not in machine['candidate_addresses']:
                print(f'running on {machine["name"]},{machine["ip"]}')
                sys.stdout.write(execute_remote_ssh_cmd(machine['ip'], 22, 'mahmooz', SSH_KEY, sys.argv[2]))

    # makes sense if only one result exists
    if job == 'ssh':
        done = False
        if machine['ip'] and not done:
            if get_local_mac() not in machine['candidate_addresses']:
                done = True
                hostname, port = parse_hostname(machine['ip'])
                cmd = f'ssh -i {KEY} -p {port} {hostname}'
                print(cmd)
                os.system(cmd)