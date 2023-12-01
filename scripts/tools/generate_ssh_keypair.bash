#!/bin/bash
set -e

source ${BASH_SOURCE[0]%/*}/../libs/lib_baremetal_compat.bash
baremetal_compat_setup

source "$CDE_HOST_SCRIPTS_DIR/libs/lib_msg.bash"

# Generate keypair
keypair="$CDE_HOST_SSH_DIR/$CDE_HOST_SSH_KEYPAIR_NAME"
if ! [ -r "$keypair.pub" ]; then
	ssh-keygen -o -t ed25519 -N '' -f "$keypair" || \
	die 1 "Something went wrong while generating ssh keypair $keypair"
else
	msg "Skipping keypair generation, already present in $CDE_HOST_SSH_KEYPAIR_NAME.pub"
fi

# Generate .ssh config
msg "Remember to update your ~/.ssh/config"
printf '===============================\n'
cat <<EOF
Host $CDE_HOST_SSH_KEYPAIR_NAME
	HostName $CDE_CONT_IP
	Port $CDE_CONT_SSH_PORT
	User $CDE_CONT_USER
EOF
printf '===============================\n'
