#!/bin/bash

REINSTALL_FLAG=false

if [ "$1" = "--reinstall" ] || [ "$2" = "--reinstall" ]; then
	REINSTALL_FLAG=true
fi

INSTALL_DIR=$HOME/Downloads/zft

# Repository Cloning

REPO_URL=https://github.com/Caesarovich/zft

if [ "$REINSTALL_FLAG" = true ]; then
	echo "Reinstallation flag detected. Removing existing directory $INSTALL_DIR..."
	rm -rf "$INSTALL_DIR"
fi

if [ -d "$INSTALL_DIR" ]; then
	echo "Directory $INSTALL_DIR already exists. Skipping clone."
else
	read -p "This will clone the repository to $INSTALL_DIR. Do you want to continue? (y/n): " choice
	if [ "$REINSTALL_FLAG" = false ] && [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
		echo "Installation aborted."
		exit 1
	fi

	echo "Cloning repository from $REPO_URL to $INSTALL_DIR..."
	git clone $REPO_URL $INSTALL_DIR
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
	echo "Downloading Zig version $ZIG_VERSION for $ZIG_PLATFORM-$ZIG_ARCH..."
	curl -L $ZIG_URL -o $ZIG_TAR

	echo "Zig downloaded to $ZIG_TAR."
	echo "Extracting Zig..."
	tar -xf $ZIG_TAR -C $INSTALL_DIR
	echo "Zig extracted to $ZIG_EXTRACT_DEST."
	echo "Zig binary located at $ZIG_BIN."
else
	echo "Zig archive already exists at $ZIG_TAR. Skipping download."
fi

echo "Testing Zig installation..."
$ZIG_BIN version

# Create alias
SHELL_CONFIG="$HOME/.bashrc"
ALIAS_CMD="alias zft='bash $INSTALL_DIR/run.sh'"

if grep -Fxq "$ALIAS_CMD" $SHELL_CONFIG && [ "$REINSTALL_FLAG" = false ]; then
	echo "Alias already exists in $SHELL_CONFIG. Skipping alias creation."
else
	echo "Creating alias in $SHELL_CONFIG... (Works only for bash shell)"
	echo "" >> $SHELL_CONFIG
	echo "# Alias for ZFT tool" >> $SHELL_CONFIG
	echo "$ALIAS_CMD" >> $SHELL_CONFIG
	echo "Alias added. Please run 'source $SHELL_CONFIG' or restart your terminal to use the 'zft' command."
fi