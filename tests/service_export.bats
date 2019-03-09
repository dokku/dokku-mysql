#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:export) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:export"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:export) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:export" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:export) success with SSH_TTY" {
  export ECHO_DOCKER_COMMAND="true"
  export SSH_TTY=`tty`
  password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  run dokku "$PLUGIN_COMMAND_PREFIX:export" l
  assert_exit_status 0
  assert_output "docker exec dokku.mysql.l bash -c printf '[client]\npassword=$password\n' > /root/credentials.cnf
docker exec dokku.mysql.l mysqldump --defaults-extra-file=/root/credentials.cnf --user=mysql l
docker exec dokku.mysql.l rm /root/credentials.cnf"
}

@test "($PLUGIN_COMMAND_PREFIX:export) success without SSH_TTY" {
  export ECHO_DOCKER_COMMAND="true"
  unset SSH_TTY
  password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  run dokku "$PLUGIN_COMMAND_PREFIX:export" l
  assert_exit_status 0
  assert_output "docker exec dokku.mysql.l bash -c printf '[client]\npassword=$password\n' > /root/credentials.cnf
docker exec dokku.mysql.l mysqldump --defaults-extra-file=/root/credentials.cnf --user=mysql l
docker exec dokku.mysql.l rm /root/credentials.cnf"
}
