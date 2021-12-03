% sshi(1) 1.0 ZEAEAZE
% Thanh Trung NGUYEN
% January 2021

# NAME

sshi - SSH Interface

# SYNOPSIS

**sshi** [*OPTIONS*] [*COMMAND*] [*ARGS*]

# DESCRIPTION

A ssh client helper. Display list of hosts to connect. Host list are configured in */etc/hosts*

# OPTIONS

**-h, --help**
: display help message

**--username=[*USERNAME*]**
: set the ssh username for current operation

# COMMAND

**sshi [*ARGS*]**
: execute *ssh* command to connect to a remote host; additional arguments are passed to *ssh* command

**sshi scp [*FILE*] [*ARGS*]**
: execute *scp* command to remotely send a file; additionnal arguments are passed to the *scp* command

# TIPS

To memorize the username, simply export the [*SSHI_USERNAME*] variable to the shell or put in */home/user/.bashrc*

> export SSHI_USERNAME=username

# EXAMPLES

**sshi** -h | **sshi** --help

**sshi** -p 1234 -t "ls -la"

**sshi scp** /path/to/file -P 1234

# SEE ALSO

Full documentation at https://github.com/flyingangel/sshi.git

# COPYRIGHT

Copyright © 2021 Thanh Trung NGUYEN
