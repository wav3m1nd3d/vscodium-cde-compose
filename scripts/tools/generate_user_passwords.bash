#!/bin/bash
set -e

source ${BASH_SOURCE[0]%/*}/../libs/lib_baremetal_compat.bash
baremetal_compat_setup

source "$CDE_HOST_SCRIPTS_DIR/libs/lib_msg.bash"
 
ask_pass() {
	local -n passwd_ref=$1
	local user=$2
	local -i fail_cnt=0
	while true; do
		msgn "Enter new password for $user: "
		read -s passwd_ref;
		printf '\n'
		msgn "Verify password for $user: "
		read -s passwd_v;
		printf '\n'
		[[ "$passwd_ref" == "$passwd_v" ]] && break
		fail_cnt+=1
		if [[ fail_cnt -ge 3 ]]; then
			die 1 "Too many tries, aborting"
		fi
		err "Passwords don't match, please retry"
	done

}

setup_enc_pass() {
	local passwd=''
	local user="$1"
	ask_pass 'passwd' "$user"
	printf '%s\n' "$passwd" | mkpasswd -sm sha512crypt > "$CDE_HOST_USERS_PASS_DIR/$user"
}

setup_root_enc_pass() {
	local -i fail_cnt=0
	while true; do
		msgn "Set random root password (deny passowrd access)? [y/n]: "
		read -n 1 lock_root_input
		printf '\n'
		case "$lock_root_input" in
			[Yy])
				cat /dev/urandom | tr -cd A-Za-z0-9 | head -c 43 | mkpasswd -sm sha512crypt > "$CDE_HOST_USERS_PASS_DIR/root"
				break
				;;
			[Nn])
				setup_enc_pass 'root'
				break
				;;
			*)
				fail_cnt+=1
				if [[ fail_cnt -ge 3 ]]; then
					die 1 "Too many tries, aborting"
				fi
				err "No such option, please retry"
				;;
		esac
	done
}

# Generate encrypted password
passwd=""
if [[ "$CDE_CONT_USER" != 'root' ]]; then
	if ! [[ -e "$CDE_HOST_USERS_PASS_DIR/$CDE_CONT_USER" ]]; then
		setup_enc_pass "$CDE_CONT_USER"
	else 
		msg "Skipping password generation for $CDE_CONT_USER, \"$CDE_HOST_USERS_PASS_DIR/$CDE_CONT_USER\" file already present"
	fi
fi
if ! [[ -e "$CDE_HOST_USERS_PASS_DIR/root" ]]; then
	setup_root_enc_pass
else
	msg "Skipping password generation for root, \"$CDE_HOST_USERS_PASS_DIR/root\" file already present"
fi