# dokku mysql [![Build Status](https://img.shields.io/travis/dokku/dokku-mysql.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-mysql) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official mysql plugin for dokku. Currently defaults to installing [mysql 5.7.28](https://hub.docker.com/_/mysql/).

## requirements

- dokku 0.12.x+
- docker 1.8.x

## installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-mysql.git mysql
```

## commands

```
mysql:app-links <app>          List all mysql service links for a given app
mysql:backup <name> <bucket> (--use-iam) Create a backup of the mysql service to an existing s3 bucket
mysql:backup-auth <name> <aws_access_key_id> <aws_secret_access_key> (<aws_default_region>) (<aws_signature_version>) (<endpoint_url>) Sets up authentication for backups on the mysql service
mysql:backup-deauth <name>     Removes backup authentication for the mysql service
mysql:backup-schedule <name> <schedule> <bucket> Schedules a backup of the mysql service
mysql:backup-schedule-cat <name> Cat the contents of the configured backup cronfile for the service
mysql:backup-set-encryption <name> <passphrase> Set a GPG passphrase for backups
mysql:backup-unschedule <name> Unschedules the backup of the mysql service
mysql:backup-unset-encryption <name> Removes backup encryption for future backups of the mysql service
mysql:clone <name> <new-name>  Create container <new-name> then copy data from <name> into <new-name>
mysql:connect <name>           Connect via mysql to a mysql service
mysql:create <name>            Create a mysql service with environment variables
mysql:destroy <name>           Delete the service, delete the data and stop its container if there are no links left
mysql:enter <name> [command]   Enter or run a command in a running mysql service container
mysql:exists <service>         Check if the mysql service exists
mysql:export <name> > <file>   Export a dump of the mysql service database
mysql:expose <name> [port]     Expose a mysql service on custom port if provided (random port otherwise)
mysql:import <name> < <file>   Import a dump into the mysql service database
mysql:info <name>              Print the connection information
mysql:link <name> <app>        Link the mysql service to the app
mysql:linked <name> <app>      Check if the mysql service is linked to an app
mysql:list                     List all mysql services
mysql:logs <name> [-t]         Print the most recent log(s) for this service
mysql:promote <name> <app>     Promote service <name> as DATABASE_URL in <app>
mysql:restart <name>           Graceful shutdown and restart of the mysql service container
mysql:start <name>             Start a previously stopped mysql service
mysql:stop <name>              Stop a running mysql service
mysql:unexpose <name>          Unexpose a previously exposed mysql service
mysql:unlink <name> <app>      Unlink the mysql service from the app
mysql:upgrade <name>           Upgrade service <service> to the specified version
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
# in semi-colon separated form
export MYSQL_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku mysql:create lolipop

# get connection information as follows
dokku mysql:info lolipop

# you can also retrieve a specific piece of service info via flags
dokku mysql:info lolipop --config-dir
dokku mysql:info lolipop --data-dir
dokku mysql:info lolipop --dsn
dokku mysql:info lolipop --exposed-dsn
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

## Configuration

It is possible to add custom configuration settings.
`/etc/mysql/conf.d` is mapped to the output of `dokku mysql:info SERVICE --config-dir`

Any files placed in this folder will be loaded. If a file is changed you will need
to reload your database for the changes to take effect.

For more information on configuration options see https://dev.mysql.com/doc/refman/5.7/en/option-files.html

> Note: This plugin mounts a host directory into the container under `/etc/mysql/conf.d`. Custom images that have files in this directory will have those files overwritten by the mount.

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2
and has access to the bucket via an IAM profile. In that case, use the `--use-iam`
option with the `backup` command.

Backups can be performed using the backup commands:

```
# setup s3 backup authentication
dokku mysql:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# remove s3 authentication
dokku mysql:backup-deauth lolipop

# backup the `lolipop` service to the `BUCKET_NAME` bucket on AWS
dokku mysql:backup lolipop BUCKET_NAME

# schedule a backup
# CRON_SCHEDULE is a crontab expression, eg. "0 3 * * *" for each day at 3am
dokku mysql:backup-schedule lolipop CRON_SCHEDULE BUCKET_NAME

# cat the contents of the configured backup cronfile for the service
dokku mysql:backup-schedule-cat lolipop

# remove the scheduled backup from cron
dokku mysql:backup-unschedule lolipop
```

Backup auth can also be set up for different regions, signature versions and endpoints (e.g. for minio):

```
# setup s3 backup authentication with different region
dokku mysql:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION

# setup s3 backup authentication with different signature version and endpoint
dokku mysql:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL

# more specific example for minio auth
dokku mysql:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

## Exposed DSN

```shell
# expose the database (you must open the exposed port on your firewall if you have one)
dokku mysql:expose lolipop
# exposed dsn available on service info
dokku mysql:info lolipop
=====> Container Information
       ...
       Exposed dsn:         mysql://mysql:SOME_PASSWORD@dokku.me:28804/lolipop
       Exposed ports:       3306->28804
       ...
```

So now you connect to your database with [`mysqlsh`](https://dev.mysql.com/doc/mysql-shell/8.0/en/mysqlsh.html#option_mysqlsh_uri) or with your favorite client.

```shell
mysqlsh --uri=$(ssh dokku@dokku.me mysql:info lolipop --exposed-dsn)
```

## Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `MYSQL_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
