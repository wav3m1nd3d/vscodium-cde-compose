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
SCRIPT_NAME="${BASH_SOURCE##*/}"
echo "$SCRIPT_NAME: Done: Check bash requirements"


CDE_BAREBOOT_LIBS_DIR="${BASH_SOURCE%/*}/../libs"

source "$CDE_BAREBOOT_LIBS_DIR/lib_source_compose_env.bash"
source "$CDE_BAREBOOT_LIBS_DIR/lib_msg.bash"
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
msg 'Done: Load libraries and environment variables'


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
[[ $cont_missing -ge 1 ]] &&\
	die 1 'No containerization platform commands were found: "podman", "docker"'
[[ $compose_missing -ge 1 ]] &&\
	die 1 'No compose platform commands were found: "podman-compose", "docker compose"'
command -v ssh-add > /dev/null ||\
	die 1 "An OpenSSH command wasn't found: \"ssh-add\""
[[ -e "$CDE_BAREBOOT_COMPOSE_ENV" ]] ||\
	die 1 "Compose file not found in path \"$CDE_BAREBOOT_COMPOSE_ENV\", edit current script relative compose file path variable \"rel_copmose_yml_file_path\""
msg 'Done: Check required software availability'


codium_path="$(command -v codium)"
codium_dir="${codium_path%/*}"
if [[ -n "$codium_dir" ]]; then
	DEFAULT_HOST_CODIUM_RESOURCES_DIRS="$codium_dir/resources"
	codium_dir="${codium_dir%/*}"
	[[ -n "$codium_dir" ]] && DEFAULT_HOST_CODIUM_RESOURCES_DIRS+=":$codium_dir/resources"
	DEFAULT_HOST_CODIUM_RESOURCES_DIRS+=':'
fi
DEFAULT_HOST_CODIUM_RESOURCES_DIRS+="/usr/share/codium/resources:/opt/vscodium-bin/resources"

[[ -n "$CDE_HOST_CODIUM_RESOURCES_DIRS" ]] && CDE_HOST_CODIUM_RESOURCES_DIRS+=':'
CDE_HOST_CODIUM_RESOURCES_DIRS+=$DEFAULT_HOST_CODIUM_RESOURCES_DIRS

OLDIFS=$IFS
IFS=':'
for resources_dir in $CDE_HOST_CODIUM_RESOURCES_DIRS; do
	[[ -z "$resources_dir" ]] && break
	[[ -f "$resources_dir/app/product.json" ]] && { HOST_CODIUM_RESOURCES_DIR="$resources_dir"; break; }
done
IFS=$OLDIFS

mkdir -p "$CDE_HOST_CACHE_DIR/raw-host-configs"
cp "$HOST_CODIUM_RESOURCES_DIR/app/product.json" "$CDE_HOST_CACHE_DIR/raw-host-configs/codium_product.json"
msg 'Done: Find and cache VSCodium version information'


if command -v realpath > /dev/null; then
	CDE_BAREBOOT_COMPOSE_ENV="$(realpath "$CDE_BAREBOOT_COMPOSE_ENV")"
	CDE_BAREBOOT_COMPOSE="$(realpath "$CDE_BAREBOOT_COMPOSE")"
fi

$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" build cde-bootstrap
$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" run cde-bootstrap
msg 'Done: Bootstrap CDE'


if [ -z "$SSH_AUTH_SOCK" ]; then
	eval $(ssh-agent -s) > /dev/null
fi
ssh-add "$CDE_HOST_SSH_DIR/$CDE_HOST_SSH_KEYPAIR_NAME"
$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" build cde
msg 'Done: Build CDE'


echo -e "\n ----- \n\nTo spin up your CDE run:\n$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" up cde"