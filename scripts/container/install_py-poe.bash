#!/bin/bash

set -e

# Install pyenv
curl https://pyenv.run | bash

# Configure pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc


# Install poetry
curl -sSL https://install.python-poetry.org | python3 -

echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
$HOME/.local/bin/poetry completions bash >> ~/.bash_completion
