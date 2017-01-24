#!/bin/bash

# Loads a configuration file (bash) if it only includes variables and/or comments.
function load_config () {
  local CFGPATH="$1"
  if [ -z "$CFGPATH" ] || [ -e "$CFGPATH" ]; then
    # file missing or not existing
    return 1
  fi
  if egrep -q -v '^#|^[^ ]*=[^;]*' "$CFGPATH"; then
    # malformed configuration file
    return 2
  fi
  source "$CFGPATH"
}

# mount point of remote backup device
BACKUP_MOUNT=/mnt/nas.pi
# synchronization script
BACKUP_SCRIPT=/home/sebschlicht/Scripts/sync.sh
# mapping from local to remote paths
BACKUP_MAPPING=/home/sebschlicht/.nas.pi.map
# file with exclusion patterns
BACKUP_EXCLUDE=/home/sebschlicht/.nas.pi.ignore

# mounts a device that has an entry in /etc/fstab if it is not mounted yet
WAS_MOUNTED=false
function require_mount {
  if mount | grep "$1" > /dev/null; then
    WAS_MOUNTED=true
    return 0
  fi
  sudo mount "$1"
}

LCK=/tmp/backup.lock
if [ -f "$LCK" ]; then
  echo "Lock '$LCK' exists, script already running."
  exit 1
fi

trap 'rm -f "$LCK"; exit $?' INT TERM EXIT

require_mount "$BACKUP_MOUNT"
"$BACKUP_SCRIPT" "$BACKUP_MAPPING" -f "$BACKUP_EXCLUDE"

if ! "$WAS_MOUNTED"; then
  sudo umount "$BACKUP_MOUNT"
fi

rm -f "$LCK"
trap - INT TERM EXIT

