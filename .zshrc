# =====================================================================
# PATHS
# =====================================================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# =====================================================================
# OH MY ZSH SETUP
# =====================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="bira"

plugins=(
  git
  docker
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# =====================================================================
# HISTORY / EDITOR
# =====================================================================
HIST_STAMPS="mm/dd/yyyy"
export EDITOR="nvim"

# =====================================================================
# ENVIRONMENT VARIABLES
# =====================================================================
# Networking shortcuts
export MOM_PC="192.168.0.11"
export HOMELAB="192.168.0.34"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$HOME/go/bin"

# Python (virtualenvwrapper)
export WORKON_HOME="$HOME/.venvs"
export VIRTUAL_ENV_DISABLE_PROMPT=1

# =====================================================================
# NVM (Node Version Manager)
# =====================================================================
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Extra NVM init (Arch package)
[[ -s "/usr/share/nvm/init-nvm.sh" ]] && source "/usr/share/nvm/init-nvm.sh"

# =====================================================================
# ORACLE CLI AUTO-COMPLETE
# =====================================================================
if [[ -e "$HOME/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh" ]]; then
  source "$HOME/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh"
fi
