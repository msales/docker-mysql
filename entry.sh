#!/bin/sh
#set -eu

TIMEZONE=${TIMEZONE:-"Europe/Warsaw"}
RAMDISK_SIZE=${RAMDISK_SIZE:-0}
RAMDISK_LOAD=${RAMDISK_LOAD:-false}
RAMDISK_SAVE=${RAMDISK_SAVE:-false}
MYSQLD_ARGS=${MYSQLD_ARGS:-"--skip-name-resolve --skip-host-cache"}

if [ ${RAMDISK_SIZE} -gt 0 ]; then
  echo "== We are going to run in ramdisk ..."
  cp /msales/tmpfs.cnf /etc/mysql/conf.d/
  chmod 644 /etc/mysql/conf.d/tmpfs.cnf

  mount -t tmpfs -o size="${RAMDISK_SIZE}m" tmpfs /var/lib/mysql_ramdisk || exit 1

  if [ "${RAMDISK_LOAD}" != "false" ] && [ -f /var/lib/mysql/ibdata1 ]; then
    echo "== Restoring database ..."
    cp -a /var/lib/mysql/* /var/lib/mysql_ramdisk/ && echo "== Content loaded" || echo "== Error saving db contents !"
  else
    echo "== Starting with a new content ..."
  fi

  echo "== Bindmount ramdisk ..."
  mount -o bind /var/lib/mysql_ramdisk /var/lib/mysql || exit 1

else
  echo "== Running without ramdisk"
fi

docker-entrypoint.sh "$@"& pid="$!";
trap "kill -TERM $pid" INT TERM;
while kill -0 $pid > /dev/null 2>&1; do
  wait $pid;
  ec="$?";
done;

if [ ${RAMDISK_SIZE} -gt 0 ] && [ "${RAMDISK_SAVE}" != "false" ]; then
  echo "== Unbindmounting ..."
  umount /var/lib/mysql
  echo "== Saving ramdisk content ..."
  rm -rf /var/lib/mysql/*
  cp -a /var/lib/mysql_ramdisk/* /var/lib/mysql/ && echo "== Content saved" || echo "== Error saving db contents !"
fi

exit $ec;
