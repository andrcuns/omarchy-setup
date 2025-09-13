# OMARCHY SETUP

omarchy-setup is a small project using ansible to update some of the defaults for a default [Omarchy](https://omarchy.org/) installation.

## Usage

[install.sh](install.sh) is base script that installs all of the software and it's configurations.

### dotfiles

Dotfiles management by [chezmoi](https://www.chezmoi.io/) is supported. Dotfiles repository path is set via `DOTFILES_REPO` environment variable. It can also be passed as an argument to `install.sh` script.
