#!/usr/bin/env bash

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

log "*** Installing essential software ***"
echo ""
sudo pacman -Sy --needed --noconfirm \
  ansible \
  chezmoi \
  diff-so-fancy \
  direnv \
  firefox \
  kitty \
  kubectx \
  mkcert \
  ncdu \
  pass \
  visual-studio-code-bin \
  zsh \
  k9s \
  ttf-fira-code \
  yubikey-manager \
  gnome-keyring \
  gcr-4

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
sed -i '/^exec-once = uwsm app -- fcitx5$/d' ~/.local/share/omarchy/default/hypr/autostart.conf
success "done!"

echo ""
log "*** Running Ansible Playbook ***"
ansible-playbook playbook.yml

if [ -n "$dotfiles_repo" ]; then
  echo ""
  log "*** Initializing chezmoi with repo: $dotfiles_repo ***"
  echo ""
  chezmoi init "$dotfiles_repo" --apply ${dotfiles_branch:+--branch "$dotfiles_branch"}
  success "done!"
fi
