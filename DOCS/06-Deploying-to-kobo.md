# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)
- Previous Step 5, [here](./05-Fix-PIP-Libraries.md)

---

## Part 6: Deploying to the Kobo

> [!IMPORTANT]
> This section covers creating the FAT32-compatible tarball, copying it to the Kobo, extracting it, and setting up the wrapper scripts.

---

### 6.1 Create FAT32-Compatible Tarball

> [!WARNING]
> The Kobo's user partition is FAT32, which does not support symbolic links. We use `--hard-dereference` and `--dereference` to convert symlinks to regular files.


---

### 6.2 Deployment Options

> [!NOTE]
> There are two ways to deploy Python to the Kobo. Choose the one that fits your needs.

**Option A: FAT32 Partition (`/mnt/onboard/.python/`)**

This is the default option described below. The FAT32 partition has plenty of space, but does not support symlinks.

1.  Create tarball without symlinks (FAT32 compatible)

```bash
cd ${BASE}/py311kobo-final


tar --owner=root --group=root \
    --hard-dereference \
    --dereference \
    -czf KoboPythonUserSpace.tgz usr/
```

**Option B: System Root (`/usr/local/python/`)**

If you prefer to install Python in the system root, skip to [Section 6.6](#66-option-b-system-root-deployment).

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

### 6.6 Option B: System Root Deployment (`/usr/local/python/`)

> [!NOTE]
> This option installs Python directly in the system root. Ext4 supports symbolic links.

#### 6.6.1 Prepare System Root Tarball

```bash
cd ${BASE}/py311kobo-final

# No special flags needed - ext4 supports symlinks
tar -czf KoboRoot.tgz usr/
```

#### 6.6.2 Deploy to Kobo

```bash
# Copy tarball
scp KoboRoot.tgz root@192.168.1.216:/mnt/onboard/

# Extract to root
ssh root@192.168.1.216
cd /
tar -xzf /mnt/onboard/KoboRoot.tgz
rm /mnt/onboard/KoboRoot.tgz
```

**Final structure:**
```
./usr/
└── local
    └── python
        ├── bin
        ├── include
        │   ├── openssl
        │   └── python3.11
        ├── lib
        │   ├── engines-1.1
        │   ├── pkgconfig
        │   └── python3.11
        └── share
            └── man

```

#### 6.6.3 Create Wrappers (System Root)

```bash
ssh root@192.168.1.216

# Python3 wrapper
cat > /usr/bin/python3 << 'EOF'
#!/bin/sh
export PATH="/usr/local/python/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/python/lib:$LD_LIBRARY_PATH"
export PYTHONHOME="/usr/local/python"
exec /usr/local/python/bin/python3.11 "$@"
EOF
chmod +x /usr/bin/python3

# Pip3 wrapper
cat > /usr/bin/pip3 << 'EOF'
#!/bin/sh
export PATH="/usr/local/python/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/python/lib:$LD_LIBRARY_PATH"
export PYTHONHOME="/usr/local/python"
exec /usr/local/python/bin/pip3 "$@"
EOF
chmod +x /usr/bin/pip3
```

> [!IMPORTANT]
> For Option B, shebangs in scripts must point to: `#!/usr/local/python/bin/python3.11`

---

### 6.7 Verify Installation (Both Options)

```bash
# Test Python
python3 --version

# Test SSL
python3 -c "import ssl; print(ssl.OPENSSL_VERSION)"

# Test all libraries
python3 -c "import bz2, lzma, ctypes, zlib; print('All libraries OK')"

# Test pip
pip3 --version
pip3 install requests
```

---

- Next, Step 7, [here](./07-Verify-installation-works.md)
