#!/bin/bash

set -ouex pipefail

mkdir -p $(realpath /root)
mkdir -p $(realpath /opt)
mkdir -p $(realpath /usr/local)

dnf5 -y copr enable scottames/ghostty
dnf5 install -yq ghostty

# Node
dnf5 install -yq npm
npm config --global set prefix "/usr"

# Cargo binstall
wget -q https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-gnu.tgz
tar -xf cargo-binstall-x86_64-unknown-linux-gnu.tgz
rm cargo-binstall-x86_64-unknown-linux-gnu.tgz

# Dotnet
dnf5 install -yq dotnet-sdk-9.0 dotnet-sdk-8.0 aspnetcore-runtime-9.0 azure-cli
DOTNET_CLI_HOME=/usr/lib/dotnet
mkdir -p "$DOTNET_CLI_HOME"
dotnet tool install --tool-path /usr/bin csharpier
npm i -gq --prefix /usr azure-functions-core-tools
wget -q -qO- https://aka.ms/install-artifacts-credprovider.sh | bash
 
# csharp
wget -q https://github.com/SofusA/csharp-language-server/releases/latest/download/csharp-language-server-x86_64-unknown-linux-gnu.zip
unzip -qq csharp-language-server-x86_64-unknown-linux-gnu.zip
mv csharp-language-server /usr/bin
rm csharp-language-server-x86_64-unknown-linux-gnu.zip 
mkdir -p /usr/lib/csharp-language-server
csharp-language-server --download --directory /usr/lib/csharp-language-server

# vscode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf5 install -yq code

# powershell
curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
mkdir -p /opt/microsoft/powershell/7/
mkdir -p /usr/local/share/man/man1/
dnf5 install -yq powershell
rm /usr/bin/pwsh
mv /opt/microsoft/powershell /usr/lib
ln -s /usr/lib/powershell/7/pwsh /usr/bin/pwsh

# Language servers
npm i -gq --prefix /usr prettier @tailwindcss/language-server vscode-langservers-extracted typescript-language-server typescript
npm i -gq --prefix /usr @angular/cli @angular/language-service typescript @angular/language-server
wget -q $(curl -s https://api.github.com/repos/tekumara/typos-lsp/releases/latest | jq -r '.assets[] | select(.name | test(".*x86_64-unknown-linux-gnu")).browser_download_url')
# wget -q https://github.com/tekumara/typos-lsp/releases/download/v0.1.40/typos-lsp-v0.1.40-x86_64-unknown-linux-gnu.tar.gz
tar -xf typos-lsp*tar.gz
mv typos-lsp /usr/bin
rm typos-lsp*tar.gz
./cargo-binstall -yq --root /usr leptosfmt

## Bicep language server
wget -q https://github.com/Azure/bicep/releases/latest/download/bicep-langserver.zip
unzip -qq bicep-langserver.zip -d /usr/lib/bicep-langserver
echo -e "#!/usr/bin/env bash\nexec dotnet /usr/lib/bicep-langserver/Bicep.LangServer.dll" > /usr/bin/bicep-langserver
chmod +x /usr/bin/bicep-langserver
rm bicep-langserver.zip

# Shell
dnf5 install -yq zoxide atuin fd-find ripgrep skim
./cargo-binstall -yq --root /usr caseify sd eza
dnf5 -y copr enable lihaohong/yazi
dnf5 -yq install yazi
dnf5 -yq install cowsay kitty
dnf5 -yq install sudo-rs uutils-coreutils
 
# Git
dnf5 -y copr enable vdanielmo/git-credential-manager
dnf5 install -yq git-credential-manager
dnf5 install -yq gh meld
./cargo-binstall -yq --root /usr --strategies crate-meta-data jj-cli

# Helix
wget -q https://github.com/SofusA/helix-driver/releases/latest/download/helix.zip
unzip -qq helix.zip
export HELIX_DEFAULT_RUNTIME=/usr/lib/helix/runtime
mkdir -p $HELIX_DEFAULT_RUNTIME
mv runtime $/usr/lib/helix
mv target/opt/hx /usr/bin/hx
rm helix.zip

# Desktop
dnf5 -y copr enable yalter/niri-git
dnf5 install -yq niri wl-clipboard swayidle mako

# Rust
dnf5 install -yq rustup

# Qobuz player
dnf5 install -yq rust-glib-sys-devel rust-gstreamer-devel rust-alsa-sys-devel # Qobuz player dependencies
wget -q https://github.com/SofusA/qobuz-player/releases/latest/download/qobuz-player-x86_64-unknown-linux-gnu.tar.gz
tar -xf qobuz-player-x86_64-unknown-linux-gnu.tar.gz
mv qobuz-player /usr/bin
rm qobuz-player-x86_64-unknown-linux-gnu.tar.gz
 
# color-scheme
wget -q https://github.com/SofusA/color-scheme/releases/latest/download/color-scheme-x86_64-unknown-linux-gnu.zip
unzip -qq color-scheme-x86_64-unknown-linux-gnu.zip
mv color-scheme /usr/bin
rm color-scheme-x86_64-unknown-linux-gnu.zip
 
# Playwright dependencies
dnf5 install -yq libjpeg-turbo libwebp libffi libicu

systemctl enable podman.socket
