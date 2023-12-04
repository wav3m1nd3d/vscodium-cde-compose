#!/bin/bash
set -e

SCRIPT_NAME="${BASH_SOURCE##*/}"
source "$TEMP_SCRIPTS_DIR/libs/lib_msg.bash"

apply_conf() {
	user="$1"
	name="$2"
	dest="$3"
	if [[ -f "$TEMP_CONFIGS_DIR/${name}_${user}.conf" ]]; then
		cat "$TEMP_CONFIGS_DIR/${name}_${user}.conf" | tee "$dest"
	elif [[ -f "$TEMP_CONFIGS_DIR/${name}_e${user}.conf" ]]; then
		while read line; do
			eval "echo ${line}"
		done <"$TEMP_CONFIGS_DIR/${name}_e${user}.conf" | tee "$dest"
	else
		die 1 "Missing configuration files for $name in \"$TEMP_CONFIGS_DIR\" directory, should be named in format ${name}_$user.conf or ${name}_e$user.conf to evaluate variables"
	fi
}

setup_ssh() {
	mkdir -p "$home_dir/.ssh"
	cp "$TEMP_SSH_DIR/$HOST_SSH_KEYPAIR_NAME.pub" "$home_dir/.ssh/authorized_keys"
	chown -R "$CONT_USER:$CONT_USER" $home_dir/.ssh
	chmod 0700 "$home_dir/.ssh"
	chmod 0600 "$home_dir/.ssh/authorized_keys"
	if [[ -z "$SSH_AGENT_PID" ]] || ! ps -p "$SSH_AGENT_PID" > /dev/null; then
		eval $(ssh-agent -s) > /dev/null
	fi
}
configure_supervisord_root() {
	apply_conf "root" "supervisord" "/etc/supervisor/supervisord.conf"
}

configure_supervisord_user() {
	mkdir -p /opt/{run,log/supervisor,supervisor}
	chown -R "$CONT_USER:$CONT_USER" /opt/run
	chown -R "$CONT_USER:$CONT_USER" /opt/log
	chown -R "$CONT_USER:$CONT_USER" /opt/supervisor
	apply_conf "user" "supervisord" "/opt/supervisor/supervisord.conf"
}

configure_ssh_root() {
	mkdir -p /var/run/sshd
	apply_conf "root" "sshd_config" "/etc/ssh/sshd_config"
}

configure_ssh_user() {
	mkdir -p /opt/{run/sshd,ssh/etc/ssh}
	chown -R "$CONT_USER:$CONT_USER" /opt/run
	chown -R "$CONT_USER:$CONT_USER" /opt/ssh
	apply_conf "user" "sshd_config" "/opt/ssh/sshd_config"
}


# Configure supervisor[d] and ssh[d]
if [[ "$CONT_USER" == 'root' ]]; then
	home_dir="/root"
	configure_supervisord_root
	configure_ssh_root
	setup_ssh
	ssh-keygen -A 
else
	home_dir="/home/$CONT_USER"
	configure_supervisord_user
	configure_ssh_user
	setup_ssh
	gosu "$CONT_USER" ssh-keygen -Af /opt/ssh
fi