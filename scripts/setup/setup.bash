#!/bin/bash
if [ -z "$BASH" ]; then 
	echo 'Error: Used shell is not "bash": consider installing it or setting up CDE manually' >&2
	exit 1
fi
if [ -n "${#BASH_VERSINFO[@]}" ] && [ "${#BASH_VERSINFO[@]}" -lt 2 ]; then
	echo 'Error: Cannot get bash version information: consider updating' >&2
	exit 1
fi
[[ "${BASH_VERSINFO[0]}" -lt 4 && "${#BASH_VERSINFO[1]}" -lt 3 ]] && CDE_LEGACY_MODE=1
set -e


CDE_BAREBOOT_LIBS_DIR="${BASH_SOURCE%/*}/../libs"

source "$CDE_BAREBOOT_LIBS_DIR/lib_source_compose_env.bash"
if [[ "$CDE_LEGACY_MODE" ]]; then
	source "$CDE_BAREBOOT_LIBS_DIR/lib_find_compose_files_legacy.bash"
	CDE_BAREBOOT_ROOT_DIR=''
	CDE_BAREBOOT_COMPOSE_ENV=''
	find_compose "${BASH_SOURCE%/*}" 3
	CDE_BAREBOOT_ROOT_DIR="${CDE_BAREBOOT_COMPOSE%/*}"
	find_compose_env "$CDE_BAREBOOT_ROOT_DIR" 3
	source_compose_env "$CDE_BAREBOOT_COMPOSE_ENV"
else
	source "$CDE_BAREBOOT_LIBS_DIR/lib_find_compose_files.bash"
	find_compose 'CDE_BAREBOOT_COMPOSE' "${BASH_SOURCE%/*}" 3
	CDE_BAREBOOT_ROOT_DIR="${CDE_BAREBOOT_COMPOSE%/*}"
	find_compose_env 'CDE_BAREBOOT_COMPOSE_ENV' "$CDE_BAREBOOT_ROOT_DIR" 3
	source_compose_env "$CDE_BAREBOOT_COMPOSE_ENV"
fi

cont_missing=0
compose_missing=0

if command -v podman > /dev/null; then
	if command -v podman-compose > /dev/null; then
		compose_cmd="podman-compose"
	else
		compose_missing=$(($compose_missing + 1))
	fi
elif command -v docker > /dev/null; then
	if command -v docker compose > /dev/null; then
		compose_cmd="docker compose"
	else
		compose_missing=$(($compose_missing + 1))
	fi
else
	cont_missing=$(($cont_missing + 1))
fi

if [ $cont_missing -ge 1 ]; then
	echo 'Error: No containerization platform commands were found: "podman", "docker"' >&2
	exit 1
fi

if [ $compose_missing -ge 1 ]; then
	echo 'Error: No compose platform commands were found: "podman-compose", "docker compose"' >&2
	exit 1
fi

if ! command -v ssh-add > /dev/null; then
	echo "Error: An OpenSSH command wasn't found: \"ssh-add\"" >&2
	exit 1
fi

if ! [ -e "$CDE_BAREBOOT_COMPOSE_ENV" ]; then
	echo "Error: Compose file not found in path \"$CDE_BAREBOOT_COMPOSE_ENV\", edit current script relative compose file path variable \"rel_copmose_yml_file_path\"" >&2
	exit 1
fi

if command -v realpath > /dev/null; then
	CDE_BAREBOOT_COMPOSE_ENV="$(realpath "$CDE_BAREBOOT_COMPOSE_ENV")"
	CDE_BAREBOOT_COMPOSE="$(realpath "$CDE_BAREBOOT_COMPOSE")"
fi

$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" --env-file "$CDE_BAREBOOT_COMPOSE_ENV" build cde-bootstrap
$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" --env-file "$CDE_BAREBOOT_COMPOSE_ENV" run cde-bootstrap
if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null; then
	eval $(ssh-agent -s) > /dev/null
fi
ssh-add "$CDE_HOST_SSH_DIR/$CDE_HOST_SSH_KEYPAIR_NAME"
$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" --env-file "$CDE_BAREBOOT_COMPOSE_ENV" build cde