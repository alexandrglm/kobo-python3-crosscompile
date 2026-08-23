# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)
- Previous Step 4, [here](./04-Crosscompile-kobo-python.md)


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

- Next, Step 6, [here](./06-Deploying-to-kobo.md)
