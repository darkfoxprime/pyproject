#!/bin/false

pypr_true() {
  return 0
}

pypr_false() {
  return 1
}

pypr_find_project_dir() {
  _pypr_project_dir="${1-$(pwd)}"
  while [[ "${_pypr_project_dir}" != "" && ! -f "${_pypr_project_dir}/.pyproject" ]]; do
    _pypr_project_dir="${_pypr_project_dir%/*}"
  done
  [[ -n "${_pypr_project_dir}" ]] || { echo "Unable to locate .pyproject file!" 1>&2; return 2; }
}

pypr_load_project() {
  local dir
  case "$#" in 0)
    [[ -n "${_pypr_project_dir}" ]] || pypr_find_project_dir || return 2
    set -- "${HOME}" "${_pypr_project_dir}"
  esac
  for dir in "$@"; do
    [[ -f "${dir}/.pyproject" ]] && eval "$(sed -e 's/^ *//;s/ *$//' -e '/^$/d' -e '/^#/d' -e '/^\[/{s/^.//;s/]$/__/;x;d}' -e 'x;G;s/\n//;p;s/__.*/__/;x;d' "${dir}/.pyproject")"
  done
}

_pypr_prog=$(basename "$0")
_pypr_usage=`sed -n -e '1,/^# *$/d' -e '/^$/,$d' -e '/^[^#]/,$d' -e '/^# *$/,$d' -e 's/^# //p' "$0"`
_pypr_usage_full=`sed -n -e '1,/^# *$/d' -e '/^$/,$d' -e '/^[^#]/,$d' -e 's/^# *$//p' -e 's/^# //p' "$0"`

pypr_usage() {
  local usage
  exec 1>&2
  case "$1" in
    +f)
      usage="${_pypr_usage_full}"
      shift
      ;;
    *)
      usage="${_pypr_usage}"
  esac
  case "$1" in
    -*)
      ec=$(echo "$1" | cut -c2-)
      shift
      ;;
    *)
      ec=22
      ;;
  esac
  case "$#" in
    0)
      ;;
    *)
      echo "$@"
      echo ""
  esac
  case $ec in
    0)
      echo "${_pypr_usage_full}"
      ;;
    *)
      echo "${usage}"
      ;;
  esac
  exit $ec
}

# pypr_parse_options [ "<long>[=][,<short>]" ... ] -- ${1+"$@"}
# parse the given options out of the passed in command line arguments
# each option specifier must have a long option, optionally followed by
# '=' if the option takes an argument, optionally followed by ',' and
# a single character short option.

pypr_parse_options() {
  local short_options
  local long_options
  local short_opt
  local long_opt
  local opt_sfx
  local t
  local -A short_to_long
  local -A takes_arg
  declare -a args
  short_options=''
  long_options=''
  while [[ -n "$1" && "$1" != "--" ]]; do
    [[ "${1%%,*}" == "${1%,*}" ]] || { echo "Invalid option specified: $1" 1>&2; return 254; }
    t="${1%,*}"
    long_opt="${t%=}"
    if [[ "${long_opt}" != "${t}" ]] ; then
      sfx=":"
      takes_arg[${long_opt}]=pypr_true
    else
      sfx=""
      takes_arg[${long_opt}]=pypr_false
    fi
    long_options="${long_options}${long_options:+,}${long_opt}${sfx}"
    t="${1#"${t}"}"
    short_opt="${t#,}"
    [[ -n "${t}" ]] && short_options="${short_options}${short_opt}${sfx}"
    short_to_long[${short_opt}]="${long_opt}"
    shift
  done
  [[ -n "$1" ]] || { echo "No end-of-options terminating -- found" 1>&2; return 254; }

  t="$(getopt -o "+${short_options}" --long "${long_options}" -n "${_pypr_prog}" "$@")"
  case $? in
    0) ;;
    *) pypr_usage;;
  esac
  eval "set -- $t"

  for long_opt in "${!takes_arg[@]}"; do
    if ${takes_arg[$long_opt]}; then
      eval "_pypr_opt_${long_opt}=''"
    else
      eval "_pypr_opt_${long_opt}=pypr_false"
    fi
  done

  while [[ "$1" != "--" ]]; do
    case "$1" in
      -h|--help)
        usage -0 ;;
      --*)
        long_opt="${1#--}"
        ;;
      -*)
        long_opt="${short_to_long[${1#-}]}"
        ;;
    esac
    shift
    if ${takes_arg[$long_opt]}; then
      eval "_pypr_opt_${long_opt}='$1'"
      shift
    else
      eval "_pypr_opt_${long_opt}=pypr_true"
    fi
  done

  shift
  _pypr_args=($@)
}
