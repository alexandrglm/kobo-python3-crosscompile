# Kobo Clara Colour (and derivates)
## Python 3.11.16 Cross-Compilation Guide

- Full README, [here](./README.md)

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

## More about crosstool-NG menuconfig deviations from defaults

This is NOT a full `.config` (crosstool-NG configs run to 500+ lines and depend on the exact crosstool-NG version).  

Instead, this documents every value that was deliberately changed away from the ct-ng default during `ct-ng menuconfig`, so the toolchain can be reproduced by following this entire guide and applying these values at each screen.

Run `ct-ng menuconfig` from the crosstool-ng source directory (NOT from the installed `ct-ng/bin/` prefix), then`.config` is saved relative to the current working directory) and set:

## Paths and misc options

-   Prefix directory: left at default (`${HOME}/x-tools/${CT_TARGET}`)

## Target options
-   Target Architecture: `arm`
-   Default instruction set mode: `arm`
-   Endianness: Little endian
-   Bitness: 32-bit
-   Architecture level: `armv7-a`
-   Use specific FPU: `neon-vfpv4`  (NOT `neon-vpfv4` — watch the typo, it breaks the build silently until gcc rejects it)
-   Tune for CPU: `cortex-a53`
-   Floating point: `hardware (FPU)`

## Operating System
-   Target OS: `linux`
-   Version of linux: `3.2.101` (oldest available in the release-tarball list; matches/predates the Kobo's real 4.9.77 kernel for max syscall compatibility)

## C-library (glibc)
-   Version of glibc: `2.19` (exact match to the Kobo's installed glibc, confirmed via `strings /lib/libc.so.6 | grep "GNU C Library"` on the device)
-   Everything else left at the ct-ng-computed defaults for this glibc version (Enable obsolete RPC, -fcommon flag, etc.... these auto-populate correctly once 2.19 is selected)

## C compiler
-   Version of gcc: `9.5.0` (NOT the default latest, gcc 16.x combined with glibc 2.19 causes brittle, poorly-tested toolchain combinations)
-   Additional supported languages: enable `C++` (needed for a couple of stdlib extension modules; cheap to enable at toolchain-build time, expensive to add later)

##   Binary utilities
-   Version of binutils: `2.32` (NOT the default latest, paired with gcc 9.5.0, this is a well-tested combination; recent binutils changes default linker hardening flags that can behave unexpectedly against such an old glibc)
-   Linkers to enable: `ld` (BFD) ... do not enable `mold`

## Debug facilities
-   Enable `gdb` (useful for on-device debugging later; everything else  `duma`, `ltrace`, `strace` left disabled)

## Companion libraries / Companion tools
- Left entirely at ct-ng defaults (expat, gettext, gmp, isl, libiconv, mpc, mpfr, ncurses, zlib all forced `-*-` automatically; make left enabled, autoconf/automake/bison/libtool/m4 left disabled since they're already installed on the host via apt)

---

After setting all of the above and saving `.config`, build with:

```bash
ct-ng build.$(nproc)
```

---

- Follow to Step 2, [here](./02-Building-required-libraries.md)
