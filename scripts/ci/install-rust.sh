#!/usr/bin/env bash
set -eo pipefail

declare -r RUSTUP=${HOME}/.cargo/bin/rustup

function install_linux_target () {
    case $(dpkg --print-architecture) in
        amd64)
            ${RUSTUP} target add x86_64-unknown-linux-musl
            ;;
        arm64)
            ${RUSTUP} target add aarch64-unknown-linux-musl
            ;;
        *)
            >&2 echo Error: unknown arch $(dpkg --print-architecture)
            exit 1
            ;;
    esac
}

function install_windows_target () {
    ${RUSTUP} target add x86_64-pc-windows-gnu

    # Cargo's built-in support for fetching dependencies from GitHub requires
    # an ssh agent to be set up, which doesn't work on Circle's Windows executors.
    # See https://github.com/rust-lang/cargo/issues/1851#issuecomment-450130685
    cat <<EOF > ~/.cargo/config
[net]
git-fetch-with-cli = true
EOF
}

function main () {
    curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
    ${RUSTUP} --version

    case $(uname) in
        Linux)
            install_linux_target
            ;;
        Darwin)
            ;;
        MSYS_NT*)
            install_windows_target
            ;;
        *)
            >&2 echo Error: unknown OS $(uname)
            exit 1
            ;;
    esac

    ${RUSTUP} target list --installed
}

main ${@}