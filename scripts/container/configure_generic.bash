#!/bin/bash

set -e

SCRIPT_NAME="${BASH_SOURCE##*/}"
source "$TEMP_SCRIPTS_DIR/libs/lib_msg.bash"
source "$TEMP_SCRIPTS_DIR/libs/lib_apply_conf.bash"

# Configure Locales
apply_conf "$CONT_USER" 'locale.gen' '/etc/locale.gen'
apply_conf "$CONT_USER" 'locale.conf' '/etc/locale.conf'
locale-gen

# Configure optionally git
die_git_opt_appears_multiple_times() {
	die 1 "Wrong value for \"\$CONT_GIT_CONFIG_INHERITANCE\", \"$1\" option appears multiple times"
}

configure_git() {
	echo "CONT_GIT_CONFIG_INHERITANCE=$CONT_GIT_CONFIG_INHERITANCE"
	[[ -z "$CONT_GIT_CONFIG_INHERITANCE" ]] && return 0
	
	local -i system_f=0
	local -i global_f=0
	for val in $CONT_GIT_CONFIG_INHERITANCE; do
		case "$val" in
			'system')
				[[ $system_f -eq 1 ]] && die_git_opt_appears_multiple_times "$val"
				system_f+=1
				;;
			'global')
				[[ $global_f -eq 1 ]] && die_git_opt_appears_multiple_times "$val"
				global_f+=1
				;;
			*)
				die 1 "Wrong value for \"\$CONT_GIT_CONFIG_INHERITANCE\", \"$val\" option doesn't exist"
				;;
		esac
	done
	echo "system_f = $system_f"
	if [[ $system_f -eq 1 ]]; then
		if [[ -e $TEMP_CACHE_DIR/raw-host-configs/system.gitconfig ]]; then
			cat << EOF >> $home_dir/.gitconfig
[include]
	path = $CONT_PROJ_DIR/$HOST_CACHE_DIR/raw-host-configs/system.gitconfig
EOF
		else
			die 1 "Couldn't find system gitconfig in cache, please rerun scripts/setup/setup.bash"
		fi
	fi
	echo "global_f = $global_f"
	if [[ $global_f -eq 1 ]]; then
		if [[ -e $TEMP_CACHE_DIR/raw-host-configs/system.gitconfig ]]; then
			cat << EOF >> $home_dir/.gitconfig
[include]
	path = $CONT_PROJ_DIR/$HOST_CACHE_DIR/raw-host-configs/global.gitconfig
EOF
		else
			die 1 "Couldn't find global gitconfig in cache, please rerun scripts/setup/setup.bash"
		fi
	fi
	chown -R "$CONT_USER:$CONT_USER" $home_dir/.gitconfig
}

if [[ "$CONT_USER" == 'root' ]]; then
	home_dir=/root
else
	home_dir=/home/$CONT_USER
fi

configure_git