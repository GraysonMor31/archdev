#!/usr/bin/env bash
set -euo pipefail

# systemd recommendations for WSL — avoid systemd-resolved fighting WSL's
# own DNS handling.
# https://learn.microsoft.com/windows/wsl/build-custom-distro#systemd-recommendations
systemctl mask systemd-resolved.service || true

# Let the wheel group use sudo (the wheel line ships commented out by default)
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Default root's shell to zsh too, for consistency if anyone runs `wsl -u root`
chsh -s /usr/bin/zsh root
