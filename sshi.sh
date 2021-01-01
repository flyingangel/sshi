#!/bin/bash

# ======
# SSHI
# ======

#set working dir
DIR_ROOT=$(dirname -- "$(realpath "$0")")
cd "$DIR_ROOT" || exit 1

#load external lib
source "$DIR_ROOT/shell_modules/shell-lib/autoload.sh"

log.header "-- SSHI --"
log.header "Hash: $(git branch) #$(git rev-parse --short HEAD)"
log.header "To show the manual: man sshi"
log.header "To set default username for current shell: export SSHI_USERNAME=username"
log.newline

function main() {
    #print hosts
    list=$(printf '%s' "$(cat /etc/hosts)" | awk -F "\\\s+" '{print $1"\t"$2}')
    i=0
    hostList=()

    log.header "#\tIP\t\tHost"

    while read -r line; do
        #test for valid IP
        if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
            ip=$(printf '%s' "$line" | awk -F "\t" '{print $1}')

            if [[ $ip == "127.0.0.1" ]]; then
                continue
            fi

            echo -e "$i\t$line"

            hostList+=("$ip")
            ((i++))
        fi
    done < <(echo "$list")

    log.newline

    read -rp "Choose a server number: " input

    #test if is a number
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        log.error "Invalid number"
        exit 1
    fi

    host="${hostList[$input]}"

    #ask for username
    if [[ -z $SSHI_USERNAME ]]; then
        input.read SSHI_USERNAME "Enter username of $host: "
    fi

    if [[ -z $SSHI_USERNAME || $SSHI_USERNAME =~ ' ' ]]; then
        log.error "Invalid username"
        exit 1
    fi

    {
        #debug
        printf '%s' "ssh $SSHI_USERNAME@$host "
        for arg in "$@"; do
            #if contains space
            if [[ "$arg" =~ ' ' ]]; then
                printf '"%s" ' "$arg"
            else
                printf '%s ' "$arg"
            fi
        done
     } | log.info

    #shellcheck disable=SC2029
    ssh "$SSHI_USERNAME"@"$host" "$@"
}

main "$@"
