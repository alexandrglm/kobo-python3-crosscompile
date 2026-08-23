#!/bin/bash

# =============================================================================
# build-libs.sh - Cross-compiles 7 libraries for Kobo Python 3.11.16
#
# Required libraries:
#   OpenSSL 1.1.1w, zlib 1.3.1, bzip2 1.0.8, libffi 3.4.6,
#   libuuid (util-linux 2.40.2), lzma (xz-utils 5.6.2), sqlite3 3.46.0
#
# Requires: crosstool-NG toolchain already built
# See: DOCS/01-toolchain-setup.md
#
# Idempotent: re-running skips downloads if tarballs exist,
# but re-configures/re-builds each library every run.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# User Configuration - Edit these paths
# -----------------------------------------------------------------------------

# Base working directory (where libraries will be built and installed)
BASE="${BASE:-/home/dev/Desktop/ClaraColour/python/crosstoolsng}"

# Path to crosstool-NG toolchain binaries
TOOLCHAIN_BIN="${TOOLCHAIN_BIN:-${HOME}/x-tools/arm-unknown-linux-gnueabihf/bin}"

# -----------------------------------------------------------------------------
# Script starts here - do not edit below unless you know what you're doing
# -----------------------------------------------------------------------------

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo "============================================================"
    echo -e "${BLUE}$1${NC}"
    echo "============================================================"
    echo ""
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
    exit 1
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# -----------------------------------------------------------------------------
# Validate paths
# -----------------------------------------------------------------------------

print_header "Checking configuration..."

# Check if BASE is set and exists
if [ -z "$BASE" ]; then
    print_error "BASE is not set. Please set it before running:\n  export BASE=/path/to/your/workdir"
fi

if [ ! -d "$BASE" ]; then
    print_info "BASE directory does not exist. Creating: $BASE"
    mkdir -p "$BASE"
fi
print_success "BASE: $BASE"

# Check if toolchain exists
if [ ! -d "$TOOLCHAIN_BIN" ]; then
    print_error "Toolchain not found at: $TOOLCHAIN_BIN\nPlease verify the path or set TOOLCHAIN_BIN."
fi

# Verify the toolchain is functional
if ! command -v "${TOOLCHAIN_BIN}/arm-unknown-linux-gnueabihf-gcc" &> /dev/null; then
    print_error "arm-unknown-linux-gnueabihf-gcc not found in $TOOLCHAIN_BIN"
fi
print_success "Toolchain: $TOOLCHAIN_BIN"

# Verify toolchain version
GCC_VERSION=$("${TOOLCHAIN_BIN}/arm-unknown-linux-gnueabihf-gcc" --version 2>&1 | head -1)
print_success "GCC: $GCC_VERSION"

# -----------------------------------------------------------------------------
# Set environment
# -----------------------------------------------------------------------------

cd "$BASE"

export PATH="${TOOLCHAIN_BIN}:${PATH}"
export CC=arm-unknown-linux-gnueabihf-gcc
export CXX=arm-unknown-linux-gnueabihf-g++
export AR=arm-unknown-linux-gnueabihf-ar
export RANLIB=arm-unknown-linux-gnueabihf-ranlib

# -----------------------------------------------------------------------------
# Helper function
# -----------------------------------------------------------------------------

fetch() {
    local url="$1"
    local file
    file="$(basename "$url")"
    if [ ! -f "$file" ]; then
        print_info "Downloading: $file"
        wget -q --show-progress "$url"
        print_success "Downloaded: $file"
    else
        print_info "Already downloaded: $file"
    fi
}

# -----------------------------------------------------------------------------
# Build each library
# -----------------------------------------------------------------------------

print_header "Building 7 libraries for Python 3.11.16 (ARMv7)"

# -----------------------------------------------------------------------------
# [1/7] zlib 1.3.1
# -----------------------------------------------------------------------------
print_header "[1/7] zlib 1.3.1"
fetch "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz"
tar xzf zlib-1.3.1.tar.gz
(
    cd zlib-1.3.1
    print_info "Configuring..."
    ./configure --prefix="${BASE}/zlib-armhf-install" --static
    print_info "Building..."
    make -j"$(nproc)"
    print_info "Installing..."
    make install
    print_success "zlib installed to ${BASE}/zlib-armhf-install"
)

# -----------------------------------------------------------------------------
# [2/7] bzip2 1.0.8
# -----------------------------------------------------------------------------
print_header "[2/7] bzip2 1.0.8"
fetch "https://github.com/libarchive/bzip2/archive/refs/tags/bzip2-1.0.8.tar.gz"
tar xzf bzip2-1.0.8.tar.gz
(
    cd bzip2-bzip2-1.0.8
    print_info "Building bzip2..."
    make CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" -f Makefile-libbz2_so
    make CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" libbz2.a
    mkdir -p "${BASE}/bzip2-armhf-install/include" "${BASE}/bzip2-armhf-install/lib"
    cp bzlib.h "${BASE}/bzip2-armhf-install/include/"
    cp libbz2.a "${BASE}/bzip2-armhf-install/lib/"
    cp -a libbz2.so* "${BASE}/bzip2-armhf-install/lib/"
    ln -sf libbz2.so.1.0.8 "${BASE}/bzip2-armhf-install/lib/libbz2.so"
    print_success "bzip2 installed to ${BASE}/bzip2-armhf-install"
)

# -----------------------------------------------------------------------------
# [3/7] libffi 3.4.6
# -----------------------------------------------------------------------------
print_header "[3/7] libffi 3.4.6"
fetch "https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz"
tar xzf libffi-3.4.6.tar.gz
(
    cd libffi-3.4.6
    print_info "Configuring..."
    ./configure \
        --host=arm-unknown-linux-gnueabihf \
        --build=x86_64-linux-gnu \
        --prefix="${BASE}/libffi-armhf-install" \
        --disable-shared
    print_info "Building..."
    make -j"$(nproc)"
    print_info "Installing..."
    make install
    print_success "libffi installed to ${BASE}/libffi-armhf-install"
)

# -----------------------------------------------------------------------------
# [4/7] util-linux 2.40.2 (libuuid)
# -----------------------------------------------------------------------------
print_header "[4/7] util-linux 2.40.2 (libuuid)"
fetch "https://www.kernel.org/pub/linux/utils/util-linux/v2.40/util-linux-2.40.2.tar.gz"
tar xzf util-linux-2.40.2.tar.gz
(
    cd util-linux-2.40.2
    print_info "Configuring..."
    ./configure \
        --host=arm-unknown-linux-gnueabihf \
        --build=x86_64-linux-gnu \
        --prefix="${BASE}/util-linux-armhf-install" \
        --disable-all-programs \
        --enable-libuuid \
        --disable-shared
    print_info "Building..."
    make -j"$(nproc)"
    print_info "Installing..."
    make install
    print_success "libuuid installed to ${BASE}/util-linux-armhf-install"
)

# -----------------------------------------------------------------------------
# [5/7] OpenSSL 1.1.1w
# -----------------------------------------------------------------------------
print_header "[5/7] OpenSSL 1.1.1w"
fetch "https://www.openssl.org/source/openssl-1.1.1w.tar.gz"
tar xzf openssl-1.1.1w.tar.gz
(
    cd openssl-1.1.1w
    print_info "Configuring..."
    ./Configure linux-generic32 \
        --prefix="${BASE}/openssl-armhf-install" \
        --openssldir="${BASE}/openssl-armhf-install/ssl" \
        -march=armv7-a \
        -mfpu=neon-vfpv4 \
        -mfloat-abi=hard \
        shared \
        no-tests \
        cross-compile-prefix=arm-unknown-linux-gnueabihf-
    print_info "Building..."
    make -j"$(nproc)"
    print_info "Installing..."
    make install_sw
    print_success "OpenSSL installed to ${BASE}/openssl-armhf-install"
)

# -----------------------------------------------------------------------------
# [6/7] xz-utils 5.6.2 (lzma)
# -----------------------------------------------------------------------------
print_header "[6/7] xz-utils 5.6.2 (lzma)"
fetch "https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.gz"
tar xzf xz-5.6.2.tar.gz
(
    cd xz-5.6.2
    print_info "Configuring..."
    ./configure \
        --host=arm-unknown-linux-gnueabihf \
        --build=x86_64-linux-gnu \
        --prefix="${BASE}/xz-armhf-install" \
        --disable-xz \
        --disable-xzdec \
        --disable-lzmadec \
        --disable-lzmainfo \
        --disable-scripts \
        --disable-shared
    print_info "Building..."
    make -j"$(nproc)"
    print_info "Installing..."
    make install
    print_success "lzma installed to ${BASE}/xz-armhf-install"
)

# -----------------------------------------------------------------------------
# [7/7] sqlite3 3.46.0
# -----------------------------------------------------------------------------
print_header "[7/7] sqlite3 3.46.0"
fetch "https://sqlite.org/2024/sqlite-autoconf-3460100.tar.gz"
tar xzf sqlite-autoconf-3460100.tar.gz
(
    cd sqlite-autoconf-3460100
    print_info "Configuring..."
    ./configure \
        --host=arm-unknown-linux-gnueabihf \
        --build=x86_64-linux-gnu \
        --prefix="${BASE}/sqlite3-armhf-install" \
        --disable-shared
    print_info "Building..."
    make -j"$(nproc)"
    print_info "Installing..."
    make install
    print_success "sqlite3 installed to ${BASE}/sqlite3-armhf-install"
)

print_header "Build Complete!"
echo ""
echo "All 7 libraries successfully built and installed:"
echo ""
printf "  %-15s %s\n" "Library" "Install Path"
printf "  %-15s %s\n" "------" "-----------"
printf "  %-15s %s\n" "zlib" "${BASE}/zlib-armhf-install"
printf "  %-15s %s\n" "bzip2" "${BASE}/bzip2-armhf-install"
printf "  %-15s %s\n" "libffi" "${BASE}/libffi-armhf-install"
printf "  %-15s %s\n" "libuuid" "${BASE}/util-linux-armhf-install"
printf "  %-15s %s\n" "OpenSSL" "${BASE}/openssl-armhf-install"
printf "  %-15s %s\n" "lzma" "${BASE}/xz-armhf-install"
printf "  %-15s %s\n" "sqlite3" "${BASE}/sqlite3-armhf-install"
echo ""
print_success "Done. You can now build Python 3.11.16"
echo ""
