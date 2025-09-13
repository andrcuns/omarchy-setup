#!/usr/bin/env bash

function log() {
  echo -e "\033[1;35m$1\033[0m"
}

function success() {
  echo -e "\033[1;32m$1\033[0m"
}

if [ -n "$1" ]; then
  dotfiles_repo="$1"
fi

log "*** Installing essential software ***"
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
log "*** Setting firefox as default browser ***"
xdg-settings set default-web-browser firefox.desktop
success "done!"

echo ""
log "*** Remove fcitx5 input handler ***"
echo "Removing packages..."
sudo pacman -Rns --noconfirm fcitx5 fcitx5-gtk fcitx5-qt 2>/dev/null || success "done!"
echo "Removing config files..."
sudo rm -rf /etc/xdg/autostart/org.fcitx.Fcitx5.desktop
rm -rf ~/.config/fcitx5 ~/config/fcitx ~/.config/environment.d/fcitx.conf
success "done!"

if [ -n "$dotfiles_repo" ]; then
	echo ""
	log "*** Initializing chezmoi with repo: $dotfiles_repo ***"
	echo ""
	chezmoi init "$dotfiles_repo"
	success "done!"
fi

echo ""
log "*** Running Ansible Playbook ***"
ansible-playbook playbook.yml
