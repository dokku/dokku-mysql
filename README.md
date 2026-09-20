# dokku mysql [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-mysql/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-mysql/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official mysql plugin for dokku. Currently defaults to installing [mysql 26.7.0](https://hub.docker.com/_/mysql/).

## Requirements

- dokku 0.35.x+
- docker 1.8.x

## Installation

```shell
# on 0.35.x+
sudo dokku plugin:install https://github.com/dokku/dokku-mysql.git --name mysql
```

## Commands

```
mysql:app-links [<app>]                            # list all MySQL service links for a given app
mysql:backup <service> <bucket-name> [-u|--use-iam] # create a backup of the MySQL service to an existing s3 bucket
mysql:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # set up authentication for backups on the MySQL service
mysql:backup-deauth <service>                      # remove backup authentication for the MySQL service
mysql:backup-schedule <service> <schedule> <bucket-name> [-u|--use-iam] # schedule a backup of the MySQL service
mysql:backup-schedule-cat <service>                # cat the contents of the configured backup cronfile for the service
mysql:backup-set-encryption <service> <passphrase> # set encryption for all future backups of MySQL service
mysql:backup-set-public-key-encryption <service> <public-key-id> # set GPG Public Key encryption for all future backups of MySQL service
mysql:backup-unschedule <service>                  # unschedule the backup of the MySQL service
mysql:backup-unset-encryption <service>            # unset encryption for future backups of the MySQL service
mysql:backup-unset-public-key-encryption <service> # unset GPG Public Key encryption for future backups of the MySQL service
mysql:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
mysql:connect <service>                            # connect to the service via the mysql connection tool
mysql:create <service> [--create-flags...]         # create a MySQL service
mysql:destroy <service> [-f|--force]               # delete the MySQL service/data/container if there are no links left
mysql:enter <service>                              # enter or run a command in a running MySQL service container
mysql:exists <service>                             # check if the MySQL service exists
mysql:export <service>                             # export a dump of the MySQL service database
mysql:expose <service> <ports...>                  # expose a MySQL service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
mysql:import <service>                             # import a dump into the MySQL service database
mysql:info <service> [--info-flags...]             # print the service information
mysql:link <service> [<app>] [--link-flags...]     # link the MySQL service to the app
mysql:linked <service> [<app>]                     # check if the MySQL service is linked to an app
mysql:links <service>                              # list all apps linked to the MySQL service
mysql:list                                         # list all MySQL services
mysql:logs <service> [-t|--tail [<tail-num>]]      # print the most recent log(s) for this service
mysql:pause <service>                              # pause a running MySQL service
mysql:promote <service> [<app>]                    # promote service <service> as DATABASE_URL in <app>
mysql:restart <service>                            # graceful shutdown and restart of the MySQL service container
mysql:set <service> <key> <value>                  # set or clear a property for a service
mysql:start <service>                              # start a previously stopped MySQL service
mysql:stop <service>                               # stop a running MySQL service
mysql:unexpose <service>                           # unexpose a previously exposed MySQL service
mysql:unlink <service> [<app>] [-n|--no-restart]   # unlink the MySQL service from the app
mysql:upgrade <service> [--upgrade-flags...]       # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to mysql:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `mysql:help` command for any undocumented commands.

### Basic Usage

### create a MySQL service

```shell
# usage
dokku mysql:create <service> [--create-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments to pass to the container create command
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image name to start the service with
- `-I|--image-version <string>`: the image version to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `-r|--root-password <string>`: override the root-level service password
- `-s|--shm-size <string>`: override shared memory size for the service docker container

Create a mysql service named lollipop:

```shell
dokku mysql:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the mysql image.

```shell
export MYSQL_IMAGE="mysql"
export MYSQL_IMAGE_VERSION="26.7.0"
dokku mysql:create lollipop
```

You can also specify custom environment variables to start the mysql service in semicolon-separated form.

```shell
export MYSQL_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku mysql:create lollipop
```

### delete the MySQL service/data/container if there are no links left

```shell
# usage
dokku mysql:destroy <service> [-f|--force]
```

flags:

- `-f|--force`: force the destruction of the service

Destroy the service, it's data, and the running container:

```shell
dokku mysql:destroy lollipop
```

### print the service information

```shell
# usage
dokku mysql:info <service> [--info-flags...]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--initial-network`: show the initial network being connected to
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku mysql:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku mysql:info lollipop --config-dir
dokku mysql:info lollipop --data-dir
dokku mysql:info lollipop --dsn
dokku mysql:info lollipop --exposed-ports
dokku mysql:info lollipop --id
dokku mysql:info lollipop --internal-ip
dokku mysql:info lollipop --initial-network
dokku mysql:info lollipop --links
dokku mysql:info lollipop --post-create-network
dokku mysql:info lollipop --post-start-network
dokku mysql:info lollipop --service-root
dokku mysql:info lollipop --status
dokku mysql:info lollipop --version
```

### list all MySQL services

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
dokku mysql:logs <service> [-t|--tail [<tail-num>]]
```

flags:

- `-t|--tail <int>`: tail the logs, optionally showing this many lines

You can tail logs for a particular service:

```shell
dokku mysql:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku mysql:logs lollipop --tail
```

By default the last 100 lines are shown, but a different count can be specified:

```shell
dokku mysql:logs lollipop --tail=5
```

### link the MySQL service to the app

```shell
# usage
dokku mysql:link <service> [<app>] [--link-flags...]
```

flags:

- `-a|--alias <string>`: an alternative alias to use for the config url exported to the app
- `-n|--no-restart`: whether to skip restarting the app
- `-q|--querystring <string>`: ampersand delimited querystring arguments to append to the service url

A mysql service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku mysql:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_MYSQL_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_MYSQL_LOLLIPOP_PORT=tcp://172.17.0.1:3306
DOKKU_MYSQL_LOLLIPOP_PORT_3306_TCP=tcp://172.17.0.1:3306
DOKKU_MYSQL_LOLLIPOP_PORT_3306_TCP_PROTO=tcp
DOKKU_MYSQL_LOLLIPOP_PORT_3306_TCP_PORT=3306
DOKKU_MYSQL_LOLLIPOP_PORT_3306_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
DATABASE_URL=mysql://:SOME_PASSWORD@dokku-mysql-lollipop:3306
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku mysql:link other_service playground
```

It is possible to change the protocol for `DATABASE_URL` by setting the environment variable `MYSQL_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground MYSQL_DATABASE_SCHEME=mysql2
dokku mysql:link lollipop playground
```

This will cause `DATABASE_URL` to be set as:

```
mysql2://:SOME_PASSWORD@dokku-mysql-lollipop:3306
```

### unlink the MySQL service from the app

```shell
# usage
dokku mysql:unlink <service> [<app>] [-n|--no-restart]
```

flags:

- `-n|--no-restart`: whether to skip restarting the app

You can unlink a mysql service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku mysql:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku mysql:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku mysql:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku mysql:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku mysql:set lollipop post-create-network
```

Set the keyserver a public key for backup encryption is fetched from:

```shell
dokku mysql:set lollipop backup-keyserver hkp://keys.example.com
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the mysql connection tool

```shell
# usage
dokku mysql:connect <service>
```

Connect to the service via the mysql connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku mysql:connect lollipop
```

### enter or run a command in a running MySQL service container

```shell
# usage
dokku mysql:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku mysql:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku mysql:enter lollipop touch /tmp/test
```

### expose a MySQL service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku mysql:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku mysql:expose lollipop 3306
```

Expose the service on the service's normal ports, with the first on a specified ip address (127.0.0.1):

```shell
dokku mysql:expose lollipop 127.0.0.1:3306
```

### unexpose a previously exposed MySQL service

```shell
# usage
dokku mysql:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku mysql:unexpose lollipop
```

### promote service <service> as DATABASE_URL in <app>

```shell
# usage
dokku mysql:promote <service> [<app>]
```

If you have a mysql service linked to an app and try to link another mysql service another link environment variable will be generated automatically:

```
DOKKU_DATABASE_BLUE_URL=mysql://:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku mysql:promote other_service playground
```

This will replace `DATABASE_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
DATABASE_URL=mysql://:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service
DOKKU_DATABASE_BLUE_URL=mysql://:ANOTHER_PASSWORD@dokku-mysql-other-service:3306/other_service
DOKKU_DATABASE_SILVER_URL=mysql://:SOME_PASSWORD@dokku-mysql-lollipop:3306/lollipop
```

### start a previously stopped MySQL service

```shell
# usage
dokku mysql:start <service>
```

Start the service:

```shell
dokku mysql:start lollipop
```

### stop a running MySQL service

```shell
# usage
dokku mysql:stop <service>
```

Stop the service and removes the running container:

```shell
dokku mysql:stop lollipop
```

### pause a running MySQL service

```shell
# usage
dokku mysql:pause <service>
```

Pause the running container for the service:

```shell
dokku mysql:pause lollipop
```

### graceful shutdown and restart of the MySQL service container

```shell
# usage
dokku mysql:restart <service>
```

Restart the service:

```shell
dokku mysql:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku mysql:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments to pass to the container create command
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade
- `-s|--shm-size <string>`: override shared memory size for the service docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku mysql:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all MySQL service links for a given app

```shell
# usage
dokku mysql:app-links [<app>]
```

List all mysql services that are linked to the `playground` app.

```shell
dokku mysql:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku mysql:clone <service> <new-service> [--clone-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments to pass to the container create command
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `-r|--root-password <string>`: override the root-level service password
- `-s|--shm-size <string>`: override shared memory size for the service docker container

You can clone an existing service to a new one:

```shell
dokku mysql:clone lollipop lollipop-2
```

### check if the MySQL service exists

```shell
# usage
dokku mysql:exists <service>
```

Here we check if the lollipop mysql service exists.

```shell
dokku mysql:exists lollipop
```

### check if the MySQL service is linked to an app

```shell
# usage
dokku mysql:linked <service> [<app>]
```

Here we check if the lollipop mysql service is linked to the `playground` app.

```shell
dokku mysql:linked lollipop playground
```

### list all apps linked to the MySQL service

```shell
# usage
dokku mysql:links <service>
```

List all apps linked to the `lollipop` mysql service.

```shell
dokku mysql:links lollipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the MySQL service database

```shell
# usage
dokku mysql:import <service>
```

Import a datastore dump:

```shell
dokku mysql:import lollipop < data.dump
```

### export a dump of the MySQL service database

```shell
# usage
dokku mysql:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku mysql:export lollipop
```

You can redirect this output to a file:

```shell
dokku mysql:export lollipop > data.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

If both passphrase and public key forms of encryption are set, the public key encryption will take precedence.

The underlying core backup script is present [here](https://github.com/dokku/docker-s3backup/blob/main/backup.sh).

Backups can be performed using the backup commands:

### set up authentication for backups on the MySQL service

```shell
# usage
dokku mysql:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku mysql:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku mysql:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku mysql:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku mysql:backup-auth lollipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### remove backup authentication for the MySQL service

```shell
# usage
dokku mysql:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku mysql:backup-deauth lollipop
```

### create a backup of the MySQL service to an existing s3 bucket

```shell
# usage
dokku mysql:backup <service> <bucket-name> [-u|--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the `lollipop` service to the `my-s3-bucket` bucket on `AWS`:

```shell
dokku mysql:backup lollipop my-s3-bucket --use-iam
```

Restore a backup file (assuming it was extracted via `tar -xf backup.tgz`):

```shell
dokku mysql:import lollipop < backup-folder/export
```

### set encryption for all future backups of MySQL service

```shell
# usage
dokku mysql:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku mysql:backup-set-encryption lollipop
```

Public key encryption will take precendence over the passphrase encryption if both types are set.

### set GPG Public Key encryption for all future backups of MySQL service

```shell
# usage
dokku mysql:backup-set-public-key-encryption <service> <public-key-id>
```

Set the `GPG` Public Key for encrypting backups:

```shell
dokku mysql:backup-set-public-key-encryption lollipop
```

The <public-key-id> is fetched from `keyserver.ubuntu.com`, unless the service names another one with the backup-keyserver property:

```shell
dokku mysql:set lollipop backup-keyserver hkp://keys.example.com
```

### unset encryption for future backups of the MySQL service

```shell
# usage
dokku mysql:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku mysql:backup-unset-encryption lollipop
```

### unset GPG Public Key encryption for future backups of the MySQL service

```shell
# usage
dokku mysql:backup-unset-public-key-encryption <service>
```

Unset the `GPG` Public Key encryption for backups:

```shell
dokku mysql:backup-unset-public-key-encryption lollipop
```

### schedule a backup of the MySQL service

```shell
# usage
dokku mysql:backup-schedule <service> <schedule> <bucket-name> [-u|--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku mysql:backup-schedule lollipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku mysql:backup-schedule lollipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku mysql:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku mysql:backup-schedule-cat lollipop
```

### unschedule the backup of the MySQL service

```shell
# usage
dokku mysql:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku mysql:backup-unschedule lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `MYSQL_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
