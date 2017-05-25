#!/bin/bash
PROGRAM_NAME='pdfshrink'
PROGRAM_TITLE='PDF Shrinking Skript'
QUIET=false

#################################
# variable initialization section 
#################################
DEFAULT_LEVEL=medium
SUPPORTED_LEVELS=( low medium high )
LEVEL=
SOURCE=
TARGET=

# Prints the usage of the script in case of using the help command.
printUsage () {
  echo 'Usage: '"$PROGRAM_NAME"' [OPTIONS] SOURCE TARGET'
  echo
  echo 'Shrinks a PDF file to reduce its size.'
  echo
  echo 'Options:'
  echo '-h, --help	 Display this help message and exit.'
  echo '-q, --quiet  Suppress any output.'
  echo '-l, --level  Specify the quality level. Possible values: low, medium, high. Defaults to high.'
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
      # TODO add options here
      # quality level
      -l|--level)
      shift
      LEVEL="$1"
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
  if [ -z "$SOURCE" ] || [ -z "$TARGET" ]; then
    fc_error 'Too few arguments!'
    return 2
  fi
  
  ##########################
  # check parameter validity
  ##########################
  if [ -z "$LEVEL" ] || [[ ! "${SUPPORTED_LEVELS[@]}" =~ "$LEVEL" ]]; then
    if [ -n "$LEVEL" ]; then
      fc_warn "Invalid quality level '$LEVEL', falling back to default level '$DEFAULT_LEVEL'."
    fi
    LEVEL="${DEFAULT_LEVEL}"
  fi
}

# Handles the parameters (arguments that aren't an option) and checks if their count is valid.
handleParameter () {
  # 1. parameter: source file
  if [ -z "$SOURCE" ]; then
    SOURCE="${1}"
  # 2. parameter: target file
  elif [ -z "$TARGET" ]; then
    TARGET="${1}"
  else
    # too many parameters
    return 1
  fi
}

##############################
# main script function section
##############################

# Determines the GhostScript settings device depending on the desired quality level.
fc_get_gs_device () {
  local level="$1"
  case $level in
    low)
      echo 'default'
      ;;
    medium)
      echo 'ebook'
      ;;
    *)
      echo 'printer'
      ;;
  esac
}

# Shrinks a PDF file to the desired quality level using GhostScript.
fc_gsshrink () {
  local level="$1"
  local source="$2"
  local target="$3"
  local device=$( fc_get_gs_device "$level" )
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/"$device" -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$target" "$source"
}

#############
# entry point
#############
parseArguments "$@"
SUCCESS=$?
if [ "$SUCCESS" -ne 0 ]; then
  fc_error "Use the '-h' switch for help."
  exit "$SUCCESS"
fi

# execute main script functions
fc_gsshrink "$LEVEL" "$SOURCE" "$TARGET"
