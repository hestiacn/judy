# 🌐 Judy 库多架构交叉编译与部署完整教程

<div align="center">

[**English**](#english-version) | [**中文**](#中文版本)

</div>

---

# 中文版本

<a id="中文版本"></a>

## 目录

- [一、交叉编译环境搭建](#一交叉编译环境搭建)
  - [1.1 核心依赖安装](#11-核心依赖安装)
  - [1.2 扩展包（备忘）](#12-备忘应对未来复杂-c-项目的扩展包)
- [二、Judy 库编译与安装](#二judy-库编译与安装以-arm32-armhf-为例)
  - [2.1 刷新配置脚本](#21-刷新配置脚本)
  - [2.2 执行配置](#22-执行配置)
  - [2.3 导入 QEMU 动态链接前缀](#23-核心避坑导入-qemu-动态链接前缀)
  - [2.4 编译与安装](#24-编译与安装)
- [三、编译结果验证](#三编译结果验证)
- [四、目标板部署与应用开发](#四目标板部署与应用开发)
  - [4.1 宿主机端二次交叉编译](#41-宿主机端二次交叉编译链接-judy-库)
  - [4.2 打包并拷贝至目标板](#42-打包并拷贝至目标板)
  - [4.3 板端配置动态链接路径](#43-板端避坑配置动态链接路径)
- [五、快速参考卡片](#五快速参考卡片)
- [六、清理与重新生成](#六清理与重新生成)

---

## 一、交叉编译环境搭建

Debian/Ubuntu 系统使用 APT 包管理器。

### 1.1 核心依赖安装

```bash
apt update && apt install -y  gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu gcc-loongarch64-linux-gnu qemu-user-static
```

### 1.2 【备忘】应对未来复杂 C++ 项目的扩展包

```bash
apt install -y g++-arm-linux-gnueabihf g++-aarch64-linux-gnu build-essential pkg-config automake autoconf libtool
```

---

## 二、Judy 库编译与安装（以 ARM32 armhf 为例）

进入源码根目录，按以下步骤执行：

### 2.1 刷新配置脚本

```bash
./bootstrap
```

### 2.2 执行配置

```bash
# ARM32 (armhf)
./configure --host=arm-linux-gnueabihf --prefix=/tmp/judy-armhf

# ARM64 (aarch64)
./configure --host=aarch64-linux-gnu --prefix=/tmp/judy-arm64

# 龙芯 (loongarch64)
./configure --host=loongarch64-linux-gnu --prefix=/tmp/judy-loong64
```

### 2.3 【核心避坑】导入 QEMU 动态链接前缀

执行 `make` 前，必须设置 QEMU_LD_PREFIX 环境变量：

| 目标架构 | 命令 |
|----------|------|
| ARM32 (armhf) | `export QEMU_LD_PREFIX=/usr/arm-linux-gnueabihf` |
| ARM64 (aarch64) | `export QEMU_LD_PREFIX=/usr/aarch64-linux-gnu` |
| 龙芯64 (loongarch64) | `export QEMU_LD_PREFIX=/usr/loongarch64-linux-gnu` |

### 2.4 编译与安装

```bash
make && make install
```

---

## 三、编译结果验证

```bash
file /tmp/judy-armhf/lib/libJudy.so.1.0.3
```

期望输出示例：
```bash
root@debian:/tmp/judy-1.0.6# file /tmp/judy-armhf/lib/libJudy.so.1.0.3
/tmp/judy-armhf/lib/libJudy.so.1.0.3: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, BuildID[sha1]=8b5987fb085519d0acbeecbe0e8433d7c3c6d819, with debug_info, not stripped
```

---

## 四、目标板部署与应用开发

### 4.1 宿主机端二次交叉编译（链接 Judy 库）

```bash
# ARM32
arm-linux-gnueabihf-gcc main.c -o my_app \
  -I/tmp/judy-armhf/include \
  -L/tmp/judy-armhf/lib \
  -lJudy

# ARM64
aarch64-linux-gnu-gcc main.c -o my_app \
  -I/tmp/judy-arm64/include \
  -L/tmp/judy-arm64/lib \
  -lJudy

# 龙芯
loongarch64-linux-gnu-gcc main.c -o my_app \
  -I/tmp/judy-loong64/include \
  -L/tmp/judy-loong64/lib \
  -lJudy
```

### 4.2 打包并拷贝至目标板

```bash
cd /tmp/judy-armhf
tar -czvf judy-target.tar.gz include/ lib/
```

将 `judy-target.tar.gz` 和 `my_app` 拷贝至目标板，解压到 `/opt/judy/`：

```bash
tar -xzvf judy-target.tar.gz -C /opt/judy/
```

### 4.3 【板端避坑】配置动态链接路径

**临时生效（当前终端）：**
```bash
export LD_LIBRARY_PATH=/opt/judy/lib:$LD_LIBRARY_PATH
./my_app
```

**永久生效：**
```bash
echo "/opt/judy/lib" > /etc/ld.so.conf.d/judy.conf
ldconfig
```

---

## 五、快速参考卡片

### 常用路径汇总

| 项目 | 路径 |
|------|------|
| Judy 源码 | `/tmp/judy-1.0.6/` |
| 安装目录（ARM32） | `/tmp/judy-armhf/` |
| 头文件 | `/tmp/judy-armhf/include/Judy.h` |
| 共享库 | `/tmp/judy-armhf/lib/libJudy.so.1.0.3` |
| 静态库 | `/tmp/judy-armhf/lib/libJudy.a` |
| pkg-config 文件 | `/tmp/judy-armhf/lib/pkgconfig/judy.pc` |

> **注意**：`judy.pc` 文件默认由 pkg-config 安装到系统目录，请执行 `pkg-config --variable=pc_path pkg-config | cut -d: -f1` 查看系统路径后，复制到 `/tmp/judy-armhf/lib/pkgconfig/`。

### 常用编译命令

```bash
# 生成 configure
./bootstrap

# 配置
./configure --host=arm-linux-gnueabihf --prefix=/tmp/judy-armhf

# 编译
make

# 安装
make install

# 使用 pkg-config 编译
export PKG_CONFIG_PATH=/tmp/judy-armhf/lib/pkgconfig:$PKG_CONFIG_PATH
arm-linux-gnueabihf-gcc $(pkg-config --cflags judy) -o my_app my_app.c $(pkg-config --libs judy)
```

---

## 六、清理与重新生成

如果修改了项目内的相关代码（不仅限于 `configure.ac` 或 `Makefile.am`），需要完全重新生成构建系统：

```bash
make distclean
rm -rf autom4te.cache aclocal.m4 configure config.h.in
```

### 为什么要这样做？

| 步骤 | 作用 |
|------|------|
| `make distclean` | 清除所有编译产物（`.o`、`.a`、`.so`、`Makefile` 等），恢复到刚解压的状态 |
| `rm -rf autom4te.cache` | 删除 autoconf 缓存，避免旧宏定义干扰 |
| `rm -f aclocal.m4 configure config.h.in` | 删除 autotools 生成的旧文件，强制重新生成 |

如果不做这些清理，`./bootstrap` 可能会跳过某些步骤，导致修改不生效或出现奇怪的问题。

## 七、贡献指南

本指南仅在 Debian 系统验证通过。如果您在其他 Linux 发行版（如 RedHat、Arch）或 FreeBSD 上成功移植，欢迎提交 Pull Request 完善文档！

---

**文档版本**：1.0  
**适用 Judy 版本**：1.0.6  
**更新日期**：2026-07-31

---

# English Version

<a id="english-version"></a>

## Table of Contents

- [I. Cross-Compilation Environment Setup](#i-cross-compilation-environment-setup)
  - [1.1 Core Dependencies Installation](#11-core-dependencies-installation)
  - [1.2 Extension Packages (Cheatsheet)](#12-extension-packages-cheatsheet-for-future-complex-c-projects)
- [II. Building and Installing Judy Library](#ii-building-and-installing-judy-library-using-arm32-armhf-as-an-example)
  - [2.1 Refresh Configuration Scripts](#21-refresh-configuration-scripts)
  - [2.2 Run Configuration](#22-run-configuration)
  - [2.3 Import QEMU Dynamic Linker Prefix](#23-critical-pitfall-import-qemu-dynamic-linker-prefix)
  - [2.4 Build and Install](#24-build-and-install)
- [III. Verify Build Results](#iii-verify-build-results)
- [IV. Target Board Deployment and Application Development](#iv-target-board-deployment-and-application-development)
  - [4.1 Secondary Cross-Compilation on Host Machine](#41-secondary-cross-compilation-on-host-machine-linking-against-judy-library)
  - [4.2 Package and Copy to Target Board](#42-package-and-copy-to-target-board)
  - [4.3 Configure Dynamic Linker Path on Target Board](#43-target-board-pitfall-configure-dynamic-linker-path)
- [V. Quick Reference Card](#v-quick-reference-card)
- [VI. Cleanup and Regeneration](#vi-cleanup-and-regeneration)
- [VII. Contribution Guidelines](#vii-contribution-guidelines)

---

## I. Cross-Compilation Environment Setup

Debian/Ubuntu systems use the APT package manager.

### 1.1 Core Dependencies Installation

```bash
apt update && apt install -y  gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu gcc-loongarch64-linux-gnu qemu-user-static
```

### 1.2 Extension Packages (Cheatsheet for Future Complex C++ Projects)

```bash
apt install -y g++-arm-linux-gnueabihf g++-aarch64-linux-gnu build-essential pkg-config automake autoconf libtool
```

---

## II. Building and Installing Judy Library (Using ARM32 armhf as an Example)

Navigate to the source code root directory and execute the following steps:

### 2.1 Refresh Configuration Scripts

```bash
./bootstrap
```

### 2.2 Run Configuration

```bash
# ARM32 (armhf)
./configure --host=arm-linux-gnueabihf --prefix=/tmp/judy-armhf

# ARM64 (aarch64)
./configure --host=aarch64-linux-gnu --prefix=/tmp/judy-arm64

# LoongArch64 (loongarch64)
./configure --host=loongarch64-linux-gnu --prefix=/tmp/judy-loong64
```

### 2.3 [Critical Pitfall] Import QEMU Dynamic Linker Prefix

Before executing `make`, you **must** set the `QEMU_LD_PREFIX` environment variable:

| Target Architecture | Command |
|---------------------|---------|
| ARM32 (armhf) | `export QEMU_LD_PREFIX=/usr/arm-linux-gnueabihf` |
| ARM64 (aarch64) | `export QEMU_LD_PREFIX=/usr/aarch64-linux-gnu` |
| LoongArch64 | `export QEMU_LD_PREFIX=/usr/loongarch64-linux-gnu` |

### 2.4 Build and Install

```bash
make && make install
```

---

## III. Verify Build Results

```bash
file /tmp/judy-armhf/lib/libJudy.so.1.0.3
```

Expected output example:
```bash
root@debian:/tmp/judy-1.0.6# file /tmp/judy-armhf/lib/libJudy.so.1.0.3
/tmp/judy-armhf/lib/libJudy.so.1.0.3: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, BuildID[sha1]=8b5987fb085519d0acbeecbe0e8433d7c3c6d819, with debug_info, not stripped
```

---

## IV. Target Board Deployment and Application Development

### 4.1 Secondary Cross-Compilation on Host Machine (Linking Against Judy Library)

```bash
# ARM32
arm-linux-gnueabihf-gcc main.c -o my_app \
  -I/tmp/judy-armhf/include \
  -L/tmp/judy-armhf/lib \
  -lJudy

# ARM64
aarch64-linux-gnu-gcc main.c -o my_app \
  -I/tmp/judy-arm64/include \
  -L/tmp/judy-arm64/lib \
  -lJudy

# LoongArch64
loongarch64-linux-gnu-gcc main.c -o my_app \
  -I/tmp/judy-loong64/include \
  -L/tmp/judy-loong64/lib \
  -lJudy
```

### 4.2 Package and Copy to Target Board

```bash
cd /tmp/judy-armhf
tar -czvf judy-target.tar.gz include/ lib/
```

Copy `judy-target.tar.gz` and `my_app` to the target board, then extract to `/opt/judy/`:

```bash
tar -xzvf judy-target.tar.gz -C /opt/judy/
```

### 4.3 [Target Board Pitfall] Configure Dynamic Linker Path

**Temporary (current terminal session only):**
```bash
export LD_LIBRARY_PATH=/opt/judy/lib:$LD_LIBRARY_PATH
./my_app
```

**Permanent:**
```bash
echo "/opt/judy/lib" > /etc/ld.so.conf.d/judy.conf
ldconfig
```

---

## V. Quick Reference Card

### Common Paths Summary

| Item | Path |
|------|------|
| Judy source code | `/tmp/judy-1.0.6/` |
| Installation directory (ARM32) | `/tmp/judy-armhf/` |
| Header file | `/tmp/judy-armhf/include/Judy.h` |
| Shared library | `/tmp/judy-armhf/lib/libJudy.so.1.0.3` |
| Static library | `/tmp/judy-armhf/lib/libJudy.a` |
| pkg-config file | `/tmp/judy-armhf/lib/pkgconfig/judy.pc` |

> **Note**: The `judy.pc` file is typically installed to the system directory by pkg-config. Run `pkg-config --variable=pc_path pkg-config | cut -d: -f1` to check the system path, then copy it to `/tmp/judy-armhf/lib/pkgconfig/`.

### Common Build Commands

```bash
# Generate configure
./bootstrap

# Configure
./configure --host=arm-linux-gnueabihf --prefix=/tmp/judy-armhf

# Build
make

# Install
make install

# Compile using pkg-config
export PKG_CONFIG_PATH=/tmp/judy-armhf/lib/pkgconfig:$PKG_CONFIG_PATH
arm-linux-gnueabihf-gcc $(pkg-config --cflags judy) -o my_app my_app.c $(pkg-config --libs judy)
```

---

## VI. Cleanup and Regeneration

If you modify any code within the project (not limited to `configure.ac` or `Makefile.am`), you need to completely regenerate the build system:

```bash
make distclean
rm -rf autom4te.cache aclocal.m4 configure config.h.in
```

### Why is this necessary?

| Step | Purpose |
|------|---------|
| `make distclean` | Remove all build artifacts (`.o`, `.a`, `.so`, `Makefile`, etc.), restoring to the fresh unpacked state |
| `rm -rf autom4te.cache` | Delete autoconf cache to avoid interference from old macro definitions |
| `rm -f aclocal.m4 configure config.h.in` | Remove old autotools-generated files to force regeneration |

Without these cleanup steps, `./bootstrap` may skip certain processes, causing changes to not take effect or leading to unexpected issues.

---

## VII. Contribution Guidelines

This guide has only been verified on Debian systems. If you have successfully ported it to other Linux distributions (such as RedHat, Arch) or FreeBSD, we welcome you to submit a Pull Request to improve the documentation!

When contributing, please follow the existing format and maintain structural consistency.

---

**Document Version**: 1.0  
**Applicable Judy Version**: 1.0.6  
**Last Updated**: 2026-07-31