# GrowLauncher GLSC v2 Decryptor

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Offline decryptor for **GrowLauncher** (`launcher.powerkuy.growlauncher`) **GLSC v2** encrypted Lua scripts (`libPowerKuy.so`).

No Frida, no Android device, and no external npm packages required — pure Node.js.

## Features
- Extracts the self-contained 32-byte key interleaved across the GLSC v2 payload (`sub_470B74`)
- Reconstructs the RC4-based inverse S-box (`sub_470BEC`), SHA-256 key schedule, and 8-bit Fisher-Yates permutation table (`sub_470CC8`)
- Replicates the chained byte-by-byte decryption pipeline (`sub_470DDC`)
- Full offline decryption directly to plaintext Lua

## Requirements
- [Node.js](https://nodejs.org/) v16 or higher (uses built-in `crypto` and `fs` modules only)

## Usage

```bash
node dec.js <input.lua> [output.lua]
```

**Examples:**

Decrypt and save to a file:
```bash
node dec.js encrypted.lua decrypted.lua
```

Preview the first 128 bytes in the terminal (omit output path):
```bash
node dec.js encrypted.lua
```

## GLSC v2 Format Overview
| Offset | Size | Description |
| :--- | :--- | :--- |
| `0x00 - 0x03` | 4 bytes | Magic header (`GLSC`) |
| `0x04` | 1 byte | Format version (`0x02`) |
| `0x05+` | Variable | Interleaved 32-byte key + encrypted payload |

### Decryption Flow
1. **Key Extraction**: Reads 32 key bytes placed at `floor((len * k) / 32)` for `k = 0..31`; remaining bytes form the ciphertext.
2. **Key Derivation**: Computes `SHA-256(key32)` for the key schedule, builds an RC4 KSA S-box (inverted for decryption), and generates an 8-bit permutation table via Fisher-Yates shuffle.
3. **Byte Pipeline**: For each byte `c = ciphertext[i]` (with `prev` initialized to `key32[0]`):
   - `inv_sbox[c]`
   - `(b - (prev + i)) & 0xFF`
   - `b ^= key32[(i + 7) & 31]`
   - 8-bit permutation (`bitPerm`)
   - 8-bit right rotation (`ror8`) using `keysched[i & 31]`
   - `inv_sbox[b]`
   - Update `prev = c`

## Disclaimer
This project is provided strictly for educational and reverse engineering research purposes.

## License
This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.
