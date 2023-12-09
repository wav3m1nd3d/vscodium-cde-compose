#!/bin/bash

set -e

SCRIPT_NAME="${BASH_SOURCE##*/}"
source "$TEMP_SCRIPTS_DIR/libs/lib_msg.bash"
source "$TEMP_SCRIPTS_DIR/libs/lib_apply_conf.bash"

# Configure Locales
apply_conf "$CONT_USER" 'locale.gen' '/etc/locale.gen'
apply_conf "$CONT_USER" 'locale.conf' '/etc/locale.conf'
locale-gen