#!/bin/bash
set -e

SCRIPT_NAME="${BASH_SOURCE##*/}"
source "$TEMP_SCRIPTS_DIR/libs/lib_msg.bash"
source "$TEMP_SCRIPTS_DIR/libs/lib_apply_conf.bash"

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
	mkdir -p $home_dir/.local/{run,log,etc/supervisor}
	chown -R $CONT_USER:$CONT_USER $home_dir/.local
	apply_conf user supervisord $home_dir/.local/etc/supervisor/supervisord.conf
}

configure_ssh_root() {
	mkdir -p /var/run/sshd
	apply_conf root sshd_config /etc/ssh/sshd_config
}

configure_ssh_user() {
	mkdir -p $home_dir/.local/{run/sshd,log,etc/ssh}
	chown -R $CONT_USER:$CONT_USER $home_dir/.local
	apply_conf user sshd_config $home_dir/.local/etc/ssh/sshd_config
}


# Configure supervisor[d] and ssh[d]
if [[ "$CONT_USER" == 'root' ]]; then
	home_dir=/root
	configure_supervisord_root
	configure_ssh_root
	setup_ssh
	ssh-keygen -A
else
	home_dir=/home/$CONT_USER
	configure_supervisord_user
	configure_ssh_user
	setup_ssh
	gosu $CONT_USER ssh-keygen -Af $home_dir/.local
fi