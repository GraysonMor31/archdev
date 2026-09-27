#!/usr/bin/env bash
set -euo pipefail

# Set locale to en_US.UTF-8
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Set systemd recommendations for WSL

# systemd recommendations for WSL — avoid systemd-resolved fighting WSL's
# own DNS handling.
# https://learn.microsoft.com/windows/wsl/build-custom-distro#systemd-recommendations
PROBLEM_UNITS=(
    systemd-resolved.service
    systemd-networkd.service
    NetworkManager.service
    systemd-tmpfiles-setup.service
    systemd-tmpfiles-clean.service
    systemd-tmpfiles-clean.timer
    systemd-tmpfiles-setup-dev-early.service
    systemd-tmpfiles-setup-dev.service
    tmp.mount
)
for unit in "${PROBLEM_UNITS[@]}"; do
    systemctl mask "$unit" || true
    systemctl --global mask "$unit" || true
done

# Let the wheel group use sudo (the wheel line ships commented out by default)
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Default root's shell to zsh too, for consistency if anyone runs `wsl -u root`
chsh -s /usr/bin/zsh root
