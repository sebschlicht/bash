#!/bin/bash
PROGRAM_NAME='flog'
PROGRAM_TITLE='FLAC to OGG'
PROGRAM_DESCRIPTION='Convert FLAC files to OGG (libvorbis) files via avconv. Uses quality level 9 (~320 kbits/s).'

# variable initialization section
DIR_SRC=
DIR_DEST=

# Prints the usage of the script in case of using the help command.
function printUsage {
  # TODO
  echo "$PROGRAM_TITLE"
  echo "$PROGRAM_DESCRIPTION"
  echo
  echo 'Usage: '"$PROGRAM_NAME"' SOURCE_DIR [DESTINATION_DIR]'
  echo
  echo 'EXPLAIN GENERAL USAGE'
  echo
  echo 'Options:'
  echo '-h, --help	Displays this help message.'
}

# Parses the startup arguments into variables.
function parseArguments {
  while [[ $# > 0 ]]; do
    key="$1"
    case $key in
      # help
      -h|--help)
      printUsage
      exit 0
      ;;
      # unknown option
      -*)
      echo "$PROGRAM_NAME"': Unknown option '"'$key'"'!'
      return 2
      ;;
      # parameter
      *)
      if ! handleParameter "$1"; then
        echo "$PROGRAM_NAME"': Too many arguments!'
        return 2
      fi
      ;;
    esac
    shift
  done

  # check for valid number of parameters
  if [ -z "$DIR_SRC" ]; then
    echo "$PROGRAM_NAME"': Too few arguments!'
    return 2
  fi
  
  # check parameter validity
  if [ -z "$DIR_DEST" ]; then
    DIR_DEST="$DIR_SRC"
  fi
}

# Handles the parameters (arguments that aren't an option) and checks if their count is valid.
function handleParameter {
  # 1. parameter: source directory
  if [ -z "$DIR_SRC" ]; then
    DIR_SRC="${1%/}"
  # [2. parameter: destination directory]
  elif [ -z "$DIR_DEST" ]; then
    DIR_DEST="${1%/}"
  else
    # too many parameters
    return 1
  fi
}

# main script function section
function fc_convert {
  FILE_SRC="$1"
  FILENAME="${FILE_SRC##*/}"
  FILENAME="${FILENAME%.*}"
  FILE_DEST="$DIR_DEST"/"$FILENAME".ogg
  
  if [ -f "$FILE_DEST" ]; then
    echo 'WARNING: Skipping existing file '"'$FILE_DEST'"'.'
    return 1
  fi
  
  avconv -i "$FILE_SRC" -c:a libvorbis -aq 9 "$FILE_DEST"
}

# entry point
parseArguments "$@"
SUCCESS=$?
if [ "$SUCCESS" -ne 0 ]; then
  echo 'Use the '"'-h'"' switch for help.'
  exit "$SUCCESS"
fi

# execute main script functions
for filepath in "$DIR_SRC"/*; do
  case "$filepath" in
    *.flac)
      fc_convert "$filepath"
      ;;
  esac
done

