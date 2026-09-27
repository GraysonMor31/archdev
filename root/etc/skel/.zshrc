# ArchDev default zsh config
# --- locale ---
# Belt-and-suspenders: /etc/locale.conf is set at image build time, but if
# systemd is off (an OOBE choice) nothing may source it into the session.
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
# --- asdf ---
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.local/share/asdf}"
export PATH="${ASDF_DATA_DIR}/shims:$PATH"

# --- plugins ---
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# --- prompt ---
eval "$(starship init zsh)"

# --- history ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# --- completion ---
autoload -Uz compinit && compinit
