#!/bin/bash

# Header
echo "======================================"
echo "     📀 ZFT Installation Script        "
echo "======================================"
echo ""

# Title in blue
TITLE="\e[34m[ZFT]\e[0m"

# COLORS
BOLD="\e[1m"
UNDERLINE="\e[4m"
RESET="\e[0m"
DIM="\e[2m"

# Spinner function
spinner()
{
    local pid=$!
    local delay=0.15
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}


REINSTALL_FLAG=false

if [ "$1" = "--reinstall" ] || [ "$2" = "--reinstall" ]; then
	REINSTALL_FLAG=true
fi

INSTALL_DIR=$HOME/Downloads/zft

# Repository Cloning

REPO_URL=https://github.com/Caesarovich/zft


if [ "$REINSTALL_FLAG" = true ]; then
	echo -e "${DIM}Reinstallation flag detected. ${BOLD}Removing${RESET}${DIM} existing directory ${BOLD}${INSTALL_DIR}${RESET}..."
	echo -e "${RESET}"
	rm -rf "$INSTALL_DIR"
fi

if [ -d "$INSTALL_DIR" ]; then
	echo -e "${DIM}Directory ${BOLD}${INSTALL_DIR}${RESET}${DIM} already exists. Skipping clone.${RESET}"
else
	exec 8<&1
	read -u 8 -p "This will clone the repository to $INSTALL_DIR. Do you want to continue? (y/n): " choice
	exec 8<&-

	if [ "$REINSTALL_FLAG" = false ] && [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
		echo "Installation aborted."
		exit 1
	fi

	echo -e "$TITLE Cloning repository from$BOLD $REPO_URL$RESET to$BOLD $INSTALL_DIR$RESET..."
	git clone $REPO_URL $INSTALL_DIR  2>/dev/null & spinner
fi

# Download Zig

ZIG_VERSION=0.15.2
ZIG_ARCH=$(uname -m)
ZIG_PLATFORM=$(uname | tr '[:upper:]' '[:lower:]')
ZIG_URL="https://ziglang.org/download/$ZIG_VERSION/zig-$ZIG_ARCH-$ZIG_PLATFORM-$ZIG_VERSION.tar.xz"
ZIG_TAR="$INSTALL_DIR/zig.tar.xz"
ZIG_EXTRACT_DEST="$INSTALL_DIR/zig-$ZIG_ARCH-$ZIG_PLATFORM-$ZIG_VERSION"
ZIG_BIN="$ZIG_EXTRACT_DEST/zig"

if [ ! -f "$ZIG_TAR" ]; then
	echo -e "$TITLE 📥 Downloading Zig version $ZIG_VERSION for $ZIG_PLATFORM-$ZIG_ARCH..."
	curl -L $ZIG_URL -o $ZIG_TAR 2>/dev/null & spinner

	echo -e "$TITLE 📦 Zig downloaded to$BOLD $ZIG_TAR$RESET"
	echo -e "$TITLE 📤 Extracting Zig..."
	tar -xf $ZIG_TAR -C $INSTALL_DIR 2>/dev/null & spinner
	echo -e "$TITLE ⚡ Zig extracted to$BOLD $ZIG_EXTRACT_DEST$RESET."
else
	echo -e "${DIM}Zig archive already exists at $ZIG_TAR. Skipping download.${RESET}"
fi

echo ""
echo -e "🔌 ${DIM}Testing Zig installation..."
$ZIG_BIN version
echo -e "${RESET}"

# Create bash alias
BASHRC_PATH="$HOME/.bashrc"
ALIAS_CMD="alias zft='bash $INSTALL_DIR/run.sh'"

if grep -Fxq "$ALIAS_CMD" $BASHRC_PATH && [ "$REINSTALL_FLAG" = false ]; then
	echo -e "${DIM}Alias already exists in $BASHRC_PATH. Skipping alias creation.${RESET}"
else
	echo -e "$TITLE 🏷️  Creating alias in $BASHRC_PATH..."
	echo "" >> $BASHRC_PATH
	echo "# Alias for ZFT tool" >> $BASHRC_PATH
	echo "$ALIAS_CMD" >> $BASHRC_PATH
fi

# Create zsh alias
ZSHRC_PATH="$HOME/.zshrc"
if grep -Fxq "$ALIAS_CMD" $ZSHRC_PATH && [ "$REINSTALL_FLAG" = false ]; then
	echo -e "${DIM}Alias already exists in $ZSHRC_PATH. Skipping alias creation.${RESET}"
else
	echo -e "$TITLE 🏷️  Creating alias in $ZSHRC_PATH..."
	echo "" >> $ZSHRC_PATH
	echo "# Alias for ZFT tool" >> $ZSHRC_PATH
	echo "$ALIAS_CMD" >> $ZSHRC_PATH
fi

# Create fish alias
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_CONFIG_PATH="$FISH_CONFIG_DIR/config.fish"
FISH_ALIAS_CMD="alias zft 'bash $INSTALL_DIR/run.sh'"

if grep -Fxq "$FISH_ALIAS_CMD" $FISH_CONFIG_PATH && [ "$REINSTALL_FLAG" = false ]; then
	echo -e "${DIM}Alias already exists in $FISH_CONFIG_PATH. Skipping alias creation.${RESET}"
else
	echo -e "$TITLE 🏷️  Creating alias in $FISH_CONFIG_PATH..."
	mkdir -p $FISH_CONFIG_DIR
	echo "" >> $FISH_CONFIG_PATH
	echo "# Alias for ZFT tool" >> $FISH_CONFIG_PATH
	echo "$FISH_ALIAS_CMD" >> $FISH_CONFIG_PATH
fi

echo ""
echo "======================================"
echo "   ✨ ZFT Installation Completed ✨"
echo "======================================"
echo ""
echo -e "To start using ZFT, please ${BOLD}restart your terminal${RESET} or run the following command to ${BOLD}reload your shell configuration${RESET}:"
echo ""
echo -e "For bash:  ${BOLD}source $BASHRC_PATH${RESET}"
echo -e "For zsh :  ${BOLD}source $ZSHRC_PATH${RESET}"
echo -e "For fish:  ${BOLD}source $FISH_CONFIG_PATH${RESET}"
echo ""
echo -e "➡️  Then you can run ZFT using the command: ${UNDERLINE}zft${RESET}"
echo ""