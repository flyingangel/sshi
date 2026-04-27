#!/bin/bash
#installer script

#set working dir
DIR_ROOT=$(dirname -- "$0")
cd "$DIR_ROOT" || exit 1

#update git submodule if not done yet
if [[ ! -f shell_modules/shell-lib/autoload.sh ]]; then
    git submodule update --init --force --remote
fi

#load external lib
source shell_modules/shell-lib/autoload.sh

if ! right.is_root; then
    log.error "Sudo permission is required to install the binary"

    exit 1
fi

{
    install_binary "$(realpath sshi.sh)" "sshi"
    install_manpage man/manpage.1.gz sshi.1.gz
} || log.fatal "Error" true

log.finish "DONE"
