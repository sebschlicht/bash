#!/bin/bash

DRY=false

function printUsage {
  echo 'Synchronization script for file backups using rsync.'
  echo 'No files will be deleted remotely and newer files will not be overridden.'
  echo
  echo 'Usage: ./sync.sh [OPTIONS] MAPPING_FILE'
  echo
  echo 'MAPPING_FILE	File containing directory mappings. Each line contains any directory that should be synchronized and its destination. (rsync syntax applies)'
  echo
  echo 'Options:'
  echo '-n, --dry-run	Do a dry run without actually writing files.'
  #echo '-d, --pull	Instead of pushing files to remote, you can pull files from remote.'
}

function parseArguments {
  while [[ $# > 0 ]]; do
    key="$1"
    case $key in
      # help
      -h|--help)
      printUsage
      exit 0
      ;;
      # dry run
      -n|--dry-run)
      DRY=true
      ;;
      # exclusion file
      -f|--exclusion-file)
      EXCLUSION_FILE="$2"
      shift
      ;;
      # unknown option
      -*)
      echo 'Unknown option '"'$key'"'!'
      return 1
      ;;
      # parameter
      *)
      if ! handleParameter "$1"; then
        echo 'Too many arguments!'
        return 1
      fi
      ;;
    esac
    shift
  done

  if [ -z "$INPUT_FILE" ]; then
    echo 'Too few arguments! Please specify a mapping file.'
    return 2
  #elif [ ! -f "$INPUT_FILE" ]; then
  #  echo 'There is no such file '"'$INPUT_FILE'"'! Please provide an existing file containing the directory mapping.'
  #  return 3
  fi
}

function handleParameter {
  # 1. mapping file
  if [ -z "$INPUT_FILE" ]; then
    INPUT_FILE="$1"
  # too many parameters
  else
    return 1
  fi
}

function push {
  source="$1"
  target="$2" 

  # output
  OPTS='-h -i'

  # transfer
  OPTS="$OPTS"' -a --no-p --progress -s -u -z'

  # exclusion
  if [ -n "$EXCLUSION_FILE" ] && [ -f "$EXCLUSION_FILE" ]; then
    OPTS="$OPTS"' --exclude-from='"$EXCLUSION_FILE"
  fi

  if $DRY; then
    OPTS="$OPTS"' -n'
  fi

  rsync $OPTS "$source" "$target"
}

parseArguments "$@"
SUCCESS=$?
if [ "$SUCCESS" -ne 0 ]; then
  echo 'Use the '"'-h'"' switch for help.'
  exit "$SUCCESS"
fi

if $DRY; then
  echo '--- THIS IS A DRY RUN, NO CHANGES WILL BE PERFORMED ---'
fi

grep -v '^#' "$INPUT_FILE" | while read from to; do
  push $from $to
done
