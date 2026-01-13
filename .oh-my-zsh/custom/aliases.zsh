#!/usr/bin/env zsh

alias docker-init="~/.oh-my-zsh/custom/scripts/docker_init.zsh"

alias lzd="lazydocker"
alias lzg="lazygit"
alias vim="nvim"
alias n="nvim"
alias minecraft="minecraft-launcher"
alias moms-desktop="ssh moms-desktop"
alias memento="memento-Dei"
alias homelab="ssh homelab"
alias update-dotfiles="~/dotfiles/scripts/update-dotfiles.sh"
alias imgcliphist="~/dotfiles/scripts/imgcliphist.sh"
alias screenshot="~/dotfiles/scripts/screenshot.sh"
alias notify-mom="~/dotfiles/scripts/notify-mom.sh"
alias system-maintenance="~/dotfiles/scripts/system-maintenance.sh"
alias check-moms-pc="~/dotfiles/scripts/check-moms-pc.sh"
alias celar="clear"

unalias ls 2>/dev/null
ls() {
  if command -v eza >/dev/null 2>&1; then
    command eza -l "$@"
  else
    command ls -l -- "$@"
  fi
}

zzed() {
  exec command zed "$@"
}

zed() {
  exec command zed "$@"
}
