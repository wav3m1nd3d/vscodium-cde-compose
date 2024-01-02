get_cached_python_ver() {
	local -n file_ref="$1"
	py_ver=$2
	if [[ -f "$CONT_PYENV_VERSIONS_DIR/${py_ver}.tar.gz" ]]; then
		file_ref="$CONT_PYENV_VERSIONS_DIR/${py_ver}.tar.gz"
		return 0
	fi
	return 1
}

install_python_ver() {
	py_ver=$1
	py_ver=$(pyenv latest -k "$py_ver")
	file=''
	if ! [[ -d "$PYENV_ROOT/versions/$py_ver" ]]; then
		if get_cached_python_ver 'file' "$py_ver"; then
			tar -xaf "$file" -C "$PYENV_ROOT/versions"
		else
			pyenv install -k "$py_ver"
			tar -caf "$CONT_PYENV_VERSIONS_DIR/${py_ver}.tar.gz" -C "$PYENV_ROOT/versions" "$py_ver"
		fi
	fi
}