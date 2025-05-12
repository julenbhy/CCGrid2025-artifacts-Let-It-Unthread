#!/usr/bin/env bash
set -e

ARCH=$(uname -m)
INSTALL_DIR="/opt"
WASI_VERSION="25.0"
WASMTIME_VERSION="16.0.0"
IWASM_VERSION="1.3.1"
WASMER_VERSION="4.2.3"

echo "Detected architecture: $ARCH"

install_wasi_sdk() {
    echo "Installing wasi-sdk..."
    case "$ARCH" in
        x86_64)
            SDK_TAR="wasi-sdk-${WASI_VERSION}-x86_64-linux.tar.gz"
            ;;
        aarch64)
            SDK_TAR="wasi-sdk-${WASI_VERSION}-aarch64-linux.tar.gz"
            ;;
        *)
            echo "Unsupported architecture for wasi-sdk: $ARCH"
            exit 1
            ;;
    esac
    curl -sL "[https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_VERSION}/${SDK_TAR}](https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_VERSION}/${SDK_TAR})" | sudo tar -xz -C "$INSTALL_DIR"
    sudo mv "$INSTALL_DIR/wasi-sdk-${WASI_VERSION}"* "$INSTALL_DIR/wasi-sdk"
}

install_musl_cross() {
    echo "Installing musl-cross..."
    case "$ARCH" in
        x86_64)
            MUSL_TAR="x86_64-linux-musl-cross.tgz"
            ;;
        aarch64)
            MUSL_TAR="aarch64-linux-musl-cross.tgz"
            ;;
        *)
            echo "Unsupported architecture for musl-cross: $ARCH"
            exit 1
            ;;
    esac
    curl -sL "[https://musl.cc/${MUSL_TAR}](https://musl.cc/${MUSL_TAR})" | sudo tar -xz -C "$INSTALL_DIR"
    if [ "$ARCH" == "x86_64" ]; then
        sudo ln -sf "$INSTALL_DIR/x86_64-linux-musl-cross/x86_64-linux-musl/lib/libc.so" /lib/ld-musl-x86_64.so.1
    fi
}

install_wasmtime() {
    echo "Installing wasmtime..."
    case "$ARCH" in
        x86_64)
            TARBALL="wasmtime-v${WASMTIME_VERSION}-x86_64-linux.tar.xz"
            ;;
        aarch64)
            TARBALL="wasmtime-v${WASMTIME_VERSION}-aarch64-linux.tar.xz"
            ;;
        *)
            echo "Unsupported architecture for wasmtime: $ARCH"
            exit 1
            ;;
    esac
curl -sL "[https://github.com/bytecodealliance/wasmtime/releases/download/v${WASMTIME_VERSION}/${TARBALL}](https://github.com/bytecodealliance/wasmtime/releases/download/v${WASMTIME_VERSION}/${TARBALL})" | sudo tar -xJ -C "$INSTALL_DIR"
}

install_iwasm() {
    echo "Installing iwasm (WAMR)..."
    sudo mkdir -p "$INSTALL_DIR/iwasm-${IWASM_VERSION}"
    case "$ARCH" in
        x86_64)
            IWASM_TAR="iwasm-${IWASM_VERSION}-x86_64-ubuntu-22.04.tar.gz"
            ;;
        aarch64)
            IWASM_TAR="iwasm-${IWASM_VERSION}-aarch64-ubuntu-22.04.tar.gz"
            ;;
        *)
            echo "Unsupported architecture for iwasm: $ARCH"
            exit 1
            ;;
    esac
    curl -sL "[https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-${IWASM_VERSION}/${IWASM_TAR}](https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-${IWASM_VERSION}/${IWASM_TAR})" | sudo tar -xz -C "$INSTALL_DIR/iwasm-${IWASM_VERSION}"
}

install_wasmer() {
    echo "Installing wasmer..."
    sudo mkdir -p "$INSTALL_DIR/wasmer-${WASMER_VERSION}"
    case "$ARCH" in
        x86_64)
            WASMER_TAR="wasmer-linux-amd64.tar.gz"
            ;;
        aarch64)
            WASMER_TAR="wasmer-linux-aarch64.tar.gz"
            ;;
        *)
            echo "Unsupported architecture for wasmer: $ARCH"
            exit 1
            ;;
    esac
    curl -sL "[https://github.com/wasmerio/wasmer/releases/download/v${WASMER_VERSION}/${WASMER_TAR}](https://github.com/wasmerio/wasmer/releases/download/v${WASMER_VERSION}/${WASMER_TAR})" | sudo tar -xz -C "$INSTALL_DIR/wasmer-${WASMER_VERSION}"
}

install_rust_and_deps() {
    echo "Installing Rust and build dependencies..."
    curl --proto '=https' --tlsv1.2 -sSf [https://sh.rustup.rs](https://sh.rustup.rs) | sh -s -- -y
    sudo apt update
    sudo apt install -y build-essential cmake m4 multitime
}

main() {
install_wasi_sdk
install_musl_cross
install_wasmtime
install_iwasm
install_wasmer
install_rust_and_deps
echo "Installation complete."
}

main
