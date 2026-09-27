FROM archlinux:base

# --- Base tooling + shell stack ---
RUN pacman -Syu --noconfirm --needed \
        base-devel git sudo openssh curl unzip jq \
        zsh zsh-autosuggestions zsh-syntax-highlighting starship \
    && pacman -Scc --noconfirm

# --- asdf-vm ---
# No official pacman package (AUR-only), and AUR/makepkg wants a non-root
# builder user, which complicates a Docker image build. Pull the prebuilt
# Go binary from GitHub releases instead — always grabs whatever is
# currently latest, so this stays current on every scheduled rebuild.
RUN ASDF_VERSION=$(curl -sL https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name') \
    && curl -sL "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-amd64.tar.gz" -o /tmp/asdf.tar.gz \
    && tar -xzf /tmp/asdf.tar.gz -C /usr/local/bin \
    && rm /tmp/asdf.tar.gz \
    && chmod +x /usr/local/bin/asdf

# --- WSL configuration + OOBE + default shell config ---
# https://learn.microsoft.com/windows/wsl/build-custom-distro
COPY --chown=root:root --chmod=0644 root/etc/wsl.conf /etc/wsl.conf
COPY --chown=root:root --chmod=0644 root/etc/wsl-distribution.conf /etc/wsl-distribution.conf
COPY --chown=root:root --chmod=0755 root/etc/oobe.sh /etc/oobe.sh
COPY --chown=root:root --chmod=0644 root/etc/skel/.zshrc /etc/skel/.zshrc

# --- System-level tweaks (systemd, sudoers, default shell) ---
COPY configure.sh /tmp/configure.sh
RUN chmod +x /tmp/configure.sh && /tmp/configure.sh && rm /tmp/configure.sh
