# dokku mysql [![Build Status](https://img.shields.io/circleci/project/github/dokku/dokku-mysql.svg?branch=master&style=flat-square "Build Status")](https://circleci.com/gh/dokku/dokku-mysql/tree/master) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg?style=flat-square "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official mysql plugin for dokku. Currently defaults to installing [mysql 8.0.23](https://hub.docker.com/_/mysql/).

## Requirements

- dokku 0.12.x+
- docker 1.8.x

## Installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-mysql.git mysql
```

## Commands

```
mysql:app-links <app>                              # list all mysql service links for a given app
mysql:backup <service> <bucket-name> [--use-iam]   # creates a backup of the mysql service to an existing s3 bucket
mysql:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # sets up authentication for backups on the mysql service
mysql:backup-deauth <service>                      # removes backup authentication for the mysql service
mysql:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedules a backup of the mysql service
mysql:backup-schedule-cat <service>                # cat the contents of the configured backup cronfile for the service
mysql:backup-set-encryption <service> <passphrase> # sets encryption for all future backups of mysql service
mysql:backup-unschedule <service>                  # unschedules the backup of the mysql service
mysql:backup-unset-encryption <service>            # unsets encryption for future backups of the mysql service
mysql:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
mysql:connect <service>                            # connect to the service via the mysql connection tool
mysql:create <service> [--create-flags...]         # create a mysql service
mysql:destroy <service> [-f|--force]               # delete the mysql service/data/container if there are no links left
mysql:enter <service>                              # enter or run a command in a running mysql service container
mysql:exists <service>                             # check if the mysql service exists
mysql:export <service>                             # export a dump of the mysql service database
mysql:expose <service> <ports...>                  # expose a mysql service on custom port if provided (random port otherwise)
mysql:import <service>                             # import a dump into the mysql service database
mysql:info <service> [--single-info-flag]          # print the service information
mysql:link <service> <app> [--link-flags...]       # link the mysql service to the app
mysql:linked <service> <app>                       # check if the mysql service is linked to an app
mysql:links <service>                              # list all apps linked to the mysql service
mysql:list                                         # list all mysql services
mysql:logs <service> [-t|--tail]                   # print the most recent log(s) for this service
mysql:promote <service> <app>                      # promote service <service> as DATABASE_URL in <app>
mysql:restart <service>                            # graceful shutdown and restart of the mysql service container
mysql:start <service>                              # start a previously stopped mysql service
mysql:stop <service>                               # stop a running mysql service
mysql:unexpose <service>                           # unexpose a previously exposed mysql service
mysql:unlink <service> <app>                       # unlink the mysql service from the app
mysql:upgrade <service> [--upgrade-flags...]       # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to mysql:help. Please consult the `mysql:help` command for any undocumented commands.

### Basic Usage

### create a mysql service

```shell
# usage
dokku mysql:create <service> [--create-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

Create a mysql service named lolipop:

```shell
dokku mysql:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the mysql image.

```shell
export DATABASE_IMAGE="mysql"
export DATABASE_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku mysql:create lolipop
```

You can also specify custom environment variables to start the mysql service in semi-colon separated form.

```shell
export DATABASE_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku mysql:create lolipop
```

### print the service information

```shell
# usage
dokku mysql:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku mysql:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
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
```

### list all mysql services

```shell
# usage
dokku mysql:list
```

List all services:

```shell
dokku mysql:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku mysql:logs <service> [-t|--tail]
```

flags:

- `-t|--tail`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku mysql:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku mysql:logs lolipop --tail
```

### link the mysql service to the app

```shell
# usage
dokku mysql:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A mysql service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app.

> NOTE: this will restart your app

```shell
dokku mysql:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_DATABASE_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_DATABASE_LOLIPOP_PORT=tcp://172.17.0.1:3306
DOKKU_DATABASE_LOLIPOP_PORT_3306_TCP=tcp://172.17.0.1:3306
DOKKU_DATABASE_LOLIPOP_PORT_3306_TCP_PROTO=tcp
DOKKU_DATABASE_LOLIPOP_PORT_3306_TCP_PORT=3306
DOKKU_DATABASE_LOLIPOP_PORT_3306_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
DATABASE_URL=mysql://lolipop:SOME_PASSWORD@dokku-mysql-lolipop:3306/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku mysql:link other_service playground
```

It is possible to change the protocol for `DATABASE_URL` by setting the environment variable `MYSQL_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground MYSQL_DATABASE_SCHEME=mysql2
dokku mysql:link lolipop playground
```

This will cause `DATABASE_URL` to be set as:

```
mysql2://lolipop:SOME_PASSWORD@dokku-mysql-lolipop:3306/lolipop
```

### unlink the mysql service from the app

```shell
# usage
dokku mysql:unlink <service> <app>
```

You can unlink a mysql service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku mysql:unlink lolipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the mysql connection tool

```shell
# usage
dokku mysql:connect <service>
```

Connect to the service via the mysql connection tool:

```shell
dokku mysql:connect lolipop
```

### enter or run a command in a running mysql service container

```shell
# usage
dokku mysql:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

```shell
dokku mysql:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku mysql:enter lolipop touch /tmp/test
```

### expose a mysql service on custom port if provided (random port otherwise)

```shell
# usage
dokku mysql:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku mysql:expose lolipop 3306
```

### unexpose a previously exposed mysql service

```shell
# usage
dokku mysql:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku mysql:unexpose lolipop
```

### promote service <service> as DATABASE_URL in <app>

```shell
# usage
dokku mysql:promote <service> <app>
```

If you have a mysql service linked to an app and try to link another mysql service another link environment variable will be generated automatically:

```
DOKKU_DATABASE_BLUE_URL=mysql://other_service:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku mysql:promote other_service playground
```

This will replace `DATABASE_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
DATABASE_URL=mysql://other_service:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service
DOKKU_DATABASE_BLUE_URL=mysql://other_service:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service
DOKKU_DATABASE_SILVER_URL=mysql://lolipop:SOME_PASSWORD@dokku-mysql-lolipop:3306/lolipop
```

### start a previously stopped mysql service

```shell
# usage
dokku mysql:start <service>
```

Start the service:

```shell
dokku mysql:start lolipop
```

### stop a running mysql service

```shell
# usage
dokku mysql:stop <service>
```

Stop the service and the running container:

```shell
dokku mysql:stop lolipop
```

### graceful shutdown and restart of the mysql service container

```shell
# usage
dokku mysql:restart <service>
```

Restart the service:

```shell
dokku mysql:restart lolipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku mysql:upgrade <service> [--upgrade-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart

You can upgrade an existing service to a new image or image-version:

```shell
dokku mysql:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all mysql service links for a given app

```shell
# usage
dokku mysql:app-links <app>
```

List all mysql services that are linked to the 'playground' app.

```shell
dokku mysql:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku mysql:clone <service> <new-service> [--clone-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

You can clone an existing service to a new one:

```shell
dokku mysql:clone lolipop lolipop-2
```

### check if the mysql service exists

```shell
# usage
dokku mysql:exists <service>
```

Here we check if the lolipop mysql service exists.

```shell
dokku mysql:exists lolipop
```

### check if the mysql service is linked to an app

```shell
# usage
dokku mysql:linked <service> <app>
```

Here we check if the lolipop mysql service is linked to the 'playground' app.

```shell
dokku mysql:linked lolipop playground
```

### list all apps linked to the mysql service

```shell
# usage
dokku mysql:links <service>
```

List all apps linked to the 'lolipop' mysql service.

```shell
dokku mysql:links lolipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the mysql service database

```shell
# usage
dokku mysql:import <service>
```

Import a datastore dump:

```shell
dokku mysql:import lolipop < database.dump
```

### export a dump of the mysql service database

```shell
# usage
dokku mysql:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku mysql:export lolipop
```

You can redirect this output to a file:

```shell
dokku mysql:export lolipop > lolipop.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### sets up authentication for backups on the mysql service

```shell
# usage
dokku mysql:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku mysql:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku mysql:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku mysql:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku mysql:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### removes backup authentication for the mysql service

```shell
# usage
dokku mysql:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku mysql:backup-deauth lolipop
```

### creates a backup of the mysql service to an existing s3 bucket

```shell
# usage
dokku mysql:backup <service> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the 'lolipop' service to the 'my-s3-bucket' bucket on ``AWS`:`

```shell
dokku mysql:backup lolipop my-s3-bucket --use-iam
```

### sets encryption for all future backups of mysql service

```shell
# usage
dokku mysql:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku mysql:backup-set-encryption lolipop
```

### unsets encryption for future backups of the mysql service

```shell
# usage
dokku mysql:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku mysql:backup-unset-encryption lolipop
```

### schedules a backup of the mysql service

```shell
# usage
dokku mysql:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku mysql:backup-schedule lolipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku mysql:backup-schedule lolipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku mysql:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku mysql:backup-schedule-cat lolipop
```

### unschedules the backup of the mysql service

```shell
# usage
dokku mysql:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku mysql:backup-unschedule lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `MYSQL_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.