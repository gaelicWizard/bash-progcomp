#!/usr/bin/env bats

load ../test_helper

function local_setup {
  load ../../completion/available/defaults.completion
  function _known_hosts() { :; }
  function defaults() { echo 'NSGlobalDomain, Bash It'; }
}

function __check_completion () {
  # Get the parameters as a single value
  COMP_LINE=$*

  # Get the parameters as an array
  eval set -- "$@"
  COMP_WORDS=("$@")

  # Index of the cursor in the line
  COMP_POINT=${#COMP_LINE}

  # Get the last character of the line that was entered
  COMP_LAST=$((${COMP_POINT} - 1))

  # If the last character was a space...
  if [[ ${COMP_LINE:$COMP_LAST} = ' ' ]]; then
    # ...then add an empty array item
    COMP_WORDS+=('')
  fi

  # Word index of the last word
  COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

  # Run the Bash-it completion function
  _defaults

  # Return the completion output
  echo "${COMPREPLY[@]}"
}

@test "completion defaults: ensure that the _defaults function is available" {
  type -a _defaults &> /dev/null
  assert_success
}

@test "completion defaults: - show verbs and options" {
  run __check_completion 'defaults '
  assert_line -n 0 'delete domains export find help import read read-type rename write -currentHost -host'
}

@test "completion defaults: r* - show matching verbs" {
  run __check_completion 'defaults r'
  assert_line -n 0 'read read-type rename'
}

@test "completion defaults: R* - show matching verbs" {
  run __check_completion 'defaults R'
  assert_line -n 0 'read read-type rename'
}

@test "completion defaults: -currentHost - show verbs" {
  run __check_completion 'defaults -currentHost '
  assert_line -n 0 'delete domains export find help import read read-type rename write'
}

@test "completion defaults: -host - show nothing" {
  run __check_completion 'defaults -host '
  assert_line -n 0 "$(_known_hosts -a)"
}

@test "completion defaults: -host teh_host_name - show verbs" {
  skip "not implemented"
  run __check_completion 'defaults -host teh_host_name '
  assert_line -n 0 'delete domains export find help import read read-type rename write'
}

@test "completion defaults: read - show all domains" {
  run __check_completion 'defaults read '
  assert_line -n 0 "NSGlobalDomain Bash\ It -app"
}

@test "completion defaults: read nsg* - show matching domains" {
  run __check_completion 'defaults read nsg'
  assert_line -n 0 "NSGlobalDomain"
}

@test "completion defaults: read NSG* - show matching domains" {
  run __check_completion 'defaults read NSG'
  assert_line -n 0 "NSGlobalDomain"
}
