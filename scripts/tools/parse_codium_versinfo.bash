#!/bin/bash
set -e

source ${BASH_SOURCE[0]%/*}/../libs/lib_baremetal_compat.bash
baremetal_compat_setup

source "$CDE_HOST_SCRIPTS_DIR/libs/lib_msg.bash"

versinfo=($(jq '.version,.commit,.quality,.release' $CDE_HOST_CACHE_DIR/product.json))

echo -n "\
DISTRO_VERSION=${versinfo[0]}
DISTRO_COMMIT=${versinfo[1]}
DISTRO_QUALITY=${versinfo[2]}
DISTRO_VSCODIUM_RELEASE=${versinfo[3]}
" > $CDE_HOST_CACHE_DIR/lib_product.bash
msg 'Done parsing'