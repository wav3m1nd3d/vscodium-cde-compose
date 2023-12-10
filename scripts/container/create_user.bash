#!/bin/bash
set -e

SCRIPT_NAME="${BASH_SOURCE##*/}"
source "$TEMP_SCRIPTS_DIR/libs/lib_msg.bash"

chk_file_accessible() {
	if ! [[ -f "$1" ]]; then
		die 1 "Encrypted password file \"$1\" doesn't exist"
	fi
	if ! [[ -r "$1" ]]; then
		die 1 "Encrypted password file \"$1\" doesn't have read permissions"
	fi
}

chk_file_accessible "$TEMP_USERS_PASS_DIR/root"
printf '%s:%s' 'root' "$(cat $TEMP_USERS_PASS_DIR/root)" | chpasswd -e
if [[ "$CONT_USER" != 'root' ]]; then
	useradd -ms /bin/bash -u "$CONT_USER_UID" "$CONT_USER"
	usermod -aG "$CONT_USER_GROUPS" "$CONT_USER"
	chk_file_accessible "$TEMP_USERS_PASS_DIR/$CONT_USER"
	printf '%s:%s' "$CONT_USER" "$(cat $TEMP_USERS_PASS_DIR/$CONT_USER)" | chpasswd -e
else
	usermod -aG "$CONT_USER_GROUPS" "root"
fi