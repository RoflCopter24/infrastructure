#!/bin/bash -e

# The command all other commands are executed with
# Will be set to 'sudo' if the script is not executed with root
userCommand=""
repoDir=$(pwd)
nerdFontsTempPath="$HOME/.cache/nerdfonts"
basePackages=(
    "apt-transport-https"
    "build-essential"
    "ca-certificates"
    "conntrack"
    "curl"
    "git"
    "gnupg-agent"
    "htop"
    "mc"
    "nano"
    "neovim"
    "openssh-server"
    "p7zip-full"
    "software-properties-common"
    "unzip"
    "vim"
    "wget"
    "zip"
)
shellPackages=(
    "zsh"
    "zsh-syntax-highlighting"
    "shellcheck"
)
nerdFonts=(
    "JetBrainsMono"
    "Meslo"
    "CascadiaCode"
    "FiraCode"
    "UbuntuMono"
)
goPackages=(
    "golang-1.14"
)
nodePackages=(
    "gcc"
    "g++"
    "make"
    "cmake"
    "nodejs"
    "yarn"
)
phpPackages=(
    "php7.4-bz2"
    "php7.4-cli"
    "php7.4-curl"
    "php7.4-fpm"
    "php7.4-gd"
    "php7.4-intl"
    "php7.4-json"
    "php7.4-mbstring"
    "php7.4-mysql"
    "php7.4-odbc"
    "php7.4-pgsql"
    "php7.4-phpdbg"
    "php7.4-xml"
    "php7.4-zip"
)

if [ "$(whoami)" != "root" ]; then
    userCommand="sudo"
fi

function installPackages() {
    echo "Installing: ${1}"
    $userCommand apt install "${1}" --yes
}

function copyRepoFile() {
    if [[ -f "$2" ]]; then
        echo "ERROR: File/Path already exists. Skipping!"
        return
    fi
    echo "Copying file to user dir: ${1} to ${2}"
    cp "${repoDir}/${1}" "${2}"
}

function copyRepoUserFile() {
    if [[ -f "${HOME}/$2" ]]; then
        echo "!!! ERROR: File already exists. Skipping!"
        return
    fi
    echo "Copying file to user dir: ${1} to ${2}"
    cp "${repoDir}/${1}" "${HOME}/${2}"
}

function installNerdfont() {
    fontFiles=("${2}" "${3}")
    echo "Downloading NerdFont ${1}"
    if [ ! -d "$nerdFontsTempPath" ]; then
        mkdir -p "$nerdFontsTempPath"
    fi
    cd "$nerdFontsTempPath"

    if wget -O "${nerdFontsTempPath}/${1}.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${1}.zip"; then
        echo "!!! Download of NerdFont ${1} failed"
        return
    fi

    echo "Download of ${1} completed. Unpacking..."

    if unzip -o "${nerdFontsTempPath}/${1}.zip" "${fontFiles[@]}" -d "${nerdFontsTempPath}/${1}"; then
        echo "!!! Extraction of ${1}.zip failed!"
        return
    fi

    echo "Installing font to /usr/share/fonts"
    cd "${nerdFontsTempPath}/${1}"
    if $userCommand cp "${fontFiles[@]}" "/usr/share/fonts/"; then
        echo "!!! Installation of ${fontFiles[*]} failed!"
        cd "${repoDir}"
        return
    fi
    cd "${repoDir}"

    echo "NerdFont ${1} installed"
}

function copyScripts() {
    scripts=(./scripts/* ./scripts/**/*)

    for script in "${scripts[@]}"; do
        if [ -d "$script" ]; then
            echo "$script is a directory. Skipping."
            continue
        fi

        echo "Copying script ${script}"
        $userCommand cp "${script}" "/usr/local/bin/"
        $userCommand chmod +x /usr/local/bin/*.sh
    done
}

echo "Ubuntu Workstation Installation Script v0.5"
echo "  written by Florian Vick <florian@florian-vick.de>"
echo "==================================================="
echo ""

echo "=> Updating package cache..."
$userCommand apt update
echo " "

echo "=> Upgrading system..."
$userCommand apt full-upgrade
echo " "

echo "=> Installing basic packages..."
installPackages "${basePackages[@]}"
echo " "

echo "=> Installing shell things like zsh..."
installPackages "${shellPackages[@]}"
echo " "

echo "=> Copying .zshrc ..."
copyRepoUserFile "workstation-setup/.zshrc" ".zshrc"
echo " "

echo "=> Launching oh-my-zsh installer..."
# launch oh-my-zsh installer
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo " "

echo "=> Acquiring NerdFonts..."
installNerdfont "JetBrainsMono" "JetBrains Mono Regular Nerd Font Complete.ttf" "JetBrains Mono Italic Nerd Font Complete.ttf"
echo " "
installNerdfont "CascadiaCode" "Caskaydia Cove Nerd Font Complete.ttf"
echo " "
installNerdfont "Meslo" "Meslo LG S Regular Nerd Font Complete.ttf"
echo " "
installNerdfont "Fira Code" "Fira Code Retina Nerd Font Complete.otf"
echo " "
installNerdfont "UbuntuMono" "Ubuntu Mono Nerd Font Complete.ttf"
echo " "

echo "=> Updating FontCache after font installation..."
fc-cache -f -v
echo " "

echo "=> Removing temporary font path..."
rm -rf "$nerdFontsTempPath"
echo " "

echo "=> Copying utility scripts to /usr/local/bin..."
copyScripts
echo " "

echo "=> Copying powerlevel10k settings file..."
copyRepoUserFile "workstation-setup/.p10k.zsh" ".p10k.zsh"
echo " "

echo "=> Installing ZSH-Theme 'romkatv/powerlevel10k'..."
zsh -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k'
echo " "

echo "=> Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $userCommand apt-key add -
$userCommand add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$userCommand apt update
installPackages "docker-ce docker-ce-cli containerd.io" --yes
$userCommand adduser "$(whoami)" "docker"
echo "/\\ You need to log out and back in if you want to user the 'docker' command with your user!"
echo " "

echo "=> Installing nodejs and yarn..."
curl -sL https://deb.nodesource.com/setup_12.x | $userCommand -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | $userCommand apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | $userCommand tee /etc/apt/sources.list.d/yarn.list
$userCommand apt update
installPackages "${nodePackages[@]}"
echo " "

echo "=> Installing Go packages"
installPackages "${goPackages[@]}"
echo " "

echo "=> Installing Rust toolchain"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash
echo " "

echo "?= Do you want to install a native PHP version (and not use docker for it)? (y/n)"
usePhp=$(read -r -N 1)
if [[ "$usePhp" == "y" ]]; then
    echo "=> Installing PHP..."
    $userCommand add-apt-repository "ppa:ondrej/php"
    $userCommand apt update
    $userCommand apt upgrade --yes
    installPackages "${phpPackages[@]}"
    $userCommand phpenmod bz2 json intl mbstring odbc mysql pgsql zip xml gd iconv dom
    $userCommand systemctl enable php7.4-fpm
fi
echo " "

echo "?= Do you want to install the Caddy webserver locally?"
useCaddy=$(read -r -N 1)
if [[ "$useCaddy" == "y" ]]; then
    echo "=> Installing Caddy webserver..."
    echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | $userCommand tee -a /etc/apt/sources.list.d/caddy-fury.list
    $userCommand apt update
    installPackages "caddy"
    $userCommand systemctl enable caddy

    echo "=> Caddy has been installed. The config is in /etc/caddy/Caddyfile".
    echo "=> For more info visit https://caddyserver.com/docs/quick-starts/caddyfile"
fi
echo " "

echo "=> Done. Everything is good to go!"
