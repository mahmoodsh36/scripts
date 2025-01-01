import sys
import os
import ctypes
import ctypes.util
import zmq
import threading
import time

REQUEST_TIMEOUT = 2500
REQUEST_RETRIES = 5

context = zmq.Context()
client = context.socket(zmq.REQ)
dest = sys.argv[1]
SERVER_ENDPOINT = dest
# socket.connect("tcp://localhost:5555")
client.connect(dest)

# set a timeout (in milliseconds) for sending and receiving
# socket.setsockopt(zmq.RCVHWM, 1) # high water mark, 1 means it will not buffer any messages
# socket.setsockopt(zmq.RCVTIMEO, 5000) # receive timeout: 5 seconds
# socket.setsockopt(zmq.SNDTIMEO, 5000) # send timeout: 5 seconds
# socket.setsockopt(zmq.RECONNECT_IVL, 1000) # reconnect interval: 1 second
# socket.setsockopt(zmq.LINGER, 0) # immediate close

sending = False
msgs = []

def sendmsg(msg):
    msgs.append(msg)
    if not sending:
        t = threading.Thread(target=start_sending)
        t.daemon = True
        t.start()

def start_sending():
    global msgs
    global client
    global sending
    sending = True
    while msgs:
        msg = msgs[0]
        request = msg.encode()
        print("sending", msg)
        client.send(request)

        retries_left = REQUEST_RETRIES
        while True:
            if (client.poll(REQUEST_TIMEOUT) & zmq.POLLIN) != 0:
                reply = client.recv()
                if reply.decode() == 'gotkey':
                    retries_left = REQUEST_RETRIES
                    break
                else:
                    print(f"malformed reply from server: {reply}")
                    continue

            retries_left -= 1
            print("No response from server")
            # Socket is confused. Close and remove it.
            client.setsockopt(zmq.LINGER, 0)
            client.close()
            if retries_left == 0:
                print("Server seems to be offline, abandoning")
                client.close()
                context.term()
                sys.exit()

            print("Reconnecting to server…")
            # Create new connection
            client = context.socket(zmq.REQ)
            client.connect(SERVER_ENDPOINT)
            print("Resending (%s)", request)
            client.send(request)

        del msgs[0]

    sending = False

# Constants for inotify
IN_MODIFY = 0x00000002

# Load libc
libc = ctypes.CDLL(ctypes.util.find_library('c'))

# define inotify functions from libc
inotify_init = libc.inotify_init
inotify_add_watch = libc.inotify_add_watch
inotify_read = libc.read

# https://stackoverflow.com/questions/1703640/how-to-implement-a-pythonic-equivalent-of-tail-f
def tail_file(filepath):
    # initialize inotify
    inotify_fd = inotify_init()

    # add a watch for file modification events
    wd = inotify_add_watch(inotify_fd, filepath.encode(), IN_MODIFY)

    # open the file and move to the end
    with open(filepath, 'r') as file:
        file.seek(0, os.SEEK_END)
        while True:
            # create a buffer to store inotify events
            buffer = os.read(inotify_fd, 1024) # this will block until the file is modified

            # Read and print any new lines from the file
            line = file.readline()
            if line:
                key = line.split(' ')[1][:-1]
                sendmsg(f'key {key}')
                # print(line, end='')

def main():
    # Start the tailing function in a separate thread
    tail_thread = threading.Thread(target=tail_file, args=('/tmp/keys.py.log',))
    tail_thread.daemon = True
    tail_thread.start()
    # join the tailing thread to make sure the program exits after it's done
    time.sleep(10000000)
    # tail_thread.join()

if __name__ == "__main__":
    main()
