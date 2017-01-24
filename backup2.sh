#!/bin/bash
PROGRAM_NAME='smbb'
PROGRAM_TITLE='Samba-Share Backup Script'
QUIET=false

# variable initialization section
readonly LOCKPATH=/tmp/backup.lock

# Prints the usage of the script in case of using the help command.
printUsage () {
  # TODO
  echo 'Usage: '"$PROGRAM_NAME"' SYNTAX'
  echo
  echo 'EXPLAIN GENERAL USAGE'
  echo
  echo 'Options:'
  echo '-h, --help	Display this help message and exit.'
  echo 'OPTIONS'
}

# Echoes an error message to stderr.
fc_error () {
  if [ "$QUIET" = false ]; then
    >&2 echo -e "[ERROR] $1"
  fi
}
# Echoes a warning to stderr.
fc_warn () {
  if [ "$QUIET" = false ]; then
    >&2 echo -e "[WARN] $1"
  fi
}
# Echoes an info message to stdout.
fc_info () {
  if [ "$QUIET" = false ]; then
    echo -e "[INFO] $1"
  fi
}

# Parses the startup arguments into variables.
parseArguments () {
  while [[ $# > 0 ]]; do
    key="$1"
    case $key in
      # help
      -h|--help)
      printUsage
      exit 0
      ;;
      # quiet mode
      -q|--quiet)
      QUIET=true
      ;;
      # unknown option
      -*)
      fc_error "Unknown option '$key'!"
      return 2
      ;;
      # parameter
      *)
      if ! handleParameter "$1"; then
        fc_error 'Too many arguments!'
        return 2
      fi
      ;;
    esac
    shift
  done
  
  # check for valid number of parameters
  if [ -z "$CONFIG_PATH" ]; then
    fc_error 'Too few arguments!'
    return 2
  fi

  # check parameter validity
  if [ ! -e "$CONFIG_PATH" ]; then
    fc_error "The specified configuration file '$CONFIG_PATH' does not exist!"
    return 3
  fi
}

# Handles the parameters (arguments that aren't an option) and checks if their count is valid.
handleParameter () {
  # 1. parameter: configuration file path
  if [ -z "$CONFIG_PATH" ]; then
    CONFIG_PATH="$1"
  else
    # too many parameters
    return 1
  fi
}

# Loads a configuration file (bash) if it only includes variables and/or comments.
function load_config () {
  local CFGPATH="$1"
  # TODO this is NOT working: key=value;echo 'foo' still possible!
  if egrep -q -v '^$|^#|^[^ ]*=[^;]*' "$CFGPATH"; then
    # malformed configuration file
    local LINES=$(egrep -v '^$|^#|^[^ ]*=[^;]*' "$CFGPATH")
    fc_error "The configuration file is malformed. Only comments and variable declarations are allowed. The following line(s) violate(s) this rule:\n'${LINES}'"
    return 1
  fi
  source "$CFGPATH"
}

##############################
# main script function section
##############################

# Checks whether a mount point is mounted or not.
fc_is_mounted () {
  if mount | grep "$1" >/dev/null; then
    return 0
  fi
  return 1
}

# Mounts the user-specified Samba share mount point. Either prompts for missing credentials or depends on proper fstab entries.
fc_mount () {
  fc_info "Mounting '$SMBB_MOUNTPOINT'..."
  if [ "$SMBB_AUTOMOUNT" = true ]; then
    # mount should have everything it needs in fstab
    sudo mount "$SMBB_MOUNTPOINT"
  else
    # prompt user to enter Samba account password
    local PASSWD=$(zenity --title='SMBB Samba User Authentication' --width=315 --entry --hide-text --text="Please enter the password of your Samba user '$SMBB_SAMBA_USER', in order to backup your system:")
    if [ -z "$PASSWD" ]; then
      return 1
    fi
    
    # use the given credentials to mount
    # TODO dependency: cifs
    sudo mount -t cifs -o user,noauto,username="$SMBB_SAMBA_USER",passwd="$PASSWD" "$SMBB_MOUNTPOINT"
  fi
  return $(fc_is_mounted "$SMBB_MOUNTPOINT")
}

# entry point
parseArguments "$@"
SUCCESS=$?
if [ "$SUCCESS" -ne 0 ]; then
  fc_error "Use the '-h' switch for help."
  exit "$SUCCESS"
fi

# execute main script functions
## check for running instances and trap lock file deletion
if [ -f "$LOCKPATH" ]; then
  fc_error "$PROGRAM_NAME is already running, exiting."
  exit 4
fi
trap 'rm -f "$LOCKPATH"; exit $?' INT TERM EXIT

## load configuration file
if ! load_config "$CONFIG_PATH"; then
  exit 5
fi

## mount Samba share if necessary
SMBB_UNMOUNT=false
if [ ! -z "$SMBB_MOUNTPOINT" ]; then
  # check if not already mounted
  if fc_is_mounted "$SMBB_MOUNTPOINT"; then
    SMBB_UNMOUNT=true
    fc_info "'$SMBB_MOUNTPOINT' is already mounted."
  elif ! fc_mount "$SMBB_MOUNTPOINT"; then
    fc_error "Failed to mount '$SMBB_MOUNTPOINT'!"
    exit 6
  fi
fi

## backup files
# TODO merge sync.sh

## unmount Samba share if mounted during execution
if [ "$SMBB_UNMOUNT" = true ]; then
  sudo umount "$SMBB_MOUNTPOINT"
fi

## remove lock file and trapping
rm -f "$LOCKPATH"
trap - INT TERM EXIT

