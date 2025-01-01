#!/usr/bin/env sh
# this doesnt work properly
out=$(find_computers.py print_ips | head -1);
port=$(echo $out | cut -d ":" -f2);
ip=$(echo $out | cut -d ":" -f1);
[ $ip = $port ] && port=22
keys=""
tail -f /tmp/keys.py.log -n 0 | while read line; do
  key=\""$(echo "$line" | cut -d ' ' -f2)"\"
  echo $key
  if [ -z "$keys" ]; then
    keys="$key"
  else
    keys="$keys,$key"
  fi
  tosend=false
  if [[ "$key" = *up* ]]; then
    tosend=true
  fi
  if $tosend; then
    mycmd="sudo python ~/work/keys/keys.py -i '[$keys]' --through_handler"
    echo "$mycmd"
    # find_computers.py run "$mycmd"
    ssh $ip -p $port -i ~/brain/keys/hetzner1 "$mycmd"
    keys=""
  fi
done