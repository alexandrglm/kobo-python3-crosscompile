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

- Next, Step 7, [here](./07-Verify-installation-works.md)
