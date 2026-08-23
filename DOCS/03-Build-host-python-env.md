# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)
- Previous Step 2, [here](./02-Building-required-libraries.md)

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


- Next Step 4, [here](./04-Crosscompile-kobo-python.md)
