el-tracker
==========

Simple command line application to track earned leave.

`el-tracker add --help`

`el-tracker use --help`

`el-tracker report --help`

You can set certain options in a configuration file in
`~/.el-tracker/config.yml`.

    ---
	global:
     name: Randall Smith
     dsn: dbi:SQLite:dbname=/home/user/.el-tracker/el-tracker.sqlite3

Docker
======

For your amusement, you can also run el-tracker in a docker container.

Build: `docker build -t el-tracker .`

Run: `docker run -it --rm -v $HOME/.el-tracker:/data el-tracker <opts>`

When run without options, the el-tracker docker will print the help
message.

The docker container expects a configuration file named "config.yaml"
and the database file named "el-tracker.sqlite3" to be in `/data`.

You may want to write a little wrapper script to simplify running the
el-tracker docker. Here's an example.

    #!/bin/bash
    
    IMAGE=el-tracker
    DOCKER=docker
    DATA=$HOME/.el-tracker
    
    $DOCKER run -it --rm -v $DATA:/data $IMAGE "$@"



