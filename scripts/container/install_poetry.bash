#!/bin/bash

set -e
source "$TEMP_SCRIPTS_DIR/libs/lib_pyenv_python_ver_cache.bash"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYTHON_BUILD_BUILD_PATH="$CONT_PYTHON_BUILD_BUILD_PATH"
export PYTHON_BUILD_CACHE_PATH="$CONT_PYTHON_BUILD_CACHE_PATH"
install_python_ver "$CONT_POETRY_PYTHON_VERS"
pyenv global "$CONT_POETRY_PYTHON_VERS"


# Install poetry
poetry_pip="$(pyenv which pip)"
"$poetry_pip" install -U pip setuptools
"$poetry_pip" install poetry


# Configure poetry
poetry_venv="$(pyenv which poetry)"
poetry_venv="${poetry_venv%/*}"
echo 'export PATH="$PATH:'"$poetry_venv\"" >> ~/.bashrc
"$(pyenv which poetry)" completions bash >> ~/.bash_completion