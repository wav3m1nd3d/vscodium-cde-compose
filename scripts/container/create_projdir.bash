#!/bin/bash
set -e
mkdir -p "$CONT_PROJ_DIR"
if [[ "$CONT_USER" != 'root' ]]; then
	chown "$CONT_USER:$CONT_USER" "$CONT_PROJ_DIR"
fi