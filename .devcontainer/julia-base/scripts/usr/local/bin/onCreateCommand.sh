#!/usr/bin/env bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

mkdir -p "${HOME}/.julia/config"
mkdir -p "${HOME}/.local/bin"
mkdir -p "${HOME}/projects"

# Copy scripts from skeleton directory if home directory is bind mounted
if [ ! -f "${HOME}/.local/bin/dockerSystemPrune.sh" ]; then
  cp /etc/skel/.local/bin/dockerSystemPrune.sh "${HOME}/.local/bin";
fi
if [ ! -f "${HOME}/.local/bin/checkForUpdates.sh" ]; then
  cp /etc/skel/.local/bin/checkForUpdates.sh "${HOME}/.local/bin";
fi

# Copy user-specific startup files if home directory is bind mounted
if [ ! -f ".julia/config/startup_ijulia.jl" ]; then
  cp -a /etc/skel/.julia/config/startup_ijulia.jl \
    "${HOME}/.julia/config"
fi
if [ ! -f ".julia/config/startup.jl" ]; then
  cp -a /etc/skel/.julia/config/startup.jl \
    "${HOME}/.julia/config"
fi

# Copy Bash-related files from root's backup directory
if [ "$(id -un)" == "root" ]; then
  if [ ! -f /root/.bashrc ]; then
    cp /var/backups/root/.bashrc /root;
  fi
  if [ ! -f /root/.profile ]; then
    cp /var/backups/root/.profile /root;
  fi
fi

# Copy Zsh-related files and folders from the untouched home directory
if [ "$(id -un)" == "root" ]; then
  if [ ! -d /root/.oh-my-zsh ]; then
    cp -R /home/*/.oh-my-zsh /root;
  fi
  if [ ! -f /root/.zshrc ]; then
    cp /home/*/.zshrc /root;
  fi
else
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    sudo cp -R /root/.oh-my-zsh "${HOME}";
    sudo chown -R "$(id -u)":"$(id -g)" "${HOME}/.oh-my-zsh";
  fi
  if [ ! -f "${HOME}/.zshrc" ]; then
    sudo cp /root/.zshrc "${HOME}";
    sudo chown "$(id -u)":"$(id -g)" "${HOME}/.zshrc";
  fi
fi

# Set PATH so it includes user's private bin if it exists
if ! $(grep -q "user's private bin" $HOME/.zshrc); then
  echo -e "\n# set PATH so it includes user's private bin if it exists\nif [ -d \"\$HOME/bin\" ] && [[ \"\$PATH\" != *\"\$HOME/bin\"* ]] ; then\n    PATH=\"\$HOME/bin:\$PATH\"\nfi" >> ${HOME}/.zshrc;
  echo -e "\n# set PATH so it includes user's private bin if it exists\nif [ -d \"\$HOME/.local/bin\" ] && [[ \"\$PATH\" != *\"\$HOME/.local/bin\"* ]] ; then\n    PATH=\"\$HOME/.local/bin:\$PATH\"\nfi" >> ${HOME}/.zshrc;
fi

# Remove old .zcompdump files
rm -f ${HOME}/.zcompdump*
