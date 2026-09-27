# ArchDev WSL (placeholder name — rename me)

An Arch Linux WSL distribution for developers: zsh + starship by default,
asdf-vm preinstalled with a first-run choice of language plugins, and a
proper native WSL OOBE (no compiled launcher app needed) — built on top of
the official `archlinux:base` image so it stays current with upstream Arch
on every rebuild.

## How it's built

- `Dockerfile` — installs zsh/starship/asdf on top of `archlinux:base` and
  drops in the WSL config files
- `configure.sh` — system-level tweaks (systemd, sudoers, default shell),
  run once during the image build
- `root/etc/wsl.conf`, `root/etc/wsl-distribution.conf`, `root/etc/oobe.sh`
  — WSL's native OOBE mechanism
  (see https://learn.microsoft.com/windows/wsl/build-custom-distro).
  `root/etc/wsl.conf` is only the **first-boot default** (systemd/interop/
  automount all on, Windows-generated DNS) — `oobe.sh` asks the user the
  same questions (systemd on/off, custom DNS vs Windows resolver, Windows
  interop on/off, automount on/off) and overwrites `/etc/wsl.conf` with
  their answers. Because wsl.conf is only read when the WSL instance
  boots, those answers don't apply to the session oobe.sh is running in —
  oobe.sh tells the user to `wsl --terminate <name>` and reopen once it's
  done.
- `root/etc/skel/.zshrc` — default shell config every new user gets
- `build.sh` — builds the image, exports it, packages it as a `.wsl` file
- `.github/workflows/build.yml` — runs `build.sh` on a weekly schedule (and
  on manual dispatch / pushes to main) and publishes the `.wsl` as a
  GitHub Release

## Building locally

Requires Docker and `fakeroot`.

```bash
./build.sh
```

Produces `archdev.wsl` in the repo root. On WSL 2.4.4+, double-click it in
File Explorer to install, or `wsl --install --from-file archdev.wsl`.

## Still open

- Rename everything from the `archdev` placeholder
- Icon + custom Windows Terminal color scheme
  (`[shortcut] icon = ...` / `[windowsterminal] ProfileTemplate = ...`
  in `wsl-distribution.conf`)
- AUR helper (yay/paru) — needs a non-root build stage inside the
  Dockerfile, deferred for now
- Pacman mirrorlist tuning for WSL/Windows-host network paths
- Confirm exact package names at first build (`zsh-autosuggestions`,
  `zsh-syntax-highlighting`, `starship` are in Arch `extra` as of writing,
  but pacman will fail loudly and obviously if that's changed)
