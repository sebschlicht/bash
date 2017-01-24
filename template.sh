#!/bin/bash
# TODO
PROGRAM_NAME='tmpl'
PROGRAM_TITLE='Template'
QUIET=false

#################################
# variable initialization section 
#################################
# TODO

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
      # TODO add options here
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
  if [ -z "$DIR_SRC" ] || [ -z "$DIR_DEST" ]; then
    fc_error 'Too few arguments!'
    return 2
  fi
  
  ##########################
  # check parameter validity
  ##########################
  # TODO
}

# Handles the parameters (arguments that aren't an option) and checks if their count is valid.
handleParameter () {
  # 1. parameter: source directory
  if [ -z "$DIR_SRC" ]; then
    DIR_SRC="${1%/}"
  # 2. parameter: destination directory
  elif [ -z "$DIR_DEST" ]; then
    DIR_DEST="${1%/}"
  else
    # too many parameters
    return 1
  fi
}

##############################
# main script function section
##############################
# TODO
fc_foo () {
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

# TODO execute main script functions

