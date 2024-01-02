#!/bin/bash

set -e

SCRIPT_NAME="${BASH_SOURCE##*/}"
source "$TEMP_SCRIPTS_DIR/libs/lib_msg.bash"
source "$TEMP_SCRIPTS_DIR/libs/lib_pyenv_python_ver_cache.bash"


# Install pyenv
curl https://pyenv.run | bash


# Configure pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYTHON_BUILD_BUILD_PATH="$CONT_PYTHON_BUILD_BUILD_PATH"
export PYTHON_BUILD_CACHE_PATH="$CONT_PYTHON_BUILD_CACHE_PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


# Install pyenv-managed python
if [[ -n "$CONT_PYTHON_VERS" ]]; then
	if [[ -f "$TEMP_PYTHON_VERS_FILE_DIR/.python-version" ]]; then
		msg 'Overriding .python-version with CONT_PYTHON_VERS' >&2
	fi
	for py_ver in $CONT_PYTHON_VERS; do
		install_python_ver "$py_ver"
	done
elif [[ -f "$TEMP_PYTHON_VERS_FILE_DIR/.python-version" ]]; then
	for py_ver in $(cat $TEMP_PYTHON_VERS_FILE_DIR/.python-version); do
		install_python_ver "$py_ver"
	done
else
	die 1 '$HOST_PYTHON_VERS_FILE_DIR/.python-version should exist or CONT_PYTHON_VERS should be set'
fi

if [[ -z "$CONT_POETRY_PYTHON_VERS" ]]; then
	die 1 'CONT_POETRY_PYTHON_VERS should be set'
fi