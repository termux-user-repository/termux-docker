#!/usr/bin/env bash

set -e

OCI="docker"
OCI_ARG=""
case $1 in
	-p|--podman) OCI="podman" ; OCI_ARG="--format docker" ;;
esac

if [ -n "${TERMUX_DOCKER_USE_SUDO-}" ]; then
	SUDO="sudo"
else
	SUDO=""
fi

case "$(uname -m)" in
	aarch64) SYSTEM_TYPE="arm"; ARCHITECTURES=("aarch64" "arm");;
	armv7l|armv8l) SYSTEM_TYPE="arm"; ARCHITECTURES=("arm");;
	i686) SYSTEM_TYPE="x86"; ARCHITECTURES=("i686");;
	x86_64) SYSTEM_TYPE="x86"; ARCHITECTURES=("i686" "x86_64");;
	*)
		echo "'uname -m' returned unknown architecture"
		exit 1
		;;
esac

for arch in "${ARCHITECTURES[@]}"; do
	$SUDO $OCI build \
		${OCI_ARG} \
		-t 'ghcr.io/termux-user-repository/termux-docker:'"$arch" \
		-f Dockerfile \
		--build-arg BOOTSTRAP_ARCH="$arch" \
		--build-arg SYSTEM_TYPE="$SYSTEM_TYPE" \
		.
	if [ "${1-}" = "publish" ]; then
		$SUDO $OCI push 'ghcr.io/termux-user-repository/termux-docker:'"$arch"
	fi
done

if [ "$SYSTEM_TYPE" = "x86" ]; then
	$SUDO $OCI tag ghcr.io/termux-user-repository/termux-docker:i686 ghcr.io/termux-user-repository/termux-docker:latest
	if [ "${1-}" = "publish" ]; then
		$SUDO $OCI push 'tghcr.io/termux-user-repository/termux-docker:latest'
	fi
fi
