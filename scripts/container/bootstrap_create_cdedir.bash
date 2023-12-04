#!/bin/bash
set -e
mkdir -p "$CONT_CDE_DIR"
if [[ "$CONT_USER" != 'root' ]]; then
	chown "$CONT_USER:$CONT_USER" "$CONT_CDE_DIR"
fi