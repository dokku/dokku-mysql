# dokku mysql (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-mysql.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-mysql) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official mysql plugin for dokku. Currently defaults to installing [mysql 5.6.26](https://hub.docker.com/_/mysql/).

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```
dokku plugin:install-dependencies
dokku plugin:install https://github.com/dokku/dokku-mysql.git
```

## commands

```
mysql:alias <name> <alias>     Set an alias for the docker link
mysql:clone <name> <new-name>  Create container <new-name> then copy data from <name> into <new-name>
mysql:connect <name>           Connect via mysql to a mysql service
mysql:create <name>            Create a mysql service
mysql:destroy <name>           Delete the service and stop its container if there are no links left
mysql:export <name>            Export a dump of the mysql service database
mysql:expose <name> [port]     Expose a mysql service on custom port if provided (random port otherwise)
mysql:import <name> < <file>   Import a dump into the mysql service database
mysql:info <name>              Print the connection information
mysql:link <name> <app>        Link the mysql service to the app
mysql:list                     List all mysql services
mysql:logs <name> [-t]         Print the most recent log(s) for this service
mysql:restart <name>           Graceful shutdown and restart of the mysql service container
mysql:start <name>             Start a previously stopped mysql service
mysql:stop <name>              Stop a running mysql service
mysql:unexpose <name>          Unexpose a previously exposed mysql service
```

## usage

```shell
# create a mysql service named lolipop
dokku mysql:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official mysql image
export MYSQL_IMAGE="mysql"
export MYSQL_IMAGE_VERSION="5.5"
dokku mysql:create lolipop

# get connection information as follows
dokku mysql:info lolipop

# lets assume the ip of our mysql service is 172.17.0.1

# a mysql service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku mysql:link lolipop playground

# the above will expose the following environment variables
#
#   DATABASE_URL=mysql://mysql:SOME_PASSWORD@172.17.0.1:3306/lolipop
#   DATABASE_NAME=/lolipop/DATABASE
#   DATABASE_PORT=tcp://172.17.0.1:3306
#   DATABASE_PORT_3306_TCP=tcp://172.17.0.1:3306
#   DATABASE_PORT_3306_TCP_PROTO=tcp
#   DATABASE_PORT_3306_TCP_PORT=3306
#   DATABASE_PORT_3306_TCP_ADDR=172.17.0.1

# you can customize the environment
# variables through a custom docker link alias
dokku mysql:alias lolipop MYSQL_DATABASE

# you can also unlink a mysql service
# NOTE: this will restart your app
dokku mysql:unlink lolipop playground

# you can tail logs for a particular service
dokku mysql:logs lolipop
dokku mysql:logs lolipop -t # to tail

# you can dump the database
dokku mysql:export lolipop > lolipop.sql

# you can import a dump
dokku mysql:import lolipop < database.sql

# you can clone an existing database to a new one
dokku mysql:clone lolipop new_database

# finally, you can destroy the container
dokku mysql:destroy lolipop
```
