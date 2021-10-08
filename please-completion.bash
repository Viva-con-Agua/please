#!/bin/bash
_please() {
  COMPREPLY=()

  # All possible first values in command line
  local SERVICES=("-v" "base" "network" "frontend" "api" "help" "quickinstall")

  # declare an associative array for options
  declare -A ACTIONS
  ACTIONS[base]="install down help"
  ACTIONS[network]="create delete set info help"
  ACTIONS[frontend]="link up update restart down logs help"
  ACTIONS[api]="link up add restart down logs help"
  ACTIONS[quickinstall]="donation"

  # All possible options at the end of the line
  local OPTIONS=("-d" "-q")

  # current word being autocompleted
  local cur=${COMP_WORDS[COMP_CWORD]}

  # If previous arg is -v it means that we remove -v from SERVICES for autocompletion
  if [ $3 = "-v" ] ; then
    SERVICES=${SERVICES[@]:1}
  fi

  # If previous arg is a key of ACTIONS (so it is a service).
  # It means that we must display action choices
  if [ ${ACTIONS[$3]+1} ] ; then
    COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
  # If previous arg is one of the actions or previous arg is an option
  # We are at the end of the command and only options are available
  elif [[ "${ACTIONS[*]}" == *"$3"* ]] || [[ "${OPTIONS[*]}" == *"$3"*  ]]; then
    # SPecial use case : help does not support options
    if [ "$3" != "help" ] ; then
      COMPREPLY=( `compgen -W "${OPTIONS[*]}" -- $cur` )
    fi
  else
    # if everything else does not match, we are either :
    # - first arg waiting for -v or a service code
    # - second arg with first being -v. waiting for a service code.
    COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
  fi
}

complete -F _please please
