# dokku mysql (beta)

Official mysql plugin for dokku. Currently installs mysql 5.7.

## requirements

- dokku 0.3.25+
- docker 1.6.x

## installation

```
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-mysql-plugin.git mysql
dokku plugins-install-dependencies
dokku plugins-install
```

## commands

```
mysql:alias <name> <alias>     Set an alias for the docker link
mysql:clone <name> <new-name>  NOT IMPLEMENTED
mysql:connect <name>           Connect via mysql to a mysql service
mysql:create <name>            Create a mysql service
mysql:destroy <name>           Delete the service and stop its container if there are no links left
mysql:export <name>            Export a dump of the mysql service database
mysql:expose <name> <port>     NOT IMPLEMENTED
mysql:import <name> <file>     NOT IMPLEMENTED
mysql:info <name>              Print the connection information
mysql:link <name> <app>        Link the mysql service to the app
mysql:list                     List all mysql services
mysql:logs <name> [-t]         Print the most recent log(s) for this service
mysql:restart <name>           Graceful shutdown and restart of the service container
mysql:unexpose <name> <port>   NOT IMPLEMENTED
mysql:unlink <name> <app>      Unlink the mysql service from the app
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
#   DATABASE_NAME=/playground/DATABASE
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

# finally, you can destroy the container
dokku mysql:destroy playground
```

## todo

- implement mysql:clone
- implement mysql:expose
- implement mysql:import
