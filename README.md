# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

After countless failed attempts, Docker experiments, sysroot nightmares, and GLIBC version errors, the final result is a fully functional Python 3.11.16 with pip, SSL, sqlite3, lzma, and all essential modules running on the Kobo, for the sake of tinkering =) !

## Process Overview

**The entire process is a full headache** that follow this approach:

1.   **Toolchain Setup**
  
The `crosstool-NG` toolchain is built with exact specifications: GLIBC 2.19, GCC 9.5.0, and Linux headers 3.2.101. This ensures all generated binaries are compatible with the Kobo's kernel and libraries.


2.   **Build Required Libraries**
  
Seven essential libraries are cross-compiled using the toolchain: OpenSSL (SSL/TLS), zlib, bzip2, libffi, libuuid, lzma, and sqlite3. These provide Python's core functionality (HTTPS, compression, UUID, etc.).


3  **Pre-requisites Before Building Python**
  
Python 3.11.16 requires a matching Python 3.11 interpreter on the host. This step compiles a native (x86_64) Python 3.11.16 and creates a virtual environment to serve as `--with-build-python` during cross-compilation.



4. **Cross-Compile Python**
  
Using the toolchain and compiled libraries, Python 3.11.16 is cross-compiled for ARMv7 (armhf). The `setup.py` file is patched to fix a cross-compilation bug, and the final product is installed to a staging directory.



5. **Latest fixes before deploying**
  
After the initial installation, several fixes are applied: pip is installed, OpenSSL libraries are copied to staging, shebangs in pip/scripts are corrected to point to the Kobo's Python location, symlinks are removed (FAT32 compatibility), and permissions are set.


6.  **Deploy to Kobo**

A FAT32-compatible tarball (without symlinks) is created and copied to the Kobo's user partition (`/mnt/onboard/.python/`). Wrapper scripts are installed in `/usr/bin/` to set environment variables and execute Python from the user partition.


---

- [Prerequisites](#prerequisites)

- [Part 1: Toolchain Setup](#part-1-toolchain-setup)

- [Part 2: Building Required Libraries](#part-2-building-required-libraries)
  - [2.1 Building Each Library](#21-building-each-library)
    - [2.1.1 Set Base Environment](#211-set-base-environment)
    - [2.1.2 Build zlib (1.3.1)](#212-build-zlib-131)
    - [2.1.3 Build bzip2 (1.0.8)](#213-build-bzip2-108)
    - [2.1.4 Build libffi (3.4.6)](#214-build-libffi-346)
    - [2.1.5 Build libuuid (util-linux 2.40.2)](#215-build-libuuid-util-linux-2402)
    - [2.1.6 Build OpenSSL (1.1.1w)](#216-build-openssl-111w)
    - [2.1.7 Build lzma (xz-utils 5.6.2)](#217-build-lzma-xz-utils-562)
    - [2.1.8 Build sqlite3 (3.46.0)](#218-build-sqlite3-3460)

- [Part 3: Pre-requisites Before Building Python](#part-3--pre-requisites-before-building-python)
  - [3.1 Download and Compile the Host Python](#31-download-and-compile-the-host-python)
  - [3.2 Create a Python 3.11 Virtual Environment for the Host](#32-create-a-python-311-virtual-environment-for-the-host)

- [Part 4: Cross-Compile Python 3.11.16 for the Kobo](#part-4-cross-compile-python-31116-for-the-kobo)
  - [4.1 Extract Fresh Python Source for Cross-Compilation](#41-extract-fresh-python-source-for-cross-compilation)
  - [4.2 Fix `setup.py` (CRITICAL)](#42-fix-setuppy-critical)
  - [4.3 Configure Python for Cross-Compilation](#43-configure-python-for-cross-compilation)
    - [4.3.1 Activate the Host Virtual Environment](#431-activate-the-host-virtual-environment)
    - [4.3.2 Set the Cross-Compilation Toolchain](#432-set-the-cross-compilation-toolchain)
    - [4.3.3 Run `./configure` with All Libraries](#433-run-configure-with-all-libraries)
    - [4.3.4 Verify Configure Success](#434-verify-configure-success)
  - [4.4 Build Python](#44--build-python)
    - [4.4.1 Check Build Output](#441-check-build-output)
  - [4.5 Install to Staging Directory](#45--install-to-staging-directory)

- [Part 5: Fixes for Pip, Missing Libraries, Shebangs and Others](#part-5-fixes-for-pip-missing-libraries-shebangs-and-others)
  - [5.1 Install Pip to Staging](#51-install-pip-to-staging)
  - [5.2 Copy OpenSSL Libraries to Staging](#52-copy-openssl-libraries-to-staging)
  - [5.3 Fix Pip Shebangs](#53-fix-pip-shebangs)
  - [5.4 Fix Any Other Script Shebangs](#54-fix-any-other-script-shebangs)
  - [5.5 Remove Symlinks (FAT32 Compatibility)](#55-remove-symlinks-fat32-compatibility)
  - [5.6 Set Correct Permissions](#56-set-correct-permissions)
  - [5.7 Verify Staging Directory Completeness](#57-verify-staging-directory-completeness)

- [Part 6: Deploying to the Kobo](#part-6-deploying-to-the-kobo)
  - [6.1 Create FAT32-Compatible Tarball](#61-create-fat32-compatible-tarball)
  - [6.2 Choose Installation Location on Kobo](#62-choose-installation-location-on-kobo)
  - [6.3 Create Python Wrapper Script](#63--create-python-wrapper-script)
  - [6.4 Create Pip Wrapper Script](#64--create-pip-wrapper-script)
  - [6.5 Create Convenience Symlinks](#65--create-convenience-symlinks)

- [Part 7: Verification](#part-7--verification)
  - [7.1 Test Python](#71--test-python)
  - [7.2 Test Core Modules](#72-test-core-modules)
  - [7.3 Test SSL (CRITICAL)](#73-test-ssl-critical)
  - [7.4 Test Pip with HTTPS](#74-test-pip-with-https)

- [Part 8: Troubleshooting](#part-8-troubleshooting)
- [Important Notes](#important-notes)
- [Quick Reference Commands](#quick-reference-commands)
- [Version Information](#version-information)
- [Final Directory Structure on Kobo](#final-directory-structure-on-kobo)

- [9. What's Next? What about `numpy` or other compiled modules?](#10-whats-next-what-about-numpy-or-other-compiled-modules)
  - [9.1 pip Works Fine](#101-pip-works-fine)
  - [9.2 Compiled Modules](#102-compiled-modules)
  - [9.3 So... How to Install Compiled Modules?](#103-so-how-to-install-compiled-modules)
    - [Option 1: Pre-compiled Wheels (Best)](#option-1-pre-compiled-wheels-best)
    - [Option 2: Cross-Compile on Your PC](#option-2-cross-compile-on-your-pc)

---

## Prerequisites

### Host System
- Debian/Ubuntu x86_64
- Minimum 20GB free disk space
- `build-essential`, and basic development tools
- A proper Python 3.11.16 version for host compiler

### Target Device

- Kobo Clara Colour

- SSH or TELNET access (read how-to [here](https://github.com/alexandrglm/kobo-clara-colour-mods-telnet-ssh-debian-chroot))

- Sufficient space in Kobo's root
> [!WARNING]
> Since the root partition is typically full on most Kobo devices, this guide installs Python on the FAT32 partition (`/mnt/onboard/`) using wrapper scripts. This also solves the symlink issue that FAT32 does not support.

---

## Part 1: Toolchain Setup

> [!IMPORTANT]
> This guide assumes you already have a working crosstool-NG toolchain with the correct GLIBC version (2.19) for your Kobo device.
>
> If not, refer to the companion repository for step-by-step instructions on building the exact toolchain for the Kobo Clara Colour (firmware August 2026), [here](https://github.com/alexandrglm/kobo-clara-colour-toolchain-glibc2.19)
>
> **Please, verify your toolchain carefully before proceeding!**

### 1.1 Verify Toolchain Installation

Check that the toolchain is installed and accessible.

```bash
export PATH="${HOME}/x-tools/arm-unknown-linux-gnueabihf/bin:${PATH}"
arm-unknown-linux-gnueabihf-gcc --version
```

**Expected output:**

```
arm-unknown-linux-gnueabihf-gcc (crosstool-NG 1.29.0.3_2e5d0b8) 9.5.0
Copyright (C) 2019 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

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

./Configure linux-armv4 \
  --prefix=${BASE}/openssl-armhf-install \
  --openssldir=${BASE}/openssl-armhf-install/ssl \
  cross-compile-prefix=arm-unknown-linux-gnueabihf- \
  no-shared

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

## Part 3:   Pre-requisites BEFORE Building Python

> [!IMPORTANT]
> **Python 3.11.16 requires a Python 3.11 interpreter on the host to cross-compile itself.**
>
> The `--with-build-python` flag needs a matching version to generate scripts and bytecode during the build. Your system likely has Python 3.13, which will cause version mismatch errors in `configure`.
>
> **This means you must compile Python TWICE:**
> 1. **First build:** Native (x86_64) Python 3.11.16 for your host; this will only be used to create the virtual environment.
> 2. **Second build:** Cross-compiled (ARMv7) Python 3.11.16 for the Kobo; the actual target.

### 3.1 Download and Compile the Host Python

```bash
cd ${BASE}

wget https://www.python.org/ftp/python/3.11.16/Python-3.11.16.tgz
tar -xzf Python-3.11.16.tgz
mv Python-3.11.16/ Python-3.11.16-HOST/

cd Python-3.11.16-HOST/

# Build NATIVELY for x86_64 (NOT cross-compilation)
./configure --prefix=${BASE}/python311-host
make -j$(nproc)
make install
```

---

### 3.2 Create a Python 3.11 Virtual Environment for the Host

```bash
# Create venv using the native build
${BASE}/python311-host/bin/python3.11 -m venv ${BASE}/.venv

# Activate the venv
source ${BASE}/.venv/bin/activate

# Verify
python --version
# Should show: Python 3.11.16
```

> [!NOTE]
> Once the virtual environment is created and verified, you no longer need the native host source code or the installed native Python binary. They served their purpose.
>
> **You can safely remove them to free up disk space:**

```bash
cd ${BASE}

# Remove the host Python source directory
rm -rf Python-3.11.16-HOST/

# Remove the native host Python installation (keep only the venv)
rm -rf python311-host/

# The venv at ${BASE}/.venv is the only thing you need going forward
```

> [!WARNING]
> **DO NOT delete the `.venv` directory.** It contains the Python 3.11 interpreter that will be used as `--with-build-python` for cross-compilation.

---

## Part 4: Cross-Compile Python 3.11.16 for the Kobo

> [!IMPORTANT]
> This is the **second build** (the actual Python that will run on the Kobo).
>
> All previously compiled libraries (zlib, bzip2, libffi, libuuid, OpenSSL, lzma, sqlite3) are now ready to be linked into Python.

---

### 4.1 Extract Fresh Python Source for Cross-Compilation

We need a clean copy of the Python source for the cross-compilation build. Do **not** reuse the host source directory.

```bash
cd ${BASE}
wget https://www.python.org/ftp/python/3.11.16/Python-3.11.16.tgz
tar -xzf Python-3.11.16.tgz
cd Python-3.11.16
```

---

### 4.2 Fix `setup.py` (CRITICAL)

> [!WARNING]
> **Python's `setup.py` has a cross-compilation bug.**
>
> It uses `dpkg-architecture` from the **host** system to determine include paths, not the target's sysroot. This causes it to add host headers (`/usr/include/arm-linux-gnueabihf`) instead of sysroot headers, breaking the build.
>
> **The Fix:** Comment out the `get_host_architecture()` block in `setup.py`.

**Lines to edit (around line 720 in Python 3.11.16):**

```python
# dpkg_architecture = get_host_architecture()
# if dpkg_architecture:
#     host_platform = dpkg_architecture[0]
#     multiarch = dpkg_architecture[1]
```

**Apply the fix with sed:**

```bash
sed -i '720,735s/^/# /' setup.py
```

Or manually edit `setup.py` and comment out the `get_host_architecture()` block.  

-  A fixed `setup.py` for Python 3.11.16 **is provided [here](./py31116-fixes/setup.py).**

---

### 4.3 Configure Python for Cross-Compilation

#### 4.3.1 Activate the Host Virtual Environment

The host venv contains Python 3.11.16, which is required for the `--with-build-python` flag.

```bash
source ${BASE}/.venv/bin/activate
```

#### 4.3.2 Set the Cross-Compilation Toolchain

Add the crosstool-NG toolchain to your PATH and set the compiler variables.

```bash
export PATH="${HOME}/x-tools/arm-unknown-linux-gnueabihf/bin:${PATH}"
export CC=arm-unknown-linux-gnueabihf-gcc
export CXX=arm-unknown-linux-gnueabihf-g++
export AR=arm-unknown-linux-gnueabihf-ar
export RANLIB=arm-unknown-linux-gnueabihf-ranlib
```

#### 4.3.3 Run `./configure` with All Libraries

> [!WARNING]
> The `BASE` variable is used here for clarity. **In practice, you should use absolute paths** to avoid any ambiguity.

```bash
CONFIG_SITE=${BASE}/config.site \
./configure \
  --host=arm-unknown-linux-gnueabihf \
  --build=x86_64-linux-gnu \
  --prefix=/usr \
  --exec-prefix=/usr \
  --with-build-python=${BASE}/.venv/bin/python3.11 \
  --with-openssl=${BASE}/openssl-armhf-install \
  --with-ensurepip=install \
  --disable-ipv6 \
  CPPFLAGS="-I${BASE}/zlib-armhf-install/include -I${BASE}/bzip2-armhf-install/include -I${BASE}/libffi-armhf-install/include -I${BASE}/util-linux-armhf-install/include/uuid -I${BASE}/xz-armhf-install/include -I${BASE}/sqlite3-armhf-install/include" \
  LDFLAGS="-L${BASE}/zlib-armhf-install/lib -L${BASE}/bzip2-armhf-install/lib -L${BASE}/libffi-armhf-install/lib -L${BASE}/util-linux-armhf-install/lib -L${BASE}/xz-armhf-install/lib -L${BASE}/sqlite3-armhf-install/lib"
```

| Flag | Purpose |
|------|---------|
| `--host=arm-unknown-linux-gnueabihf` | Target architecture (ARMv7 hard-float) |
| `--build=x86_64-linux-gnu` | Host architecture (your PC) |
| `--prefix=/usr` | Installation prefix on the Kobo |
| `--exec-prefix=/usr` | Binary installation prefix on the Kobo |
| `--with-build-python=...` | Python 3.11 interpreter on the host (from venv) |
| `--with-openssl=...` | Path to cross-compiled OpenSSL |
| `--with-ensurepip=install` | Install pip during build |
| `--disable-ipv6` | Disable IPv6 checks (avoids getaddrinfo issues) |
| `CPPFLAGS=...` | Include paths for all cross-compiled libraries |
| `LDFLAGS=...` | Library paths for all cross-compiled libraries |



#### 4.3.4 Verify Configure Success

After `./configure` completes, check the output summary. You should see:

```
zlib                yes
_bz2                yes
_ctypes             yes
_uuid               yes
_ssl                yes
_hashlib            yes
_lzma               yes
_sqlite3            yes
```

> [!IMPORTANT]
> If any of these say `no`, `disabled` or `N/A`, the build will lack that functionality.  
  
Therefore, you must double-check:

- Python VENV paths and functionality
- Verify the crosstools-NG paths
- Review the `./configure` used FLAGS
- Ensure all extra libraries have been compiled separately
- Confirm that you are using absolute paths instead of relative ones
- Etc.

---

### 4.4   Build Python

Now compile Python. This will take 15-30 minutes depending on your system.

```bash
make -j$(nproc)
```

#### 4.4.1 Check Build Output

After `make` completes, you should see a summary like:

```
Checked 112 modules (33 built-in, 76 shared, 1 n/a on linux-arm, 0 disabled, 2 missing, 0 failed on import)
```

> [!IMPORTANT]
> The "missing" modules should only be optional ones we intentionally skipped (`_curses`, `_tkinter`, `_dbm`, `_gdbm`).
> 
> If `_ssl`, `_hashlib`, `_lzma`, or `_sqlite3` appear in the missing list, something went wrong.

---

### 4.5   Install to Staging Directory

Install Python to a staging directory. This will be the source for the final tarball, as for example:

```bash
make install DESTDIR=${BASE}/py311kobo-final
```

---

## Part 5: Fixes for Pip, Missing Libraries, Shebangs and Others

> [!IMPORTANT]
> Before creating the final tarball, several fixes must be applied to ensure everything works correctly on the Kobo.


###   5.1 Install Pip to Staging

Download and install pip into the staging directory using the host venv.

```bash
cd ${BASE}/py311kobo-final

wget https://bootstrap.pypa.io/get-pip.py
${BASE}/.venv/bin/python3.11 get-pip.py \
  --root=${BASE}/py311kobo-final \
  --prefix=/usr \
  --ignore-installed \
  --no-warn-script-location

rm get-pip.py
```

### 5.2 Copy OpenSSL Libraries to Staging

> [!IMPORTANT]
> The Python `_ssl.so` module links against `libssl.so.1.1` and `libcrypto.so.1.1`. These must be copied to the staging directory before creating the tarball.

1.  Copy OpenSSL shared libraries from the install directory

```bash
cp ${BASE}/openssl-armhf-install/lib/libssl.so.1.1 ${BASE}/py311kobo-final/usr/lib/
cp ${BASE}/openssl-armhf-install/lib/libcrypto.so.1.1 ${BASE}/py311kobo-final/usr/lib/
```

---

### 5.3 Fix Pip Shebangs

> [!IMPORTANT]
> Pip scripts currently point to your host Python path.
> They must be fixed to point to the Kobo's future Python location.

For example, PATH for internal Kobo pythton location would be `/mnt/onboard/.python/', so:

- Fix all pip scripts to use the correct Kobo Python path:

```bash
cd ${BASE}/py311kobo-final/usr/bin

for f in pip pip3 pip3.11; do

    if [ -f "$f" ]; then
        sed -i '1s|.*|#!/mnt/onboard/.python/usr/bin/python3.11|' "$f"
        echo "Fixed shebang in: $f"
    fi

done
```
---

### 5.4 Fix Any Other Script Shebangs

Some other scripts may also have incorrect shebangs. Fix them all:

```bash
for f in idle3.11 pydoc3.11 2to3-3.11; do
    if [ -f "$f" ]; then
        sed -i '1s|.*|#!/mnt/onboard/.python/usr/bin/python3.11|' "$f"
    fi
done
```

---

### 5.5 Remove Symlinks (FAT32 Compatibility)

> [!WARNING]
> The Kobo's user partition (`/mnt/onboard`) is FAT32, which **does not support symbolic links**.

1.  emove any existing symlinks:
```bash
cd ${BASE}/py311kobo-final

find usr -type l -delete
```

2.  Verify no symlinks remain:

```bash
find usr -type l | wc -l
```
**Should show: 0**

---

### 5.6 Set Correct Permissions

Ensure all files have the correct permissions for the Kobo.

```bash
cd ${BASE}/py311kobo-final

# Directories: 755
find usr -type d -exec chmod 755 {} \;

# Binaries: 755
chmod -R 755 usr/bin/

# Python files: 644
find usr/lib/python3.11 -name "*.py" -exec chmod 644 {} \; 2>/dev/null

# Shared libraries: 644
find usr/lib/python3.11/lib-dynload -name "*.so" -exec chmod 644 {} \; 2>/dev/null
find usr/lib -name "*.so.*" -exec chmod 644 {} \; 2>/dev/null

# Set lib-dynload directory to 755
chmod 755 usr/lib/python3.11/lib-dynload/
```

---

### 5.7 Verify Staging Directory Completeness

Run these checks to confirm the staging directory contains everything needed.

```bash
cd ${BASE}/py311kobo-final

echo "Total files: $(find usr -type f | wc -l)"
echo "Python files: $(find usr/lib/python3.11 -name "*.py" | wc -l)"
echo "Shared objects: $(find usr -name "*.so*" | wc -l)"
echo "Binaries: $(ls -la usr/bin/ | wc -l)"

echo "OpenSSL libraries:"

ls -la usr/lib/libssl.so.1.1 2>/dev/null || echo "ERROE libssl.so.1.1 MISSING"
ls -la usr/lib/libcrypto.so.1.1 2>/dev/null || echo "ERROR libcrypto.so.1.1 MISSING"

echo "Encodings: $(find usr/lib/python3.11/encodings -name "*.py" | wc -l)"
```

**Expected results:**

| Check | Expected |
|-------|----------|
| Total files | ~9500 |
| Python files | ~2265 |
| Shared objects | ~75 |
| OpenSSL libraries | 2 files present |
| Encodings | ~180 files |

---

## Part 6: Deploying to the Kobo

> [!IMPORTANT]
> This section covers creating the FAT32-compatible tarball, copying it to the Kobo, extracting it, and setting up the wrapper scripts.

---

### 6.1 Create FAT32-Compatible Tarball

> [!WARNING]
> The Kobo's user partition is FAT32, which does not support symbolic links. We use `--hard-dereference` and `--dereference` to convert symlinks to regular files.

1.  Create tarball without symlinks (FAT32 compatible)

```bash
cd ${BASE}/py311kobo-final


tar --owner=root --group=root \
    --hard-dereference \
    --dereference \
    -czf KoboPythonUserSpace.tgz usr/
```

---

### 6.2 Choose Installation Location on Kobo

> [!NOTE]
> We install Python on the FAT32 partition (`/mnt/onboard/.python/`) to avoid filling the root partition.
>
> The directory structure will be:
>
> ```
> /mnt/onboard/.python/
> └── usr/
>     ├── bin/
>     ├── lib/
>     └── include/
> ```

1.  Create the target directory on the Kobo (via SSH, TELNET):

```bash
[root@kobo ~]# mkdir -p /mnt/onboard/.python"
```

2.   Copy the tarball to the Kobo's user partition (via scp, or via USB):

```bash
scp ${BASE}/py311kobo-final/KoboPythonUserSpace.tgz root@<IP>:/mnt/onboard/.python/
```

---

3.  Extract the tarball on Kobo

```bash
ssh root@192.168.1.216

cd /mnt/onboard/.python

tar -xzf KoboPythonUserSpace.tgz
```

- Remove the tarball to free space, `rm KoboPythonUserSpace.tgz`

---

### 6.3   Create Python Wrapper Script

The wrapper script sets the necessary environment variables and executes the Python binary from the user partition.

```bash
ssh root@192.168.1.216

cat > /usr/bin/python3 << 'EOF'
#!/bin/sh
export PYTHONHOME=/mnt/onboard/.python/usr
export PYTHONPATH=/mnt/onboard/.python/usr/lib/python3.11
export LD_LIBRARY_PATH=/mnt/onboard/.python/usr/lib:$LD_LIBRARY_PATH
exec /mnt/onboard/.python/usr/bin/python3.11 "$@"
EOF

chmod +x /usr/bin/python3
```

---

### 6.4   Create Pip Wrapper Script

Similarly, create a wrapper for pip.

```bash
cat > /usr/bin/pip3 << 'EOF'
#!/bin/sh
export PYTHONHOME=/mnt/onboard/.python/usr
export PYTHONPATH=/mnt/onboard/.python/usr/lib/python3.11
export LD_LIBRARY_PATH=/mnt/onboard/.python/usr/lib:$LD_LIBRARY_PATH
exec /mnt/onboard/.python/usr/bin/pip3.11 "$@"
EOF

chmod +x /usr/bin/pip3
```

---

### 6.5   Create Convenience Symlinks

For convenience, you may want to add `python` and `pip` aliases.

```bash
cat > /usr/bin/python << 'EOF'
#!/bin/sh
exec /usr/bin/python3 "$@"
EOF
chmod +x /usr/bin/python

cat > /usr/bin/pip << 'EOF'
#!/bin/sh
exec /usr/bin/pip3 "$@"
EOF
chmod +x /usr/bin/pip
```

---


## Part 7:   Verification

### 7.1  Test Python

```bash
[root@kobo ~]# python3 --version
Python 3.11.16

[root@kobo ~]# pip3 --version
pip 26.2.1 from /mnt/onboard/.python/usr/lib/python3.11/site-packages/pip (python 3.11)
```

### 7.2 Test Core Modules

```bash
python3 -c "import encodings; print('✅ encodings OK')"
python3 -c "import json; print('✅ json OK')"
python3 -c "import sqlite3; print('✅ sqlite3 OK')"
python3 -c "import lzma; print('✅ lzma OK')"
python3 -c "import zlib; print('✅ zlib OK')"
python3 -c "import bz2; print('✅ bz2 OK')"
python3 -c "import uuid; print('✅ uuid OK')"
python3 -c "import ctypes; print('✅ ctypes OK')"
```

### 7.2 Test SSL (CRITICAL)

```bash
python3 -c "import ssl; print(f'✅ OpenSSL {ssl.OPENSSL_VERSION}')"
# Should show: OpenSSL 1.1.1w  11 Sep 2023
```

### 7.3 Test Pip with HTTPS

```bash
pip3 install requests
python3 -c "import requests; print('✅ requests OK')"
```

---

## Part 8: Troubleshooting

### Issue: `ImportError: libssl.so.1.1: cannot open shared object file`

**Cause:**   OpenSSL libraries not copied to Kobo.

**Solution:**

```bash
scp ${BASE}/openssl-armhf-install/lib/libssl.so.1.1 root@192.168.1.216:/mnt/onboard/.python/usr/lib/
scp ${BASE}/openssl-armhf-install/lib/libcrypto.so.1.1 root@192.168.1.216:/mnt/onboard/.python/usr/lib/
```

### Issue: `No module named 'encodings'`

**Cause:**   Python standard library not extracted correctly.

**Solution:**
```bash
cd /mnt/onboard/.python
tar -xzf KoboPythonUserSpace.tgz
ls -la usr/lib/python3.11/encodings/
```

### Issue: `tar: can't create symlink: Operation not permitted`

**Cause:** FAT32 partition doesn't support symlinks.

**Solution:** Recreate tarball without symlinks:
```bash
cd ${BASE}/py311kobo-final
find usr -type l -delete
tar --owner=root --group=root --hard-dereference --dereference -czf KoboPythonUserSpace.tgz usr/
```

### Issue: `GLIBC_2.XX not found`

**Cause:** Python compiled against newer GLIBC than Kobo's 2.19.

**Solution:** Ensure toolchain uses GLIBC 2.19. Rebuild with correct crosstool-NG configuration.

### Issue: `ssl module is unavailable`

**Cause:** OpenSSL not found during Python build.

**Solution:**
1. Verify OpenSSL build: `ls ${BASE}/openssl-armhf-install/lib/libssl.so*`
2. Verify OpenSSL headers: `ls ${BASE}/openssl-armhf-install/include/openssl/`
3. Rebuild Python with `--with-openssl=${BASE}/openssl-armhf-install`

### Issue: `pip: command not found`

**Cause:** Pip wrapper not created or not executable.

**Solution:**
```bash
ls -la /usr/bin/pip3
# If missing, recreate the wrapper script (see section 6.6)
```

---

## Important Notes

1. **Kobo GLIBC**: The Kobo Clara Colour uses GLIBC 2.19. Any binary compiled with GLIBC > 2.19 will NOT work.

2. **FAT32 Limitations**: The `/mnt/onboard` partition is FAT32, which does NOT support:
   - Symbolic links
   - Unix permissions
   - Special files

3. **LD_LIBRARY_PATH**: Required for SSL to work. Ensure it's set in all wrapper scripts.

4. **Shebangs**: All Python scripts (`pip`, etc.) must have shebang pointing to `/mnt/onboard/.python/usr/bin/python3.11`, NOT your PC's Python path.

5. **Space**: Python installation uses ~327MB on the Kobo's user partition.

---

## Quick Reference Commands

### Rebuild Python After Library Updates

```bash
cd ${BASE}/Python-3.11.16
make distclean
# Run configure again (see section 4.4)
make -j$(nproc)
make install DESTDIR=${BASE}/py311kobo-final
```

### Deploy Everything to Kobo

```bash
# Copy tarball
scp ${BASE}/py311kobo-final/KoboPythonUserSpace.tgz root@192.168.1.216:/mnt/onboard/.python/

# Copy OpenSSL libraries
scp ${BASE}/openssl-armhf-install/lib/libssl.so.1.1 root@192.168.1.216:/mnt/onboard/.python/usr/lib/
scp ${BASE}/openssl-armhf-install/lib/libcrypto.so.1.1 root@192.168.1.216:/mnt/onboard/.python/usr/lib/
```

---

## Version Information

| Component | Version |
|-----------|---------|
| **Python** | 3.11.16 |
| **OpenSSL** | 1.1.1w |
| **GLIBC** | 2.19 |
| **GCC** | 9.5.0 |
| **Binutils** | 2.32 |
| **Linux Headers** | 3.2.101 |
| **zlib** | 1.3.1 |
| **bzip2** | 1.0.8 |
| **libffi** | 3.4.6 |
| **util-linux** | 2.40.2 |
| **xz-utils** | 5.6.2 |
| **sqlite3** | 3.46.0 |

---

## Final Directory Structure on Kobo

```
/mnt/onboard/.python/
└── usr/
    ├── bin/
    │   ├── python3.11
    │   ├── pip3.11
    │   ├── pip3 -> pip3.11
    │   └── pip -> pip3.11
    ├── lib/
    │   ├── libssl.so.1.1
    │   ├── libcrypto.so.1.1
    │   └── python3.11/
    │       ├── encodings/
    │       ├── lib-dynload/
    │       │   ├── _ssl.cpython-311-arm-linux-gnueabihf.so
    │       │   ├── _hashlib.cpython-311-arm-linux-gnueabihf.so
    │       │   └── ...
    │       └── site-packages/
    │           └── pip/
    └── include/
        └── python3.11/
```
---

## 9. What's Next? What about `numpy` or other compiled modules?

> [!NOTE]
> This Python 3.11.16 installation on the Kobo is fully functional with pip, SSL, and all core modules working correctly.

### 9.1 pip Works Fine

```bash
[root@kobo ~]# pip install jsonify
-sh: pip: not found
[root@kobo ~]# pip3 install jsonify
Collecting jsonify
  Downloading jsonify-0.5.tar.gz (1.0 kB)
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
  Preparing metadata (pyproject.toml) ... done
Building wheels for collected packages: jsonify
  Building wheel for jsonify (pyproject.toml) ... done
  Created wheel for jsonify: filename=jsonify-0.5-py3-none-any.whl size=1564 sha256=1f65f5d1c969bfc2d649347266f9f6afa6a9cd09c28b272ef50a1383fc33ddba
  Stored in directory: /.cache/pip/wheels/8b/0b/70/cd8a2f72ec6e8dbab2d7fffe3e8a545f4d152255cc7e8541f5
Successfully built jsonify
Installing collected packages: jsonify
Successfully installed jsonify-0.5

WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager, possibly rendering your system unusable. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv. Use the --root-user-action option if you know what you are doing and want to suppress this warning.
```

### 9.2 Compiled Modules

> [!IMPORTANT]
> **Pure Python packages** (like `requests`, `beautifulsoup4`, `flask`, `click`, etc.) install without issues because they contain only Python code.
>
> **Compiled packages** (like `numpy`, `scipy`, `pillow`, `lxml`, `cryptography`, etc.) require compilation of C/C++ code, which **fails on the Kobo** because:
>  - The Kobo has no compiler (`gcc` or `make`)
>  - The Kobo has no build tools (`cmake`, `ninja`, etc.)
>- The Kobo has limited memory and storage


> [!TIP]
> Most common Python packages (requests, flask, beautifulsoup4, etc.) are pure Python and work without any issues. Only specialised scientific/computational packages require extra effort. For the Kobo's typical use case (web scraping, automation, simple scripts), pure Python packages.



### 9.3   So... How to Install Compiled Modules?

There are two ways to install compiled modules on the Kobo:

#### Option 1:   Pre-compiled Wheels (Best)

If a pre-compiled wheel exists for your platform (ARMv7, Python 3.11), pip will download and install it directly.  
Many popular packages have pre-compiled wheels for ARMv7 (`linux_armv7l`, `manylinux2014_armv7l`, `musllinux_1_1_armv7l`). However, not all packages provide these.

-  Try to install with --only-binary to force wheel installation:
```bash
pip3 install numpy --only-binary numpy
```

#### Option 2: Cross-Compile on Your PC

If no pre-compiled wheel exists, you must cross-compile the module on your PC using the same toolchain used for Python.

**Example: Cross-compiling NumPy**

- On your PC (with crosstool-NG toolchain):
```bash
export PATH="${HOME}/x-tools/arm-unknown-linux-gnueabihf/bin:${PATH}"
export CC=arm-unknown-linux-gnueabihf-gcc
export CXX=arm-unknown-linux-gnueabihf-g++
export SYSROOT="${HOME}/x-tools/arm-unknown-linux-gnueabihf/arm-unknown-linux-gnueabihf/sysroot"
```

- Create a cross-compilation environment using `crossenv`:
```bash
pip3 install crossenv

python3 -m crossenv \
  --host ${CC} \
  --sysroot ${SYSROOT} \
  ${BASE}/.venv/bin/python3.11 \
  ${BASE}/numpy-crossenv

source ${BASE}/numpy-crossenv/bin/activate
```

- Build numpy for ARM. The wheel will be generated in dist/ or you can find it in the build directory:

```bash
pip3 install numpy
```

- After building, copy the resulting `.whl` or the compiled `.so` files to the Kobo:

```bash
scp dist/numpy-*.whl root@192.168.1.216:/tmp/
pip3 install /tmp/numpy-*.whl
```


### 9.5 Quick Check for Available Wheels

```bash
# Check if a pre-compiled wheel exists for your platform
pip3 download --no-deps --platform linux_armv7l --python-version 3.11 --abi cp311 <package-name>

# Example
pip3 download --no-deps --platform linux_armv7l --python-version 3.11 --abi cp311 numpy
# If it downloads a .whl file, it exists.
```


- **Pure Python packages:** Work perfectly.
- **Compiled packages:** 
  - Check for pre-compiled wheels first (`pip3 install --only-binary`)
  - If no wheel exists, cross-compile on your PC using the crosstool-NG toolchain
  - Copy the compiled files to the Kobo


---



*Last Updated: August 2026*
