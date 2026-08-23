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

- Follow to Step 2, [here](/02-Building-required-libraries.md)
