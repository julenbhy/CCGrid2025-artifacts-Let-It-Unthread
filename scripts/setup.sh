#!/usr/bin/env bash
set -euxo pipefail

# Cargar variables de entorno
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/env.sh"

echo "Setting up for architecture: $ARCH"

install_rust_and_deps() {
    if command -v rustc &>/dev/null; then
        echo "Rust already installed ($(rustc --version))"
        return
    fi
    echo "Installing Rust and build dependencies..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    sudo apt update
    sudo apt install -y build-essential cmake m4 multitime
}

install_wasi_sdk() {
    if [ -d "$WASI_SDK" ]; then
        echo "wasi-sdk already installed at $WASI_SDK"
        return
    fi
    case "$ARCH" in
        x86_64) SDK_TAR="wasi-sdk-${WASI_VERSION}.0-x86_64-linux.tar.gz" ;;
        aarch64) SDK_TAR="wasi-sdk-${WASI_VERSION}.0-arm64-linux.tar.gz" ;;
        *) echo "Unsupported architecture for wasi-sdk: $ARCH"; exit 1 ;;
    esac
    TMP_DIR=$(mktemp -d)
    curl -sL "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_VERSION}/${SDK_TAR}" \
        | tar -xz -C "$TMP_DIR"
    sudo rm -rf "$WASI_SDK"
    sudo mv "$TMP_DIR"/wasi-sdk-* "$WASI_SDK"
    rm -rf "$TMP_DIR"
    echo "wasi-sdk installed at $WASI_SDK"
}

install_musl() {
    if [ -d "$MUSL" ]; then
        echo "musl already installed at $MUSL"
        return
    fi
    case "$ARCH" in
        x86_64) MUSL_TAR="x86_64-linux-musl-native.tgz" ;;
        aarch64) MUSL_TAR="aarch64-linux-musl-native.tgz" ;;
        *) echo "Unsupported architecture for musl: $ARCH"; exit 1 ;;
    esac
    TMP_DIR=$(mktemp -d)
    curl -sL "https://musl.cc/${MUSL_TAR}" | tar -xz -C "$TMP_DIR"
    sudo rm -rf "$MUSL"
    sudo mv "$TMP_DIR"/* "$MUSL"
    rm -rf "$TMP_DIR"

    # Generate symlink for the dynamic loader
    case "$ARCH" in
        x86_64)
            sudo ln -sf "$MUSL/lib/libc.so" /lib/ld-musl-x86_64.so.1
            ;;
        aarch64)
            sudo ln -sf "$MUSL/lib/libc.so" /lib/ld-musl-aarch64.so.1
            ;;
    esac

    echo "musl installed at $MUSL"
}

install_wasmtime() {
    if [ -x "$WASMTIME" ]; then
        echo "wasmtime already installed at $WASMTIME"
        $WASMTIME --version
        return
    fi
    case "$ARCH" in
        x86_64) TARBALL="wasmtime-v${WASMTIME_VERSION}-x86_64-linux.tar.xz" ;;
        aarch64) TARBALL="wasmtime-v${WASMTIME_VERSION}-aarch64-linux.tar.xz" ;;
        *) echo "Unsupported architecture for wasmtime: $ARCH"; exit 1 ;;
    esac
    TMP_DIR=$(mktemp -d)
    curl -sL "https://github.com/bytecodealliance/wasmtime/releases/download/v${WASMTIME_VERSION}/${TARBALL}" \
        | tar -xJ -C "$TMP_DIR"
    sudo rm -rf "$(dirname "$WASMTIME")"
    sudo mv "$TMP_DIR"/wasmtime-v${WASMTIME_VERSION}-* "$(dirname "$WASMTIME")"
    rm -rf "$TMP_DIR"
    $WASMTIME --version
}

install_iwasm() {
    if [ -x "$IWASM" ]; then
        echo "iwasm already installed at $IWASM"
        $IWASM --version || true
        return
    fi
    sudo rm -rf "$(dirname "$IWASM")"
    sudo mkdir -p "$(dirname "$IWASM")"
    case "$ARCH" in
        x86_64)
            IWASM_TAR="iwasm-${IWASM_VERSION}-x86_64-ubuntu-22.04.tar.gz"
            curl -sL "https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-${IWASM_VERSION}/${IWASM_TAR}" \
                | sudo tar -xz -C "$(dirname "$IWASM")"
            ;;
        aarch64)
            curl -sL "https://github.com/bytecodealliance/wasm-micro-runtime/archive/refs/tags/WAMR-${IWASM_VERSION}.tar.gz" \
                | tar -xz
            cd wasm-micro-runtime-WAMR-${IWASM_VERSION}/product-mini/platforms/linux
            mkdir build && cd build
            cmake .. -DWAMR_BUILD_TARGET=AARCH64
            make
            sudo cp iwasm "$IWASM"
            cd "$SCRIPT_DIR"
            rm -rf wasm-micro-runtime-WAMR-${IWASM_VERSION}
            ;;
        *) echo "Unsupported architecture for iwasm: $ARCH"; exit 1 ;;
    esac
    $IWASM --version || true
}

install_wasmer() {
    if [ -x "$WASMER" ]; then
        echo "wasmer already installed at $WASMER"
        $WASMER --version
        return
    fi
    case "$ARCH" in
        x86_64) WASMER_TAR="wasmer-linux-amd64.tar.gz" ;;
        aarch64) WASMER_TAR="wasmer-linux-aarch64.tar.gz" ;;
        *) echo "Unsupported architecture for wasmer: $ARCH"; exit 1 ;;
    esac
    TMP_DIR=$(mktemp -d)
    curl -sL "https://github.com/wasmerio/wasmer/releases/download/v${WASMER_VERSION}/${WASMER_TAR}" \
        | tar -xz -C "$TMP_DIR"

    sudo rm -rf "/opt/wasmer-${WASMER_VERSION}"
    sudo mv "$TMP_DIR" "/opt/wasmer-${WASMER_VERSION}"

    $WASMER --version
}

main() {
    local targets=("$@")
    if [ ${#targets[@]} -eq 0 ]; then
        targets=(rust wasi musl wasmtime iwasm wasmer)
    fi

    for target in "${targets[@]}"; do
        case "$target" in
            rust) install_rust_and_deps ;;
            wasi) install_wasi_sdk ;;
            musl) install_musl ;;
            wasmtime) install_wasmtime ;;
            iwasm) install_iwasm ;;
            wasmer) install_wasmer ;;
            *) echo "Unknown target: $target"; exit 1 ;;
        esac
    done

    echo "Installation complete."
}

main "$@"



# ADD:
#numpy
#curl