# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)
- Previous Step 3, [here](./03-Build-host-python-env.md)



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
  ac_cv_file__dev_ptmx=yes \
  ac_cv_file__dev_ptc=no \
  ac_cv_func_getentropy=no \
  ac_cv_func_getrandom=no \
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

- Next, Step 5, [here](./05-Fix-PIP-Libraries.md)
