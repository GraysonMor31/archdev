#!/usr/bin/env bash
set -euo pipefail

ask_yn() {
    # $1 = prompt, $2 = default (y/n)
    local prompt="$1" default="$2" reply
    if [[ "$default" == "y" ]]; then
        read -rp "$prompt [Y/n]: " reply
        reply="${reply:-y}"
    else
        read -rp "$prompt [y/N]: " reply
        reply="${reply:-n}"
    fi
    [[ "$reply" =~ ^[Yy]$ ]]
}

echo "======================================"
echo " Welcome to ArchDev — Arch Linux for WSL"
echo "======================================"
echo
echo "A few questions about how this instance should behave."
echo "(These map straight to /etc/wsl.conf — you can hand-edit it anytime after.)"
echo

# --- systemd ---
if ask_yn "Enable systemd (needed for Docker Engine, most services)?" y; then
    SYSTEMD=true
else
    SYSTEMD=false
fi

# --- DNS ---
if ask_yn "Manage DNS yourself instead of using Windows' resolver?" n; then
    read -rp "Enter nameserver IP(s), space-separated: " -a nameservers
    GEN_RESOLV=false
else
    GEN_RESOLV=true
fi

# --- interop ---
if ask_yn "Enable Windows interoperability (run .exe files from WSL)?" y; then
    INTEROP=true
    if ask_yn "Also append Windows PATH into your Linux PATH?" y; then
        APPEND_PATH=true
    else
        APPEND_PATH=false
    fi
else
    INTEROP=false
    APPEND_PATH=false
fi

# --- automount ---
if ask_yn "Auto-mount Windows drives (C:, D:, etc.) under /mnt?" y; then
    AUTOMOUNT=true
else
    AUTOMOUNT=false
fi

echo
echo "==> Writing /etc/wsl.conf"

{
    echo "[boot]"
    echo "systemd=${SYSTEMD}"
    echo
    echo "[interop]"
    echo "enabled=${INTEROP}"
    echo "appendWindowsPath=${APPEND_PATH}"
    echo
    echo "[automount]"
    echo "enabled=${AUTOMOUNT}"
    if [[ "$AUTOMOUNT" == "true" ]]; then
        echo 'options="metadata"'
    fi
    echo
    echo "[network]"
    echo "generateResolvConf=${GEN_RESOLV}"
} > /etc/wsl.conf

if [[ "$GEN_RESOLV" == "false" ]]; then
    : > /etc/resolv.conf
    for ns in "${nameservers[@]}"; do
        echo "nameserver $ns" >> /etc/resolv.conf
    done
fi

echo
echo "NOTE: wsl.conf is only read when this WSL instance boots, so none of"
echo "the above is live yet in this session. Once setup finishes, from"
echo "PowerShell/Windows Terminal (not in here) run:"
echo "  wsl --terminate ArchDev"
echo "then reopen it to pick the settings up."
echo

# --- user creation ---
read -rp "Enter a username: " username

useradd -m -G wheel -s /usr/bin/zsh "$username"
passwd "$username"

echo
echo "asdf-vm is already installed. Want to bootstrap any language runtimes now?"
echo "  1) Node.js"
echo "  2) Python"
echo "  3) Go"
echo "  4) Ruby"
echo "  5) Rust"
echo
read -rp "Enter numbers separated by spaces, or press enter to skip: " -a choices

declare -A plugin_map=(
    [1]=nodejs
    [2]=python
    [3]=golang
    [4]=ruby
    [5]=rust
)

for choice in "${choices[@]}"; do
    plugin="${plugin_map[$choice]:-}"
    if [[ -n "$plugin" ]]; then
        echo "==> Setting up $plugin via asdf"
        su - "$username" -c "asdf plugin add $plugin" || true
        su - "$username" -c "asdf install $plugin latest" || true
        su - "$username" -c "asdf global $plugin latest" || true
    fi
done

echo
echo "All set. Opening your shell..."
exit 0
