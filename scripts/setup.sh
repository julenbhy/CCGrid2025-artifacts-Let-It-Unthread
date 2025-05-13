#!/usr/bin/env bash
set -ex

ARCH=$(uname -m)
INSTALL_DIR="/opt"
WASI_VERSION="25"
WASMTIME_VERSION="16.0.0"
IWASM_VERSION="2.1.2"
WASMER_VERSION="4.2.3"

echo "Detected architecture: $ARCH"

install_rust_and_deps() {
    echo "Installing Rust and build dependencies..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    sudo apt update
    sudo apt install -y build-essential cmake m4 multitime
}

install_wasi_sdk() {
    case "$ARCH" in
        x86_64)
            echo "Installing wasi-sdk for x86_64..."
            SDK_TAR="wasi-sdk-${WASI_VERSION}.0-x86_64-linux.tar.gz"
            ;;
        aarch64)
            echo "Installing wasi-sdk for aarch64..."
            SDK_TAR="wasi-sdk-${WASI_VERSION}.0-arm64-linux.tar.gz"
            ;;
        *)
            echo "Unsupported architecture for wasi-sdk: $ARCH"
            exit 1
            ;;
    esac
    curl -sL "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_VERSION}/${SDK_TAR}" | sudo tar -xz -C "$INSTALL_DIR"
    sudo mv "$INSTALL_DIR/wasi-sdk-${WASI_VERSION}.0"* "$INSTALL_DIR/wasi-sdk"
}

install_musl_cross() {
    case "$ARCH" in
        x86_64)
            echo "Installing musl-cross for x86_64..."
            MUSL_TAR="x86_64-linux-musl-cross.tgz"
            ;;
        aarch64)
            echo "Installing musl-cross for aarch64..."
            MUSL_TAR="aarch64-linux-musl-cross.tgz"
            ;;
        *)
            echo "Unsupported architecture for musl-cross: $ARCH"
            exit 1
            ;;
    esac
    curl -sL "https://musl.cc/${MUSL_TAR}" | sudo tar -xz -C "$INSTALL_DIR"
    if [ "$ARCH" == "x86_64" ]; then
        sudo ln -sf "$INSTALL_DIR/aarch64-linux-musl-cross/aarch64-linux-musl/lib/libc.so" /lib/ld-musl-aarch64.so.1
    fi
}

install_wasmtime() {
    case "$ARCH" in
        x86_64)
            echo "Installing wasmtime for x86_64..."
            TARBALL="wasmtime-v${WASMTIME_VERSION}-x86_64-linux.tar.xz"
            ;;
        aarch64)
            echo "Installing wasmtime for aarch64..."
            TARBALL="wasmtime-v${WASMTIME_VERSION}-aarch64-linux.tar.xz"
            ;;
        *)
            echo "Unsupported architecture for wasmtime: $ARCH"
            exit 1
            ;;
    esac
curl -sL "https://github.com/bytecodealliance/wasmtime/releases/download/v${WASMTIME_VERSION}/${TARBALL}" | sudo tar -xJ -C "$INSTALL_DIR"
}

install_iwasm() {
    sudo mkdir -p "$INSTALL_DIR/iwasm-${IWASM_VERSION}"
    case "$ARCH" in
        x86_64)
            echo "Installing iwasm (WAMR) for x86_64..."
            IWASM_TAR="iwasm-${IWASM_VERSION}-x86_64-ubuntu-22.04.tar.gz"
            curl -sL "https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-${IWASM_VERSION}/${IWASM_TAR}" | sudo tar -xz -C "$INSTALL_DIR/iwasm-${IWASM_VERSION}"
            ;;
        aarch64)
            echo "Compiling iwasm (WAMR) for aarch64..."
            curl -sL "https://github.com/bytecodealliance/wasm-micro-runtime/archive/refs/tags/WAMR-${IWASM_VERSION}.tar.gz" | tar -xz
	    cd wasm-micro-runtime-WAMR-${IWASM_VERSION}/product-mini/platforms/linux
	    mkdir build && cd build
	    cmake .. -DWAMR_BUILD_TARGET=AARCH64
	    make
	    cp iwasm "$INSTALL_DIR/iwasm-${IWASM_VERSION}"
	    #cd ../../../ | rm -rf wasm-micro-runtime-WAMR-${IWASM_VERSION}
            ;;
        *)
            echo "Unsupported architecture for iwasm: $ARCH"
            exit 1
            ;;
    esac
    
}

install_wasmer() {
    sudo mkdir -p "$INSTALL_DIR/wasmer-${WASMER_VERSION}"
    case "$ARCH" in
        x86_64)
            echo "Installing wasmer for x86_64..."
            WASMER_TAR="wasmer-linux-amd64.tar.gz"
            ;;
        aarch64)
            echo "Installing wasmer for aarch64..."
            WASMER_TAR="wasmer-linux-aarch64.tar.gz"
            ;;
        *)
            echo "Unsupported architecture for wasmer: $ARCH"
            exit 1
            ;;
    esac
    curl -sL "https://github.com/wasmerio/wasmer/releases/download/v${WASMER_VERSION}/${WASMER_TAR}" | sudo tar -xz -C "$INSTALL_DIR/wasmer-${WASMER_VERSION}"
}

main() {
	install_rust_and_deps
	install_wasi_sdk
	install_musl_cross
	install_wasmtime
	install_iwasm
	install_wasmer
	echo "Installation complete."
}

main
