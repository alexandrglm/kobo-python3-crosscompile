#!/bin/bash
# patch-setup.py.sh
# Fixes the cross-compilation bug in CPython's setup.py where
# add_multiarch_paths() calls the HOST's dpkg-architecture, injecting
# host glibc headers (/usr/include/<triplet>) into the cross-build.
#
# This contaminates the build with the wrong glibc (host's modern glibc
# instead of the toolchain's glibc 2.19 sysroot), breaking nearly every
# module (unicodedata, _ssl, _hashlib, etc.), not just SSL-related ones.
#
# Usage: run from inside the extracted Python-3.11.16/ source directory,
# BEFORE running ./configure.
#
#   cd Python-3.11.16
#   /path/to/patch-setup.py.sh

set -euo pipefail

if [ ! -f setup.py ]; then
    echo "ERROR: setup.py not found in current directory."
    echo "Run this script from inside the extracted Python-3.11.16/ source tree."
    exit 1
fi

if grep -q "disabled: breaks cross-compile with crosstool-NG sysroot" setup.py; then
    echo "setup.py already patched. Nothing to do."
    exit 0
fi

cp setup.py setup.py.orig
echo "Backed up original to setup.py.orig"

sed -i '/def add_multiarch_paths(self):/a\        return  # disabled: breaks cross-compile with crosstool-NG sysroot' setup.py

if grep -A1 "def add_multiarch_paths(self):" setup.py | grep -q "return  # disabled"; then
    echo "Patch applied successfully."
    echo ""
    sed -n '/def add_multiarch_paths/,+2p' setup.py
else
    echo "ERROR: patch verification failed. Restoring original."
    cp setup.py.orig setup.py
    exit 1
fi
