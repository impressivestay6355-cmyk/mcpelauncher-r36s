# Licenses

License texts of the third-party components included in the
`mcpelauncher-client` binaries and the port. The launcher itself is
GPL-3.0, see [LICENSE](../LICENSE).

| File | Component | License |
|---|---|---|
| SDL3.txt | SDL3 | zlib |
| imgui.txt | Dear ImGui | MIT |
| curl.txt | curl | curl (MIT-style) |
| OpenSSL-1.1.1.txt | OpenSSL 1.1.1w | OpenSSL / SSLeay |
| zlib.txt | zlib | zlib |
| libpng.txt | libpng | libpng |
| libc++.txt, libc++abi.txt | LLVM libc++ / libc++abi | Apache-2.0 with LLVM exception |
| mcpelauncher-*.txt | minecraft-linux support libraries | MIT / public domain (Unlicense) |
| AOSP-*-NOTICE.txt | Android bionic / system core code used by mcpelauncher-linker and the bundled libc.so / libm.so | Apache-2.0 / BSD (see files) |
| libc-shim-NOTICE.txt | BSD / ISC code inside libc-shim | BSD / ISC |
| Mozilla-CA-bundle-MPL-2.0.txt | Mozilla CA certificate bundle (`mcpe_launcher/mcpelauncher/cacert.pem`) | MPL-2.0 |

## Bundled shared libraries (`mcpe_launcher/lib/`)

| File | Component | License |
|---|---|---|
| glibc-LGPL-2.1.txt | glibc libs (libm, libdl, libpthread, librt) | LGPL-2.1 |
| GCC-runtime-exception.txt | libgcc_s, libatomic | GPL-3.0 with GCC Runtime Library Exception |
| OpenSSL-3-Apache-2.0.txt | libssl.so.3, libcrypto.so.3 | Apache-2.0 |
| libc++.txt | libc++_shared.so | Apache-2.0 with LLVM exception |
| (MIT) | libgbm.so.1 (Mesa) | MIT |

These are unmodified upstream builds. Their source code is available from
the respective upstream projects (glibc, GCC, OpenSSL, LLVM, Mesa), and on
request as stated in [LEGAL.md](../LEGAL.md).
