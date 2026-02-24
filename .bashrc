# ----------------------------------------
# Load global definitions
# ----------------------------------------
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ----------------------------------------
# PATH adjustments
# ----------------------------------------
CUSTOM_PATHS="$HOME/.local/share/nvm/v25.6.1/bin:$HOME/.local/opt/lua-lsp/bin:$HOME/.luarocks/lib/luarocks/rocks-5.1/lua-language-server/3.15.0-1/bin:$HOME/.luarocks/bin:$HOME/go/bin:$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/bin"

# Only prepend if not already in PATH
if ! [[ "$PATH" =~ "$CUSTOM_PATHS" ]]; then
    PATH="$CUSTOM_PATHS:$PATH"
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

eval "$(starship init bash)"
