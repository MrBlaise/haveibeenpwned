#!/bin/bash -aeu

set -o pipefail
shopt -s expand_aliases

type shasum >/dev/null 2>&1 || type sha1sum >/dev/null 2>&1 && alias shasum=sha1sum ||  { echo >&2 "I require shasum or sha1sum to run. Aborting."; exit 1; }
type curl >/dev/null 2>&1 || { echo >&2 "I require curl to run. Aborting."; exit 1; }

function usage_exit {
    echo "${0} {password} [-f -d -i -p]"
    echo "Options:"
    echo -e "\t-f --file         to use a file of passwords (new line seperated)"
    echo -e "\t-d --delay        to set delay (defaults to 2s to prevent rate limit)"
    echo -e "\t-i --interactive  start interactive mode"
    echo -e "\t-p --plain        print plain passwords and their statuses" 
    echo "Example: ${0} 12345"    
    echo "Example: ${0} --file=password_file.txt --delay=2 --plain"    
    echo "Example: ${0} --interactive"    
    echo "Example: ${0} --interactive --plain"    
    exit 1
}

function check_password {
    (curl -s https://api.pwnedpasswords.com/range/$(echo -n "${1}" | shasum | cut -b 1-5) | grep $(echo -n "${1}" | shasum | cut -b 6-40 | tr a-f A-F))
}

function check_password_interactive {
    echo -n "Password:"
    read -s pw
    echo -ne " Loading...\033[0K\r"
    if [[ ! -z "${PLAIN:-}" ]]; then
      check_password_with_plain_results ${pw}
    else
      check_password "${pw}"
    fi
    exit $?
}

function check_password_with_plain_results {
    echo -n "${1}" | (check_password "${1}" | xargs -0 -I {} echo -n "FOUND: ${1} -- {}") || echo "SAFE: ${1}" 
}

test "$#" -gt 0 || usage_exit

for i in "$@"
do
case $i in
    -f=*|--file=*)
    FILE="${i#*=}"
    shift 
    ;;
    -d=*|--delay=*)
    DELAY="${i#*=}"
    shift 
    ;;
    -i|--interactive)
    INTERACTIVE=1	    
    shift 
    ;;
    -p|--plain)
    PLAIN=1	    
    shift 
    ;;
    -h|--help)
    usage_exit
    shift 
    ;;
    *)
    check_password "${1}"
    exit $?
    ;;
esac
done

if [[ ! -z "${INTERACTIVE:-}" ]]; then
    check_password_interactive
fi

if [[ -z "${DELAY:-}" ]]; then
    DELAY=2
fi

if [[ ! -z "${FILE:-}" ]]; then
    first_run=1
    while read -r line; do
      if [[ "${first_run}" != 1  ]]; then
	  sleep "${DELAY}"
      fi
      if [[ ! -z "${PLAIN:-}" ]]; then
	  echo -n "${line}" | check_password_with_plain_results "${line}"
      else
          echo -n "${line}" | check_password "${line}" || :
      fi
      first_run=0
    done < "${FILE}"    
fi

if [[ -z "${INTERACTIVE:-}" ]] && [[ -z "${FILE:-}"  ]]; then
    usage_exit
fi

