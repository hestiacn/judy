<div align="center">

# Judy - 高性能动态数组库

> C 语言实现的超大规模稀疏动态数组，内存仅在实际使用时分配，支持 Peta 级别扩展。

**最新版本:** [![releases](https://img.shields.io/github/v/tag/hestiacn/judy)](https://github.com/hestiacn/judy/tags) | [![更新日志](https://img.shields.io/badge/📖_更新日志-点击查看-important)](CHANGELOG.md)

[![Version](https://img.shields.io/badge/version-1.0.6-blue)](https://github.com/hestiacn/judy)
[![License](https://img.shields.io/badge/license-LGPL%202.1-green)](COPYING)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20FreeBSD%20%7C%20HP--UX-lightgrey)]()
<br>
[📄 English](README.md) | [🐞 报告 Bug](https://github.com/hestiacn/judy/issues)

</div>

---

## 📖 目录

- [简介](#简介)
- [特别提示](#特别提示)
- [快速开始](#快速开始-linux)
- [从源码构建](#从源码构建)
- [Windows 包](#windows-包)
- [构建选项](#构建选项)
- [目录结构](#目录结构)
- [已知问题](#已知问题)

---

## 简介

Judy 是一个用 C 语言实现的高性能动态数组库。与传统的数组或哈希表不同，Judy 数组在声明时只是一个空指针 —— **只有在实际存储数据时才会占用内存**，同时可以动态扩展到物理内存极限。

Judy 数组支持数字或字符串索引的插入、检索和删除操作。无需配置和调优 —— 实际上也不可能。Judy 提供排序、计数和相邻/空位搜索功能。索引可以是顺序的、聚集的、周期性的或随机的 —— 对算法来说没有区别。Judy 数组可以分层排列来处理任意位模式 —— 大索引、键集合等。

### 为什么选择 Judy？

| 特性 | 说明 |
|------|------|
| ⚡ **高性能** | 时间复杂度接近 O(log₂₅₆ n)，数据量增 256 倍仅多一次内存访问 |
| 💾 **极致内存效率** | 空数组零内存占用，按需分配，无内部碎片 |
| 🔧 **零配置** | 无需调优、无需预设大小、无需选择哈希函数 |
| 📈 **极致扩展** | 从 0 到 Peta 级别元素无缝扩展 |
| 🎯 **通用索引** | 支持数字和字符串索引；顺序/聚集/周期/随机分布均不影响性能 |

### 与传统数据结构的对比

Judy 在多数场景下优于：数组、稀疏数组、哈希表、B 树、二叉树、线性链表、跳表等。

### 本分支 (v1.0.6)

由 **HestiaCN** 维护，在官方版本基础上新增：

- 🖥️ **跨平台运行时编译器自动检测**：运行时自动检测 CC/CXX 编译器
- 🔒 **现代编译器支持**：为 Clang 15+ 严格模式添加显式兼容标志
- 📦 **Windows 批处理移植**：完整移植 JudyL / JudySL / JudyHS 模块的构建逻辑
- 🛡️ **强化共享库构建**：加固 `-fPIC` 处理，确保正确生成 `.so` 文件
- 🔗 **pkg-config 支持**：安装 `judy.pc` 文件，方便与其他项目集成
- 🪟 **MSVC 原生支持**：通过 `build.bat` 在 Windows 上使用 MSVC 编译器构建 32/64 位 DLL
- 🪟 **MSYS2/MinGW-w64 支持**：新增通过 MSYS2 环境在 Windows 上 (i686 和 x86_64) 的完整构建支持
---

## 特别提示

由于在`build.sh`脚本引入了 `judy.pc` 文件的自动复制机制，编译流程现需依赖 `pkg-config` (或 `pkgconf`) 工具。
请根据您所使用的系统环境，选择对应的命令进行安装：

- **Unix / FreeBSD**: `pkg install pkgconf`
- **Debian / Ubuntu / Mint**: `apt install pkg-config`
- **Fedora**: `dnf install pkgconf` (最新版可使用 `dnf5 install pkgconf`)
- **RHEL / CentOS / Rocky**: `dnf install pkgconf` (或旧系统使用 `yum install pkgconfig`)
- **Arch Linux / Manjaro**: `pacman -S pkgconf`
- **Alpine Linux**: `apk add pkgconfig`
- **openSUSE / SLES**: `zypper install pkg-config`
- **macOS (Homebrew)**: `brew install pkg-config`

### 请安装后再次执行以下命令即可！

```bash
cd judy-1.0.6/src
sh build.sh
```

### 💡 为什么加入了 judy.pc？（技术背景说明）

Judy Array 是一个性能极高、但极其古老的 C 语言库。由于历史原因，它在现代多平台编译中存在一个致命的"顽疾"，而引入 `judy.pc` 正是为了彻底根治它：

**1. 解决官方没有包配置文件的遗留问题**

现代大型软件编译时，统一使用 `pkg-config` 工具来寻找第三方库。但 Judy 太古老了，官方源码根本没有提供 `judy.pc` 配置文件，导致编译器经常因为"找不到 Judy"而报错中断。

**2. 抹平不同系统的"路径鸿沟"**

不同操作系统对第三方库的存放规则完全不同：
- Linux 系统: `/usr/lib/` 和 `/usr/include/`
- Unix 系统: `/usr/local/lib/` 和 `/usr/local/include/`

如果不引入 `.pc` 文件，编译脚本就需要写大量 if/else 来硬编码判断系统路径，臃肿且易错。

而 `judy.pc` 配合 `pkg-config` 工具，`build.sh` 会在编译时自动适配不同系统的路径差异，无需用户手动干预。

这也是为什么在编译前，我们建议您先安装 `pkg-config` (或 `pkgconf`) 工具，避免编译报错。

---

## 快速开始 (Linux)

在 Linux 系统上，你可以通过以下步骤从源码构建并安装 Judy：

```bash
# 克隆仓库
git clone https://github.com/hestiacn/judy.git
cd judy

# 生成构建系统（首次运行或更新构建文件后需要）
./bootstrap

# 配置（自动检测本地架构）
./configure

# 编译
make

# 运行测试（推荐）
make check

# 安装到系统（默认 /usr/local，可能需要 sudo）
sudo make install
```

> **注意**：`./bootstrap` 用于生成 `configure` 脚本，只需在首次克隆或构建文件更新后运行一次。日常开发中，直接使用 `./configure` 即可。

---

## 从源码构建

如果您需要自定义编译选项，或想在自己的环境中从源码构建 Judy，可以克隆本仓库或下载源码包进行自动构建：

```bash
# 克隆仓库
git clone https://github.com/hestiacn/judy.git
cd judy

# 或下载源码包
wget https://github.com/hestiacn/judy/archive/refs/tags/v1.0.6.tar.gz
tar -xzf v1.0.6.tar.gz
cd judy-1.0.6

# 生成构建系统并编译
./bootstrap
./configure
make
sudo make install
```

详细的构建选项和平台示例请参考下方的 [构建选项](#构建选项) 章节。

---

## Windows 包

预构建的 Windows 包可在 GitHub Release 中获取：

### MSVC (Visual Studio)

```
v1.0.6/
├── judy-windows-msvc-x86.zip
│   ├── Judy.dll
│   ├── Judy.lib
│   └── checksums.txt
└── judy-windows-msvc-x64.zip
    ├── Judy.dll
    ├── Judy.lib
    └── checksums.txt
```

### MSYS2 (MinGW-w64)

```
v1.0.6/
├── judy-windows-msys2-mingw-x86.zip
│   └── i686/
│       ├── libjudy-1.0.6-1-i686.pkg.tar.zst
│       ├── libjudy-devel-1.0.6-1-i686.pkg.tar.zst
│       └── checksums.txt
└── judy-windows-msys2-mingw-x64.zip
    └── x86_64/
        ├── libjudy-1.0.6-1-x86_64.pkg.tar.zst
        ├── libjudy-devel-1.0.6-1-x86_64.pkg.tar.zst
        └── checksums.txt
```

### 校验 SHA256 校验和

```bash
# MSVC 包
cd judy-windows-msvc-x86
sha256sum -c checksums.txt

# MSYS2 包
cd i686  # 或 x86_64
sha256sum -c checksums.txt
```

### 使用方法

#### MSVC (Visual Studio)

1.  解压 ZIP 包。
2.  将 `Judy.lib` 添加到项目的链接器输入中。
3.  确保 `Judy.dll` 在 PATH 环境变量中，或与可执行文件放在同一目录下。
4.  在源代码中包含 `Judy.h`。

```c
#include "Judy.h"

// 链接 Judy.lib
```

#### MSYS2 (MinGW-w64)

使用 `pacman` 安装包：

```bash
# 32位
pacman -U i686/libjudy-1.0.6-1-i686.pkg.tar.zst
pacman -U i686/libjudy-devel-1.0.6-1-i686.pkg.tar.zst

# 64位
pacman -U x86_64/libjudy-1.0.6-1-x86_64.pkg.tar.zst
pacman -U x86_64/libjudy-devel-1.0.6-1-x86_64.pkg.tar.zst
```

安装后，库和头文件将可在 MSYS2 环境中使用。

---

## 构建选项

### 快速开始

```bash
# 1. 生成构建系统（必需）
./bootstrap

# 2. 配置（自动检测本地架构）
./configure

# 3. 构建
make

# 4. 运行测试（可选）
make check

# 5. 安装（默认安装到 /usr/local）
sudo make install
```

### 安装到自定义目录

```bash
# 安装到临时目录进行测试
./bootstrap
./configure --prefix=/tmp/judy-install
make
make install

# 安装到用户本地目录
./bootstrap
./configure --prefix=$HOME/local
make
make install

# 安装到系统目录（需要 root 权限）
./bootstrap
./configure --prefix=/usr
make
sudo make install
```

### 32位 / 64位

Judy 可以构建为 32位或 64位库。`configure` 会自动检测本地环境并使用相应的默认值。要显式指定非本地架构：

```bash
# 生成构建系统
./bootstrap

# 强制 32位
./configure --enable-32-bit

# 强制 64位
./configure --enable-64-bit

make
make install
```

### 平台示例

#### Linux AMD64 (x86_64)

```bash
./bootstrap

# 本地 64位（默认）
./configure
make
make check
sudo make install

# 强制 32位
./configure --enable-32-bit
make
make check
sudo make install
```

#### HP-UX PA-RISC

```bash
./bootstrap

# 本地 32位（默认）
./configure
make
make check
make install

# 64位
CFLAGS=+DD64 ./configure --enable-64-bit
make
make check
make install
```

> 💡 **注意**：`./bootstrap` 用于生成 `configure` 脚本，只需运行一次。日常开发中，直接使用 `./configure` 即可。

> **注意**：同时支持 32位和 64位运行时环境的机器（如 RISC 平台和 x86-64）可能默认使用其中一种。如果你想为非默认目标类型编译，**你需要自行设置正确的编译标志**，例如设置 `CFLAGS` 让编译器切换模式，以及设置 `LDFLAGS` 让链接器正常工作。

---

## 目录结构

```bash
judy/
├── src/           # 头文件和源文件
├── doc/           # 文档（外部和内部）
├── test/          # 测试支持和计时程序
├── tool/          # 工具（jhton: HTML → man 页面转换器）
│                  # 注：包含最新版 config.guess 和 config.sub，供 bootstrap 复制到根目录
├── examples/      # 示例程序
├── packaging/     # 打包相关（MSYS2 PKGBUILD 等）
├── .github/       # GitHub Actions CI/CD 配置 -win 配置自动生成相关脚本
├── bootstrap      # 引导脚本（生成构建系统，并复制 tool/config.* 到根目录）
├── configure.ac   # Autoconf 配置模板
├── Makefile.am    # Automake 模板
├── configure      # Autoconf 生成的可执行脚本
├── Makefile.in    # Automake 生成的模板文件
├── config.guess   # 由 bootstrap 从 tool/ 复制
├── config.sub     # 由 bootstrap 从 tool/ 复制
├── AUTHORS        # 作者和贡献者
├── COPYING        # 许可证 (LGPL 2.1)
├── INSTALL        # 安装说明
├── CHANGELOG.md   # 更新日志
├── README.md      # 英文说明
└── README-zh_CN.md # 中文说明
```

---

## 已知问题

**HP-UX 编译错误**：可能出现 `error 1000: Unexpected symbol:`。这是 HP 编译器的问题，它不喜欢 `static inline` 后面跟 typedef 类型。

```bash
# 解决方案（在 Judy 目录下执行）
find ./ -name \*.[ch] | xargs perl -i.BAK -pe 's/static inline/static/g'
```

---

<p align="center">
  <sub>由 <a href="https://github.com/hestiacn">HestiaCN</a> 维护的分支 | 原作者 <a href="https://sourceforge.net/projects/judy/">Doug Baskins</a></sub>
</p>