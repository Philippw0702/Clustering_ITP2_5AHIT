set -e

for host in deb1 deb2 deb3 deb4; do
  if [ "$host" != "$HOSTNAME" ]; then
    ping -c1 -W1 $host >/dev/null 2>&1 || exit 1
  fi
done

exit 0
