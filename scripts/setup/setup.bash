#!/bin/bash
if [ -z "$BASH" ]; then 
	echo 'E: Used shell is not "bash": consider installing it or setting up CDE manually' >&2
	exit 1
fi
if [ -z "${#BASH_VERSINFO[@]}" ] || [ ${#BASH_VERSINFO[@]} -lt 2 ]; then
	echo 'E: Cannot get bash version information: consider updating' >&2
	exit 1
fi
set -e
[[ ${BASH_VERSINFO[0]} -lt 4 && ${#BASH_VERSINFO[1]} -lt 3 ]] && declare -i CDE_LEGACY_MODE=1



CDE_BAREBOOT_LIBS_DIR="${BASH_SOURCE%/*}/../libs"
SCRIPT_NAME="${BASH_SOURCE##*/}"

echo "$SCRIPT_NAME: Loading libraries and environment variables"
source "$CDE_BAREBOOT_LIBS_DIR/lib_source_compose_env.bash"
source "$CDE_BAREBOOT_LIBS_DIR/lib_msg.bash"
source "$CDE_BAREBOOT_LIBS_DIR/lib_inherit_git_config.bash"
if [[ $CDE_LEGACY_MODE -eq 1 ]]; then
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
if command -v realpath > /dev/null; then
		CDE_BAREBOOT_COMPOSE_ENV="$(realpath "$CDE_BAREBOOT_COMPOSE_ENV")"
		CDE_BAREBOOT_COMPOSE="$(realpath "$CDE_BAREBOOT_COMPOSE")"
fi


get_req_cmds() {
	msg 'Finding required software'
	declare -g compose_cmd=''
	if command -v podman > /dev/null; then
		if command -v podman-compose > /dev/null; then
			compose_cmd='podman-compose'
		fi
	elif command -v docker > /dev/null; then
		if command -v docker compose > /dev/null; then
			compose_cmd='docker compose'
		fi
	else
		die 1 'No containerization platform commands were found: "podman", "docker"'
	fi	
	[[ -z "$compose_cmd" ]] &&\
		die 1 'No compose platform commands were found: "podman-compose", "docker compose"'
	command -v ssh-add > /dev/null ||\
		die 1 "An OpenSSH command couldn't be found: \"ssh-add\""
	command -v codium > /dev/null ||\
		die 1 "VSCodium command couldn't be found: \"codium\""
}
get_req_cmds

cache_codium_versinfo() {
	msg 'Finding and caching VSCodium version information'
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
}
cache_codium_versinfo

die_git_opt_appears_multiple_times() {
	die 1 "Wrong value for \"\$CONT_GIT_CONFIG_INHERITANCE\", \"$1\" option appears multiple times"
}

die_git_opt_mutually_exclusive() {
	die 1 "Wrong value for \"\$CONT_GIT_CONFIG_INHERITANCE\", \"$1\" and \"$2\" options are mutually exclusive"
}

cache_git_configs() {
	is_git_in_list "$CDE_CONT_PKGS" || return 0
	if ! command -v git >/dev/null; then
		msg "Skipping git host configuration caching, command \"git\" couldn't be found"
		return 0
	fi
	[[ -z "$CDE_CONT_GIT_CONFIG_INHERITANCE" ]] && return 0

	local -i system_f=0
	local -i global_f=0
	local -i local_f=0
	local -i config_f=0
	for val in $CDE_CONT_GIT_CONFIG_INHERITANCE; do
		case "$val" in
			'system')
				[[ $system_f -eq 1 ]] && die_git_opt_appears_multiple_times "$val"
				system_f+=1
				;;
			'global')
				[[ $global_f -eq 1 ]] && die_git_opt_appears_multiple_times "$val"
				global_f+=1
				;;
			'local')
				[[ $local_f -eq 1 ]] && die_git_opt_appears_multiple_times "$val"
				local_f+=1
				;;
			'config')
				[[ $config_f -eq 1 ]] && die_git_opt_appears_multiple_times "$val"
				[[ $system_f -eq 1 ]] && die_git_opt_mutually_exclusive "$val" 'system'
				[[ $global_f -eq 1 ]] && die_git_opt_mutually_exclusive "$val" 'global'
				[[ $local_f -eq 1 ]] && die_git_opt_mutually_exclusive "$val" 'local'
				config_f+=1
				;;
			*)
				die 1 "Wrong value for \"\$CONT_GIT_CONFIG_INHERITANCE\", \"$val\" option doesn't exist"
				;;
		esac
	done
	msg 'Caching git host configuration'
	[[ $system_f -eq 1 ]] && git config --list --system 2>/dev/null 1>"$CDE_HOST_CACHE_DIR/raw-host-configs/git_system.conf" || true
	[[ $global_f -eq 1 ]] && git config --list --global 2>/dev/null 1>"$CDE_HOST_CACHE_DIR/raw-host-configs/git_global.conf" || true
	[[ $local_f -eq 1 ]] && git config --list --local 2>/dev/null 1>"$CDE_HOST_CACHE_DIR/raw-host-configs/git_local.conf" || true
	if [[ $config_f -eq 1 ]]; then 
		git config --list --system 2>/dev/null 1>"$CDE_HOST_CACHE_DIR/raw-host-configs/git_system.conf" || true
		git config --list --global 2>/dev/null 1>"$CDE_HOST_CACHE_DIR/raw-host-configs/git_global.conf" || true
		git config --list --local 2>/dev/null 1>"$CDE_HOST_CACHE_DIR/raw-host-configs/git_local.conf" || true
	fi
}
cache_git_configs

bootstrap_cde() {
	msg 'Bootstrapping CDE'
	$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" build cde-bootstrap
	$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" run cde-bootstrap
}
bootstrap_cde

add_cde_ssh_identity() {
	msg 'Adding CDE ssh identity'
	if [ -z "$SSH_AUTH_SOCK" ]; then
		eval $(ssh-agent -s) > /dev/null
	fi
	ssh-add "$CDE_HOST_SSH_DIR/$CDE_HOST_SSH_KEYPAIR_NAME"
}
add_cde_ssh_identity

build_cde() {
	msg 'Building CDE'
	$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" build cde
}
build_cde

echo -e "\n ----- \n\nTo spin up your CDE run:\n$compose_cmd -f "$CDE_BAREBOOT_COMPOSE" up cde"