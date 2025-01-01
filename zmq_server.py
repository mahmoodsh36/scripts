#!/usr/bin/env python
import time
import zmq
import subprocess

context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://*:5555")

try:
    keys = ''
    while True:
        message = socket.recv().decode()
        print(message)
        if message.startswith('key'):
            key = '"' + message.split(' ')[1] + '"'
            if keys == '':
                keys = key
            else:
                keys = keys + ',' + key
            if 'up(' in key:
                cmd = f"sudo python ~/work/keys/keys.py -i '[{keys}]' --through_handler"
                print(cmd)
                subprocess.run(cmd, shell=True)
                keys = ''
            socket.send(b"gotkey")
        else:
            socket.send(b"?")
except KeyboardInterrupt:
    print("closing socket.")
    # close the socket and terminate the context
    socket.close()
    context.term()