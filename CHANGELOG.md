# Changelog

All notable changes to this project are documented in this file.

### v1.0.6 (July 30, 2026) — HestiaCN

**Build System & Portability**
*   🖥️ **Cross-platform build system**: Auto-detects CC/CXX compiler (Clang/GCC) at runtime.
*   🔒 **Modern compiler support**: Added explicit compatibility flags for Clang 15+ strict mode.
*   📦 **Windows batch build port**: Full port of build logic for JudyL / JudySL / JudyHS modules.
*   🛡️ **Hardened shared library build**: Reinforced `-fPIC` handling to ensure correct `.so` generation.
*   📝 **Standardized build scripts**: Renamed `sh_build` to `build.sh` for consistency.
*   🔗 **pkg-config support**: Installs `judy.pc` file for easy integration with other projects.
*   🏗️ **VPATH build support**: Allows out-of-source builds using `../configure`.
*   🪟 **Native MSVC support**: Build 32/64-bit DLLs on Windows using MSVC compiler via `build.bat`.
*   🪟 **MSYS2/MinGW-w64 support**: Added full build support on Windows (i686 and x86_64) via MSYS2 environment.
*   📦 **Updated GNU core components**: Upgraded `config.guess` and `config.sub` to latest GNU official versions (2026-05-17), significantly improved architecture detection with native support for riscv64, loongarch, kvx and other modern platforms [#31](https://sourceforge.net/p/judy/bugs/31/).
*   📁 **Resolved build conflict (obj → libobj rename)**: Renamed `src/obj/` directory to `src/libobj/`. Since `obj` is a reserved directory name keyword in various mainstream build systems and platform toolchains, using it directly may cause unexpected build warnings or dependency conflicts. Renaming to `libobj` eliminates namespace pollution in the build tree and more accurately reflects the directory's purpose — housing the final library files.
*   📁 **Fixed source file copy paths**: Corrected `cp` paths in each submodule's `Makefile.am` to use `$(top_srcdir)` instead of relative paths.
*   🔧 **Fixed Automake include paths**: Updated `INCLUDES` variable to `AM_CPPFLAGS` and replaced relative paths with `$(top_srcdir)`/`$(top_builddir)` to ensure VPATH and out-of-source build reliability.
*   🔗 **Fixed libtool library linking**: Corrected `libJudy_la_LIBADD` paths in `src/libobj/Makefile.am` using `$(top_builddir)`.
*   🐞 **Fixed parallel builds**: Resolved race condition in man page generation (`JSLD` target dependency) in `doc/Makefile.am` — [#4](https://sourceforge.net/p/judy/patches/4/), [#29](https://sourceforge.net/p/judy/bugs/29/).
*   🐞 **Fixed MSYS2 doc build**: Creates `man/man3` directory before installing man pages to resolve "No such file or directory" error.
*   📋 **Enhanced build logging**: Added detailed logging with automatic output of last 300 lines on error.
*   🔄 **GitHub Actions CI/CD**: Automatically builds MSVC (x64/x86) and MSYS2 (i686/x86_64) releases with artifacts uploaded.

**Build Reproducibility**
*   🕐 **Removed man page timestamps**: Eliminated `ctime()` calls in `jhton.c` for reproducible builds — [#7](https://sourceforge.net/p/judy/patches/7/).

**Compiler & Architecture Fixes**
*   🔧 **Fixed Win64 pointer truncation**: Changed `Word_t` from `unsigned long` to `uintptr_t`, resolving C4311/C4312 pointer-to-integer conversion warnings on 64-bit Windows.
*   🔧 **Fixed MSVC DLL export**: Added `JUDY_API` macro providing `__declspec(dllexport/dllimport)` for MSVC and `__attribute__((visibility("default")))` for MinGW, enabling cross-compiler DLL symbol export.
*   🔧 **New JudyHSDelGet API**: Added `JudyHSDelGet()` function that returns the deleted value when removing a JudyHS entry, resolving [#23](https://sourceforge.net/p/judy/feature-requests/23/) regarding "delete without return value". Users no longer need to call `JudyHSGet()` before deletion — **delete + retrieve reduced from 2 lookups to 1**.
*   🐞 **Fixed GCC 4.9+ optimization bug**: Resolved miscompilation affecting Judy1 on 64-bit systems with `-O2`/`-O3` — [#5](https://sourceforge.net/p/judy/patches/5/), [#25](https://sourceforge.net/p/judy/bugs/25/), [#28](https://sourceforge.net/p/judy/bugs/28/).
*   🐞 **Fixed `-O3 -fpeel-loops` undefined behavior**: Used `sizeof` instead of hardcoded array bounds in `Judy1Set.c` — [#28](https://sourceforge.net/p/judy/bugs/28/), [#30](https://sourceforge.net/p/judy/bugs/30/).
*   🐞 **Fixed JudyTablesGen include path**: Added `-I$(top_srcdir)/src` to `JudyLTablesGen` and `Judy1TablesGen` compile rules to resolve header file not found errors.
*   🐞 **Fixed 64-bit Judy1Tables generation**: Disabled Leaf1 table generation on 64-bit systems to avoid `cJ1_LEAF1_MAXPOP1` undefined errors.
*   🐞 **Fixed Win64 data model**: Added LLP64 support for MinGW64 builds via `INTPTR_C`/`UINTPTR_C` macros.
*   🐞 **Fixed `JudyMalloc.c` header resolution**: Added `-I$(top_srcdir)/src` to `AM_CPPFLAGS` in `src/JudyCommon/Makefile.am` to locate `Judy.h`.
*   🐞 **Fixed `JudyMalloc.c` DLL export conflict**: Added `-DJUDY_DLL_EXPORT` for MSVC builds of `JudyMalloc.c` to resolve C2491 `dllimport` function definition error.
*   🐞 **Fixed `JudyHSGet` function signature**: Added missing `P_JE` parameter to `JudyHSGet` to match declaration with definition.
*   🐞 **Fixed `JudyLInsArray` declaration placement**: Moved `P_JE` parameter to the correct position in function declaration.
*   🔧 **Fixed MSVC `-o` deprecation warning**: Replaced `-o` option with `/Fe:` in MSVC build scripts to eliminate D9035 warning.
*   🔧 **Fixed format string warnings**: Replaced `%ld` with `%zu` in `JudyTables.c` to eliminate C4477 warnings.

**Packaging & Integration**
*   📦 **Native MSVC packaging**: Automatically generates `Judy.dll` and `Judy.lib` via GitHub Actions, supporting x64/x86 dual architecture.
*   📦 **MSYS2 packaging support**: Added `packaging/msys2/PKGBUILD` for building and packaging on Windows.
*   🔗 **pkg-config file**: Added `judy.pc` for easy integration with other projects.

**Documentation**
*   📖 **Updated documentation**: Added Judy architecture overview and API reference.
*   📖 **Added bilingual support**: `README.md` (English) and `README-zh_CN.md` (Chinese).
*   📖 **Added CHANGELOG**: Uses standard modern `CHANGELOG.md` format replacing legacy `ChangeLog`.

**Examples**
*   💡 **JudyHS wrapper**: Added `examples/judyhs_wrapper.c` demonstrating how to bypass JudyHS limitations (return value on delete, memory usage tracking).
*   💡 **String map**: Added `examples/strmap.c` showcasing JudyL-based string key mapping with iteration support.
*   💡 **Test programs**: Added `test_strmap.c` and `test_wrapper.c` for example validation.

**Known Issues & Historical Limitations (To Be Addressed)**

* 📌 **[#22](https://sourceforge.net/p/judy/feature-requests/22/): Missing destructor**: When JudyHS stores pointers to dynamically allocated memory, the official implementation lacks a destructor mechanism. Users must manually manage memory deallocation using external auxiliary data structures, increasing complexity.
  - Reporter: Demetrios Obenour (2016-05-27)

* 📌 **[#23](https://sourceforge.net/p/judy/feature-requests/23/): Performance & functional limitations**: Costa Tsaousis, founder of [Netdata](https://github.com/netdata/netdata), reported the following issues after extensive usage:
  - **JudySL traversal bottleneck**: Iteration interfaces like `JudySLFirst()`/`JudySLNext()` copy internal keys into user-provided buffers (`strcpy()`/`memcpy()`) on each return. On large datasets (e.g., 1 billion entries), the copy overhead is enormous during full traversals, severely limiting JudySL's practicality in full-scan scenarios.
  - **JudyHS delete without return value**: `JudyHSDel()` only returns an `int`, unable to return the original `Word_t` value of the deleted item. Users needing to clean up associated external resources on deletion must call `JudyHSGet()` first to retrieve the value before deletion, significantly degrading delete performance.
  - *   **Status**: ✅ **This issue has been resolved in v1.0.6 with the new `JudyHSDelGet()` API.**
  - **JudyHS lacks iteration capability**: No official `JudyHSFirst()`, `JudyHSNext()` iteration interfaces exist (due to its internal hash-based unordered structure). For scenarios where order doesn't matter but full traversal is needed, users are forced to maintain an auxiliary doubly-linked list, significantly increasing memory overhead.
  - **Lack of real-time memory statistics**: `JudyHSFreeArray()` only returns freed bytes on destruction. Users cannot query current memory usage without destroying the array. An interface like `JudyXMemUsed()` is recommended.
  - Reporter: Costa Tsaousis (2022-05-29)

---

### v1.0.5 (May 2007) — twh

- 🧹 Added proper clean targets to enable multiple builds
- 📁 Added examples directory
- 🔍 Correctly detects 32/64-bit build environment
- ⚙️ Allow explicit configure for 32/64-bit environment

### v1.0.4 (May 2007) — twh

- 🐞 Fixed Checkit problem `error Judy1PrevEmpty Rcode != 1 = 0`
- 🐞 Fixed memory alignment in `JudyMallocIF.c`
- ✅ Fixed messages from `make check`

### v1.0.3 (Feb 2006) — twh

- 🔧 Fixed make files to break out each copy element as a unique target
- ♻️ Resolved issue where `make check` rebuilt the entire library

### v1.0.2 (Jan 2006) — twh

- 🐞 Fixed assumption of signed char in test programs
- 📝 Updated `sh_build`
- 📖 Fixed generation of man pages from HTML
- ⚙️ Fixed 32-bit and 64-bit configure

### v1.0.1 (Dec 2004) — twh

- 📦 Fixed bootstrap to use later versions
- 📖 Fixed manpage naming from `(3X)` to `(3)`
- 🔧 Code changes to support Microsoft `__inline` directive
- 📁 Moved away from symlinks to using copies
- 🪟 Added `build.bat` to support building on Windows

### v1.0.0 (Sept 2004) — twh

- 🔧 Complete Autoconfiscation of Judy
- 🗑️ Removed previous build environment
- 📌 Bumped to 1.0.0 to denote API change

### v0.1.6 (June 2004) — dlb

- 🔄 Endian-neutral version
- 🚀 Includes `JudyHS*()` — very fast, scalable string version (preliminary)
- 🐞 All `malloc()`/`free()` through interface routines in `JudyMalloc.c`
- 📁 `Judy.h` works on all ISO-compliant platforms
- 📝 Changed `<stdint.h>` to `<inttypes.h>` for portability
- ✅ Conforms to standard C
- 🐞 Hundreds of changes for portability