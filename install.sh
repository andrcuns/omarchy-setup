#!/usr/bin/env bash

set -e

function log() {
  echo -e "\033[1;35m$1\033[0m"
}

function success() {
  echo -e "\033[1;32m$1\033[0m"
}

if [ -n "$1" ]; then
  dotfiles_repo="$1"
  dotfiles_branch="$2"
fi

log "*** Install ansible ***"
omarchy-pkg-add ansible
success "done!"

echo ""
log "*** Running Ansible Playbook ***"
ansible-playbook playbook.yml --ask-become-pass --skip-tags neovim
success "done!"

echo ""
log "*** Install additional aur packages ***"
yay -S docker-sbx-bin
success "done!"

if [ -n "$dotfiles_repo" ]; then
  echo ""
  log "*** Initializing chezmoi with repo: $dotfiles_repo ***"
  echo ""
  chezmoi init "$dotfiles_repo" --apply ${dotfiles_branch:+--branch "$dotfiles_branch"}
  success "done!"
fi
