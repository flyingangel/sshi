# sshi

A ssh client helper. Display list of hosts to connect.

## Install

Run `./install.sh` (as root) to install the `sshi` command.

Configure the host list using your host file `/etc/hosts`.

## How to use

Type `man sshi` to view man page.

Type `sshi` to use helper for `ssh` command. Additional arguments will be passed to the native `ssh` command e.g. `sshi -p 777 -t "ls -la"`.

Type `sshi scp /path/to/file` to use helper for `scp` command to send a file to remote server. Additional arguments will be passed to the native `scp` command e.g. `sshi scp -P 777 /path/to/file`.

## Uninstall

`sshi` command is installed in `/usr/local/bin`.

Use the script `uninstall.sh` to remove it automatically.

## Development

Test and update man page

    pandoc man/manpage.md -s -t man | /usr/bin/man -l -

Build man page

    pandoc man/manpage.md -s -t man | gzip > man/manpage.1.gz
