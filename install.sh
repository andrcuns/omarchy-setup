#!/usr/bin/env bash

if [ -n "$1" ]; then
  export DOTFILES_REPO="$1"
fi

echo "*** Installing essential software ***"
echo ""
sudo pacman -S --needed --noconfirm \
	ansible \
	chezmoi \
	diff-so-fancy \
	direnv \
	eza \
	firefox \
	github-cli \
	git \
	kitty \
	kubectx \
	mkcert \
	ncdu \
	pass \
	visual-studio-code-bin \
	zsh \
	zoxide \
	k9s \
  ttf-fira-code

echo ""
echo "*** Running Ansible Playbook ***"
ansible-playbook playbook.yml
