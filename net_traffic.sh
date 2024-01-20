#!/usr/bin/env sh

get_tx() {
    cat /sys/class/net/wlan0/statistics/tx_bytes
}
get_rx() {
    cat /sys/class/net/wlan0/statistics/rx_bytes
}

rx_prev=$(get_rx)
tx_prev=$(get_tx)
while true; do
    rx=$(get_rx)
    tx=$(get_tx)
    echo -n upload $(expr $tx - $tx_prev)
    echo -n ' '
    echo -n download $(expr $rx - $rx_prev)
    echo
    sleep 1;
    rx_prev=$rx
    tx_prev=$tx
done