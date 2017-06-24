#!/bin/false

pypr_find_project_dir() {
  _pypr_project_dir="${1-$(pwd)}"
  while [[ "${_pypr_project_dir}" != "" && ! -f "${_pypr_project_dir}/.pyproject" ]]; do
    _pypr_project_dir="${_pypr_project_dir%/*}"
  done
  [[ -n "${_pypr_project_dir}" ]] || { echo "Unable to locate .pyproject file!" 1>&2; return 2; }
}

pypr_load_project() {
  [[ -n "${_pypr_project_dir}" ]] || pypr_find_project_dir || return 2
  for dir in "${HOME}" "${_pypr_project_dir}"; do
    [[ -f "${dir}/.pyproject" ]] && eval "$(sed -e 's/^ *//;s/ *$//' -e '/^$/d' -e '/^#/d' -e '/^\[/{s/^.//;s/]$/__/;x;d}' -e 'x;G;s/\n//;p;s/__.*/__/;x;d' "${dir}/.pyproject")"
  done
}

