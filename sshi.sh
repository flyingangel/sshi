#!/bin/bash

# ======
# SSHI
# ======

#set working dir
CURRENT_DIR=$(pwd -P)
DIR_ROOT=$(dirname -- "$(realpath "$0")")
cd "$DIR_ROOT" || exit 1

#load external lib
source "$DIR_ROOT/shell_modules/shell-lib/autoload.sh"

function dispatcher() {
    local action=$1

    case $action in
    "-h" | "--help") man_sshi ;;
    "scp")
        exec_scp "$@"
        shift
        ;;
    *) exec_ssh "$@" ;;
    esac

}

function man_sshi() {
    log.header "-- SSHI --"
    log.header "Hash: $(git branch) #$(git rev-parse --short HEAD)"
    log.header "To show the manual: man sshi"
}

function exec_ssh() {
    ask_host
    ask_username

    {
        #debug
        printf '%s' "ssh $SSHI_USERNAME@$host "
        print_args "$@"
    } | log.info

    #shellcheck disable=SC2029
    ssh "$SSHI_USERNAME@$host" "$@"
}

function exec_scp() {
    local filename=$1
    local dir="~/"

    [[ -n $filename ]] || log.error "Argument filename missing" true

    #if absolute path not work, try relative path
    if [[ ! -f $filename && -f $CURRENT_DIR/$filename ]]; then
        filename="$(realpath "$CURRENT_DIR/$filename")"
    fi

    #remove filename argument
    shift

    #opts
    POSITIONAL=()
    for i in "$@"; do
        case $i in
        --dir=*) dir="${i#*=}" ;;
        *) POSITIONAL+=("$i") ;;
        esac
    done
    #restore positional parameters
    set -- "${POSITIONAL[@]}"

    ask_host
    ask_username

    {
        #debug
        printf '%s' "scp $filename $SSHI_USERNAME@$host:$dir "
        print_args "$@"
    } | log.info

    scp "$filename" "$SSHI_USERNAME@$host:$dir" "$@"

    log.finish "DONE"
}

function ask_host() {
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
}

function ask_username() {
    #ask for username
    if [[ -z $SSHI_USERNAME ]]; then
        log.newline
        log.header "To set default username for current shell: export SSHI_USERNAME=username"

        input.read SSHI_USERNAME "Enter username of $host: "
    fi

    if [[ -z $SSHI_USERNAME || $SSHI_USERNAME =~ ' ' ]]; then
        log.error "Invalid username"
        exit 1
    fi
}

function print_args() {
    for arg in "$@"; do
        #if contains space
        if [[ "$arg" =~ ' ' ]]; then
            printf '"%s" ' "$arg"
        else
            printf '%s ' "$arg"
        fi
    done
}

# ========
# = INIT =
# ========
dispatcher "$@"
