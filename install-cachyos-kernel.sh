#!/usr/bin/env bash

set -e

# CachyOs kernel which fixes issues with lags after long suspends happening on omarchy kernel

# Download and extract the installer
curl -o /tmp/cachyos-repo.tar.xz https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf /tmp/cachyos-repo.tar.xz -C /tmp && cd /tmp/cachyos-repo

# Run the automated installer
sudo env OMARCHY_ALLOW_DIRECT_PACMAN=1 ./cachyos-repo.sh

# Install the kernel
sudo pacman -S linux-cachyos
