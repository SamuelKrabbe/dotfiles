# ----------------------------------------
# Load global definitions
# ----------------------------------------
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ----------------------------------------
# PATH adjustments
# ----------------------------------------
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# ----------------------------------------
# Early exit for non-interactive shells
# ----------------------------------------
[[ $- != *i* ]] && return

# ----------------------------------------
# Aliases
# ----------------------------------------
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# ----------------------------------------
# Prompt
# ----------------------------------------
PS1='[\u@\h \W]\$ '

# ----------------------------------------
# Load user-specific configs
# ----------------------------------------
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        [ -f "$rc" ] && . "$rc"
    done
fi
unset rc
