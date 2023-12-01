#!/bin/bash
set -e
usermod -p '' root
if [[ "$CONT_USER" != 'root' ]]; then
	useradd -s /bin/bash -G "$CONT_USER_GROUPS" -u "$CONT_USER_UID" "$CONT_USER"
	usermod -p '' "$CONT_USER"
else
	usermod -aG "$CONT_USER_GROUPS" "$CONT_USER"
fi