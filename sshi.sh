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
        shift
        exec_scp "$@"
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
    local i

    #opts
    POSITIONAL=()
    for i in "$@"; do
        case $i in
        --username=*) SSHI_USERNAME="${i#*=}" ;;
        *) POSITIONAL+=("$i") ;;
        esac
    done
    #restore positional parameters
    set -- "${POSITIONAL[@]}"

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
    local i

    [[ -n $filename ]] || log.error "Argument filename missing" true

    #if absolute path not work, try relative path
    if [[ ! -f $filename && -f $CURRENT_DIR/$filename ]]; then
        filename="$(realpath "$CURRENT_DIR/$filename")"
    fi

    #last check
    [[ -f $filename ]] || log.error "Cound not found file $filename" true

    #remove filename argument
    shift

    #opts
    POSITIONAL=()
    for i in "$@"; do
        case $i in
        --dir=*) dir="${i#*=}" ;;
        --username=*) SSHI_USERNAME="${i#*=}" ;;
        *) POSITIONAL+=("$i") ;;
        esac
    done
    #restore positional parameters
    set -- "${POSITIONAL[@]}"

    ask_host
    ask_username

    {
        #debug
        printf '%s' "scp "
        print_args "$@"
        printf '%s' "$filename $SSHI_USERNAME@$host:$dir"
    } | log.info

    scp "$@" "$filename" "$SSHI_USERNAME@$host:$dir"

    log.finish "DONE"
}

function ask_host() {
    local input ip list i hostList textList dialogList

    i=1
    hostList=()
    textList=()
    dialogList=()
    list=$(printf '%s' "$(cat /etc/hosts)" | awk -F "\\\s+" '{print $1"\t"$2}')

    while read -r line; do
        #test for valid IP
        if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
            ip=$(printf '%s' "$line" | awk -F "\t" '{print $1}')
            host=$(printf '%s' "$line" | awk -F "\t" '{print $2}')

            if [[ $ip == "127.0.0.1" ]]; then
                continue
            fi

            textList+=("$(printf '   %-2s\t%-15s\t%-30s' "$i" "$ip" "$host")")
            dialogList+=("$i" "$(printf '%-15s\t%s' "$ip" "$host")")
            hostList+=("$ip")

            ((i++))
        fi
    done < <(echo "$list")

    # Use dialog to display
    if command -v dialog &> /dev/null; then
        input=$(dialog --keep-tite --menu "Choose a server:" 30 70 "${#dialogList[@]}" "${dialogList[@]}" 3>&1 1>&2 2>&3)

        # User cancel
        if ! [[ "$input" =~ ^[0-9]+$ ]]; then
            exit 1
        fi
    else
        log.header "$(printf '   %-2s\t%-15s\t%-30s\n' '#' 'IP' 'Host')"

        # Fallback to text-based selection
        for line in "${textList[@]}"; do
            printf '%s\n' "$line"
        done

        log.newline

        read -rp 'Choose a server number: ' input

        # Test if the input is a number
        if ! [[ "$input" =~ ^[0-9]+$ ]]; then
            log.error "Invalid number"
            exit 1
        fi
    fi

    #test if is a number
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        log.error "Invalid number"
        exit 1
    fi

    [[ $input -gt 0 ]] && ((input--))
    host="${hostList[$input]}"
}

function ask_username() {
    #ask for username
    if [[ -z $SSHI_USERNAME ]]; then
        log.newline
        log.header "To set default username for current shell: export SSHI_USERNAME=username"

        input.read SSHI_USERNAME "$host's username: "
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
