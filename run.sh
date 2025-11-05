#!/bin/bash

ZFT_PATH=$(realpath "$(dirname "$0")")
ZIG_VERSION=0.15.2
ZIG_ARCH=$(uname -m)
ZIG_PLATFORM=$(uname | tr '[:upper:]' '[:lower:]')
ZIG_BIN="$ZFT_PATH/zig-$ZIG_ARCH-$ZIG_PLATFORM-$ZIG_VERSION/zig"

WORK_DIR="$PWD"
VALGRIND_FLAG=false
BONUS_FLAG=false


for arg in "$@"; do
	if [ "$arg" = "--valgrind" ]; then
		VALGRIND_FLAG=true
		break
	fi

	if [ "$arg" = "--bonus" ]; then
		BONUS_FLAG=true
		continue
	fi
	
	# If not a flag, assume it's the working directory
	WORK_DIR="$(realpath "$arg")"
done

# Build the project
cd "$ZFT_PATH" || { echo "Failed to change directory to $ZFT_PATH"; exit 1; }
RELATIVE_WORK_DIR=$(realpath --relative-to="$ZFT_PATH" "$WORK_DIR")

BUILD_FLAGS="-Dlibft-path=$RELATIVE_WORK_DIR -Dbonus=$BONUS_FLAG"

if [ "$VALGRIND_FLAG" = true ]; then
	BUILD_FLAGS="$BUILD_FLAGS -Duse-llvm=true"
fi

$ZIG_BIN build $BUILD_FLAGS

# If build failed, exit
if [ $? -ne 0 ]; then
	echo "Build failed."
	exit 1
fi


# Run the project
if [ "$VALGRIND_FLAG" = true ]; then
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes "$ZFT_PATH/zig-out/bin/zft"
else
	"$ZFT_PATH/zig-out/bin/zft"
fi