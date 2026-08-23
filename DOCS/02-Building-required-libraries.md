# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)
- Previous Step 1, [here](./01-toolchain-setup.md)

---


## Part 2: Building Required Libraries

> [!IMPORTANT]
> Certain libraries must be compiled alongside the toolchain to ensure Python compiles correctly with full functionality. Below is the complete list of libraries we built, their versions, and the rationale for each.

| Library | Version | Purpose | Required? |
|---------|---------|---------|-----------|
| **OpenSSL** | 1.1.1w | SSL/TLS support for HTTPS, pip, and secure connections | **CRITICAL** |
| **zlib** | 1.3.1 | Compression support (`.gz` files, pip packages) | **REQUIRED** |
| **bzip2** | 1.0.8 | Decompression support (`.bz2` files, pip packages) | **REQUIRED** |
| **libffi** | 3.4.6 | Foreign Function Interface (for `ctypes`, used by many packages) | **REQUIRED** |
| **libuuid** (util-linux) | 2.40.2 | UUID generation (for `uuid` module) | **REQUIRED** |
| **lzma** (xz-utils) | 5.6.2 | LZMA/XZ compression (for `tarfile`, `.xz` packages) | **RECOMMENDED** |
| **sqlite3** | 3.46.0 | SQLite database support (used by many applications) | **RECOMMENDED** |

### Libraries NOT Compiled (And Why)

| Library | Purpose | Why Not Included |
|---------|---------|------------------|
| **libncurses** | Terminal UI support for `curses` module | Kobo has no interactive terminal where `curses` would be useful |
| **libpanel** | Panel library for `curses_panel` | Depends on `curses`; same rationale as above |
| **libtk** | Tk GUI for `tkinter` module | Kobo has no X11 display server. `tkinter` is completely useless on an e-reader |
| **libdb** | Berkeley DB for `_dbm` module | Rarely used; most applications use SQLite or JSON instead |
| **libgdbm** | GNU DBM for `_gdbm` module | Same as above; `shelve` and `dbm` are niche use cases |
| **libreadline** | Command-line editing and history | Not required for running scripts |
| **libgdb** | GDB debugger support | not needed for production; debugging can be done via logs |

> [!NOTE]
> **If compiling for a different target (e.g., a full Linux desktop or Raspberry Pi with GUI), consider adding:**
> - `libncurses` and `libpanel` for `curses` support
> - `libtk` for `tkinter` GUI applications
> - `libreadline` for interactive shell enhancements
> - `libdb` and `libgdbm` for complete `dbm` support
> - `libxml2` and `libxslt` for XML processing (if needed)
> - `libpng` and `libjpeg` for image support (if needed)

The list above is for learning-self-reference, **not required for the Kobo devices**.

### 2.1 Building Each Library

> [!IMPORTANT]
> **All libraries must be cross-compiled for ARMv7 using the `crosstool-NG` toolchain.**

#### 2.1.1 Set Base Environment

```bash
export BASE="/home/dev/Desktop/ClaraColour/python/crosstoolsng"
mkdir -p ${BASE}

export PATH="${HOME}/x-tools/arm-unknown-linux-gnueabihf/bin:${PATH}"
export CC=arm-unknown-linux-gnueabihf-gcc
export CXX=arm-unknown-linux-gnueabihf-g++
export AR=arm-unknown-linux-gnueabihf-ar
export RANLIB=arm-unknown-linux-gnueabihf-ranlib
```

---

#### 2.1.2 Build zlib (1.3.1)

| Library | Version | Install Path |
|---------|---------|--------------|
| **zlib** | 1.3.1 | `${BASE}/zlib-armhf-install` |

```bash
cd ${BASE}
wget https://zlib.net/zlib-1.3.1.tar.gz
tar -xzf zlib-1.3.1.tar.gz
cd zlib-1.3.1

./configure --prefix=${BASE}/zlib-armhf-install --static
make -j$(nproc)
make install
```

---

#### 2.1.3 Build bzip2 (1.0.8)

| Library | Version | Install Path |
|---------|---------|--------------|
| **bzip2** | 1.0.8 | `${BASE}/bzip2-armhf-install` |

```bash
cd ${BASE}
wget https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
tar -xzf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

make -j$(nproc) CC=${CC} AR=${AR} RANLIB=${RANLIB}
make install PREFIX=${BASE}/bzip2-armhf-install
```

---

#### 2.1.4 Build libffi (3.4.6)

| Library | Version | Install Path |
|---------|---------|--------------|
| **libffi** | 3.4.6 | `${BASE}/libffi-armhf-install` |

```bash
cd ${BASE}
wget https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz
tar -xzf libffi-3.4.6.tar.gz
cd libffi-3.4.6

./configure \
  --host=arm-unknown-linux-gnueabihf \
  --build=x86_64-linux-gnu \
  --prefix=${BASE}/libffi-armhf-install \
  --disable-shared

make -j$(nproc)
make install
```

---

#### 2.1.5 Build libuuid (util-linux 2.40.2)

| Library | Version | Install Path |
|---------|---------|--------------|
| **libuuid** | 2.40.2 | `${BASE}/util-linux-armhf-install` |

```bash
cd ${BASE}
wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.40/util-linux-2.40.2.tar.gz
tar -xzf util-linux-2.40.2.tar.gz
cd util-linux-2.40.2

./configure \
  --host=arm-unknown-linux-gnueabihf \
  --build=x86_64-linux-gnu \
  --prefix=${BASE}/util-linux-armhf-install \
  --disable-all-programs \
  --enable-libuuid \
  --disable-shared

make -j$(nproc)
make install
```

---

#### 2.1.6 Build OpenSSL (1.1.1w)

| Library | Version | Install Path |
|---------|---------|--------------|
| **OpenSSL** | 1.1.1w | `${BASE}/openssl-armhf-install` |

```bash
cd ${BASE}
wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz
tar -xzf openssl-1.1.1w.tar.gz
cd openssl-1.1.1w

CC=arm-unknown-linux-gnueabihf-gcc AR=... RANLIB=... \
./Configure linux-generic32 \
  -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard \
  shared no-tests

make -j$(nproc)
make install
```

---

#### 2.1.7 Build lzma (xz-utils 5.6.2)

| Library | Version | Install Path |
|---------|---------|--------------|
| **lzma** | 5.6.2 | `${BASE}/xz-armhf-install` |

```bash
cd ${BASE}
wget https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.gz
tar -xzf xz-5.6.2.tar.gz
cd xz-5.6.2

./configure \
  --host=arm-unknown-linux-gnueabihf \
  --build=x86_64-linux-gnu \
  --prefix=${BASE}/xz-armhf-install \
  --disable-xz \
  --disable-xzdec \
  --disable-lzmadec \
  --disable-lzmainfo \
  --disable-scripts \
  --disable-shared

make -j$(nproc)
make install
```

---

#### 2.1.8 Build sqlite3 (3.46.0)

| Library | Version | Install Path |
|---------|---------|--------------|
| **sqlite3** | 3.46.0 | `${BASE}/sqlite3-armhf-install` |

```bash
cd ${BASE}
wget https://sqlite.org/2024/sqlite-autoconf-3460100.tar.gz
tar -xzf sqlite-autoconf-3460100.tar.gz
cd sqlite-autoconf-3460100

./configure \
  --host=arm-unknown-linux-gnueabihf \
  --build=x86_64-linux-gnu \
  --prefix=${BASE}/sqlite3-armhf-install \
  --disable-shared

make -j$(nproc)
make install
```

---

- Next, Step 3, [here](./03-Build-host-python-env)
