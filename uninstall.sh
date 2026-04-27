#!/bin/bash
#uninstaller script

#set working dir
DIR_ROOT=$(dirname -- "$0")
cd "$DIR_ROOT" || exit 1

#load external lib
source shell_modules/shell-lib/autoload.sh

if ! right.is_root; then
    log.error "Sudo permission is required to uninstall the binary"

    exit 1
fi

{
    uninstall_binary "sshi"
    uninstall_manpage "sshi.1.gz"
} || log.fatal "Error" true

log.finish "DONE"
