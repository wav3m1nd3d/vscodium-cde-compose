#!/bin/bash
set -e

codium_path=''
for codium_path in "$HOME/.vscodium-server/bin/"*"/bin/codium-server"; do
	[[ -x "$entry" ]] && break
done

# Install VSCodium extensions from marketplace
for ext in $CONT_CODIUM_EXTS; do
	"$codium_path" --install-extansion $CONT_CODIUM_EXTS
done

# Install VSCodium extensions from .vsix
for entry in "$TEMP_CODIUM_EXTS_DIR/"*".vsix"; do
	if [[ -f "$entry" ]]; then
		"$codium_path" --install-extension "$entry"
	fi
done