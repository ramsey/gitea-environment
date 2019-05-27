#!/usr/bin/env bash

set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "You must run this script as root to allow it to update your /etc/hosts file"
  exit
fi

SCRIPT_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"

function remove_hosts {
    sed -i '/^# RAMSEY-GITEA-DRONE START$/,/^# RAMSEY-GITEA-DRONE END/d' /etc/hosts
}

function update_hosts {
    remove_hosts

    echo "# RAMSEY-GITEA-DRONE START" >> /etc/hosts
    echo "127.0.0.1 gitea" >> /etc/hosts
    echo "127.0.0.1 drone" >> /etc/hosts
    echo "127.0.0.1 minio" >> /etc/hosts
    echo "# RAMSEY-GITEA-DRONE END" >> /etc/hosts
}

function start {
    mkdir -p "${SCRIPT_DIR}/data/composer"
    update_hosts
    docker-compose up -d
}

function stop {
    docker-compose down
    remove_hosts
}

case $1 in
    start|up)
        start
        ;;
    stop|down)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: ./service.sh [ start | stop | restart ]"
        ;;
esac
