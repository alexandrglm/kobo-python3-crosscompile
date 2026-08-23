# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)
- Previous Step 7, [here](./07-Verify-installation-works.md)


## 8. What's Next? What about `numpy` or other compiled modules?

> [!NOTE]
> This Python 3.11.16 installation on the Kobo is fully functional with pip, SSL, and all core modules working correctly.

### 8.1 pip Works Fine

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

### 8.2 Compiled Modules

> [!IMPORTANT]
> **Pure Python packages** (like `requests`, `beautifulsoup4`, `flask`, `click`, etc.) install without issues because they contain only Python code.
>
> **Compiled packages** (like `numpy`, `scipy`, `pillow`, `lxml`, `cryptography`, etc.) require compilation of C/C++ code, which **fails on the Kobo** because:
>  - The Kobo has no compiler (`gcc` or `make`)
>  - The Kobo has no build tools (`cmake`, `ninja`, etc.)
>- The Kobo has limited memory and storage


> [!TIP]
> Most common Python packages (requests, flask, beautifulsoup4, etc.) are pure Python and work without any issues. Only specialised scientific/computational packages require extra effort. For the Kobo's typical use case (web scraping, automation, simple scripts), pure Python packages.



### 8.3   So... How to Install Compiled Modules?

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


### 8.4 Quick Check for Available Wheels

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
