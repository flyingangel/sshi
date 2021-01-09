# sshi

A ssh client helper. Display list of hosts to connect.

## Install

Run `./install.sh` (as root) to install the `sshi` command.

## How to use

Type `sshi` to use helper for `ssh` command.

Any additional arguments or options will be added to the native `ssh` command. Ex: `sshi -p 777 -t "ls -la"`.

Type `sshi scp /path/to/file` to use helper for `scp` command to send a file to remote server.

## Uninstall

`sshi` command is installed in `/usr/local/bin`.

Use the script `uninstall.sh` to remove it automatically.

## Development

Test and update man page

    pandoc man/manpage.md -s -t man | /usr/bin/man -l -

Build man page

    pandoc man/manpage.md -s -t man | gzip > man/manpage.1.gz
