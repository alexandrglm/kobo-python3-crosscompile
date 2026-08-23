# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)
- Previous Step 6, [here](./06-Deploying-to-kobo.md)

---
## Verifications, troubleshootings, etc.

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

- Final Step, [here](./08-Compiling-compiled-PIP-modules.md)
