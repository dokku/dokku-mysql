# dokku mysql (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-mysql.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-mysql) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official mysql plugin for dokku. Currently defaults to installing [mysql 5.7.12](https://hub.docker.com/_/mysql/).

## requirements

- dokku 0.4.x+
- docker 1.8.x

## installation

```shell
# on 0.4.x+
sudo dokku plugin:install https://github.com/dokku/dokku-mysql.git mysql
```

## commands

```
mysql:backup <name> <bucket>   Create a backup of the mysql service to an existing s3 bucket
mysql:backup-auth <name> <aws_access_key_id> <aws_secret_access_key> Sets up authentication for backups on the mysql service
mysql:backup-deauth <name>     Removes backup authentication for the mysql service
mysql:backup-schedule <name> <schedule>  <aws_access_key_id> <aws_secret_access_key> <bucket> Schedules a backup of the mysql service
mysql:backup-unschedule <name> Unschedules the backup of the mysql service
mysql:clone <name> <new-name>  Create container <new-name> then copy data from <name> into <new-name>
mysql:connect <name>           Connect via mysql to a mysql service
mysql:create <name>            Create a mysql service with environment variables
mysql:destroy <name>           Delete the service and stop its container if there are no links left
mysql:enter <name> [command]   Enter or run a command in a running mysql service container
mysql:export <name> > <file>   Export a dump of the mysql service database
mysql:expose <name> [port]     Expose a mysql service on custom port if provided (random port otherwise)
mysql:import <name> < <file>   Import a dump into the mysql service database
mysql:info <name>              Print the connection information
mysql:link <name> <app>        Link the mysql service to the app
mysql:list                     List all mysql services
mysql:logs <name> [-t]         Print the most recent log(s) for this service
mysql:promote <name> <app>     Promote service <name> as DATABASE_URL in <app>
mysql:restart <name>           Graceful shutdown and restart of the mysql service container
mysql:start <name>             Start a previously stopped mysql service
mysql:stop <name>              Stop a running mysql service
mysql:unexpose <name>          Unexpose a previously exposed mysql service
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

# you can also specify custom environment
# variables to start the mysql service
# in semi-colon separated forma
export MYSQL_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku mysql:create lolipop

# get connection information as follows
dokku mysql:info lolipop

# you can also retrieve a specific piece of service info via flags
dokku mysql:info lolipop --config-dir
dokku mysql:info lolipop --data-dir
dokku mysql:info lolipop --dsn
dokku mysql:info lolipop --exposed-ports
dokku mysql:info lolipop --id
dokku mysql:info lolipop --internal-ip
dokku mysql:info lolipop --links
dokku mysql:info lolipop --service-root
dokku mysql:info lolipop --status
dokku mysql:info lolipop --version

# a bash prompt can be opened against a running service
# filesystem changes will not be saved to disk
dokku mysql:enter lolipop

# you may also run a command directly against the service
# filesystem changes will not be saved to disk
dokku mysql:enter lolipop ls -lah /

# a mysql service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku mysql:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_MYSQL_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_MYSQL_LOLIPOP_PORT=tcp://172.17.0.1:3306
#   DOKKU_MYSQL_LOLIPOP_PORT_3306_TCP=tcp://172.17.0.1:3306
#   DOKKU_MYSQL_LOLIPOP_PORT_3306_TCP_PROTO=tcp
#   DOKKU_MYSQL_LOLIPOP_PORT_3306_TCP_PORT=3306
#   DOKKU_MYSQL_LOLIPOP_PORT_3306_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   DATABASE_URL=mysql://mysql:SOME_PASSWORD@dokku-mysql-lolipop:3306/lolipop
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku mysql:link other_service playground

# since DATABASE_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_MYSQL_BLUE_URL=mysql://mysql:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku mysql:promote other_service playground

# this will replace DATABASE_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   DATABASE_URL=mysql://mysql:ANOTHER_PASSWORD@dokku-mysql-other_service:3306/other_service
#   DOKKU_MYSQL_BLUE_URL=mysql://mysql:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service
#   DOKKU_MYSQL_SILVER_URL=mysql://mysql:SOME_PASSWORD@dokku-mysql-lolipop:3306/lolipop

# you can also unlink a mysql service
# NOTE: this will restart your app and unset related environment variables
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

## Changing database adapter

It's possible to change the protocol for DATABASE_URL by setting
the environment variable MYSQL_DATABASE_SCHEME on the app:

```
dokku config:set playground MYSQL_DATABASE_SCHEME=mysql2
dokku mysql:link lolipop playground
```

Will cause DATABASE_URL to be set as
mysql2://mysql:SOME_PASSWORD@dokku-mysql-lolipop:3306/lolipop

CAUTION: Changing MYSQL_DATABASE_SCHEME after linking will cause dokku to
believe the service is not linked when attempting to use `dokku mysql:unlink`
or `dokku mysql:promote`.
You should be able to fix this by

- Changing DATABASE_URL manually to the new value.

OR

- Set MYSQL_DATABASE_SCHEME back to its original setting
- Unlink the service
- Change MYSQL_DATABASE_SCHEME to the desired setting
- Relink the service

### Backups

Datastore backups are supported via AWS S3. The only supported region is `us-east-1`, and using an S3 bucket in another region will result in an error. If you would like to sponsor work to enable support for other regions, please contact @josegonzalez.

Backups can be performed using the backup commands:

```
# setup s3 backup authentication
dokku mysql:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# remove s3 authentication
dokku mysql:backup-deauth lolipop

# backup the `lolipop` service to the `BUCKET_NAME` bucket on AWS
dokku mysql:backup lolipop BUCKET_NAME

# schedule a backup
dokku mysql:backup-schedule lolipop CRON_SCHEDULE BUCKET_NAME

# remove the scheduled backup from cron
dokku mysql:backup-unschedule lolipop
```

### Adding a custom my.cnf

You can create a custom my.cnf by saving it to `/var/lib/dokku/services/mysql/APP_NAME/config/my.cnf` and restarting your database
