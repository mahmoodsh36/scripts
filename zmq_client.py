#!/usr/bin/env python
import itertools
import sys
import zmq

REQUEST_TIMEOUT = 2500
REQUEST_RETRIES = 3
SERVER_ENDPOINT = "tcp://localhost:5555"

context = zmq.Context()

print("Connecting to server…")
client = context.socket(zmq.REQ)
client.connect(SERVER_ENDPOINT)

for sequence in itertools.count():
    request = str(sequence).encode()
    print("Sending (%s)", request)
    client.send(request)

    retries_left = REQUEST_RETRIES
    while True:
        if (client.poll(REQUEST_TIMEOUT) & zmq.POLLIN) != 0:
            reply = client.recv()
            print(request)
            print(sequence)
            if int(reply) == sequence:
                print("Server replied OK (%s)", reply)
                retries_left = REQUEST_RETRIES
                break
            else:
                print("Malformed reply from server: %s", reply)
                continue

        retries_left -= 1
        print("No response from server")
        # Socket is confused. Close and remove it.
        client.setsockopt(zmq.LINGER, 0)
        client.close()
        if retries_left == 0:
            print("Server seems to be offline, abandoning")
            sys.exit()

        print("Reconnecting to server…")
        # Create new connection
        client = context.socket(zmq.REQ)
        client.connect(SERVER_ENDPOINT)
        print("Resending (%s)", request)
        client.send(request)