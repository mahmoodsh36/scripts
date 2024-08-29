#!/usr/bin/env sh
cd /home/mahmooz/work/mpv-history-daemon
venv/bin/python -m mpv_history_daemon daemon --log-file /home/mahmooz/data/mpv_data/my_log_file --write-period 30 --scan-time 1 /home/mahmooz/data/mpv_data/sockets /home/mahmooz/data/mpv_data/
