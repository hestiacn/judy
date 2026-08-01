# 更新日志

这个项目的所有重大更改都会记录在这个文件里。

### v1.0.6 (2026年7月30日) — HestiaCN

**构建系统与可移植性**
*   🖥️ **跨平台构建系统**：运行时自动检测 CC/CXX 编译器 (Clang/GCC)。
*   🔒 **现代编译器支持**：为 Clang 15+ 严格模式添加显式兼容标志。
*   📦 **Windows 批处理移植**：完整移植 JudyL / JudySL / JudyHS 模块的构建逻辑。
*   🛡️ **强化共享库构建**：加固 `-fPIC` 处理，确保正确生成 `.so` 文件。
*   📝 **标准化构建脚本**：将 `sh_build` 重命名为 `build.sh` 以提高一致性。
*   🔗 **pkg-config 支持**：安装 `judy.pc` 文件，方便与其他项目集成。
*   🏗️ **VPATH 构建支持**：允许使用 `../configure` 进行源码外构建。
*   🪟 **MSVC 原生支持**：通过 `build.bat` 在 Windows 上使用 MSVC 编译器构建 32/64 位 DLL。
*   🪟 **MSYS2/MinGW-w64 支持**：新增通过 MSYS2 环境在 Windows 上 (i686 和 x86_64) 的完整构建支持。
*   📦 **更新 GNU 基础底层组件：将 config.guess 和 config.sub 升级至最新 GNU 官方版本 (2026-05-17)，全面改进架构检测能力，原生适配 riscv64, loongarch, kvx 等现代平台[#31](https://sourceforge.net/p/judy/bugs/31/)。
*   📁 **优化构建冲突（重命名 obj → libobj）**：将 `src/obj/` 目录重命名为 `src/libobj/`。由于 `obj` 是各类主流构建系统及平台底层工具链的保留目录名关键字，直接使用可能引发非预期的构建警告或依赖识别冲突。将其重命名为 `libobj`，既能从根本上消除构建树中的命名空间污染，也更精准地指明了该目录用于存放最终库文件的功能定位。
*   📁 **修复源文件复制路径**：修正各子模块 Makefile.am 中的 `cp` 路径，使用 `$(top_srcdir)` 替代相对路径。
*   🔧 **修复 Automake 包含路径**：将 `INCLUDES` 变量更新为 `AM_CPPFLAGS`，并替换相对路径为 `$(top_srcdir)`/`$(top_builddir)`，确保 VPATH 和源码外构建的可靠性。
*   🔗 **修复 libtool 库链接**：修正 `src/libobj/Makefile.am` 中 `libJudy_la_LIBADD` 的路径，使用 `$(top_builddir)`。
*   🐞 **修复并行构建**：解决 `doc/Makefile.am` 中 man 页面生成的竞态条件 (`JSLD` 目标依赖) —— [#4](https://sourceforge.net/p/judy/patches/4/), [#29](https://sourceforge.net/p/judy/bugs/29/)。
*   🐞 **修复 MSYS2 文档构建**：在安装 man 页面之前创建 `man/man3` 目录，解决 "No such file or directory" 错误。
*   📋 **增强构建日志**：新增详细日志记录功能，出错时自动输出最后 300 行日志。
*   🔄 **GitHub Actions CI/CD**：自动构建 MSVC (x64/x86) 和 MSYS2 (i686/x86_64) 版本，并上传 artifacts。

**构建可重现性**
*   🕐 **移除 man 页面时间戳**：消除 `jhton.c` 中的 `ctime()` 调用，实现可重现构建 —— [#7](https://sourceforge.net/p/judy/patches/7/)。

**编译器与架构修复**
*   🔧 **修复 Win64 指针截断问题**：将 `Word_t` 从 `unsigned long` 改为 `uintptr_t`，解决 64 位 Windows 下指针与整数转换的 C4311/C4312 警告。
*   🔧 **修复 MSVC DLL 导出**：添加 `JUDY_API` 宏，为 MSVC 提供 `__declspec(dllexport/dllimport)`，为 MinGW 提供 `__attribute__((visibility("default")))`，实现跨编译器 DLL 符号导出。
* 🔧 **新增 JudyHSDelGet API**：新增 `JudyHSDelGet()` 函数，在删除 JudyHS 条目时同时返回被删除的值，解决了 [#23](https://sourceforge.net/p/judy/feature-requests/23/) 中“删除不返回值”的问题。用户无需再额外调用 `JudyHSGet()` 获取值后再删除，单次操作即可完成，**删除 + 取值从 2 次查找降为 1 次**。
*   🐞 **修复 GCC 4.9+ 优化 bug**：解决 `-O2`/`-O3` 在 64 位系统上影响 Judy1 的误编译问题 —— [#5](https://sourceforge.net/p/judy/patches/5/), [#25](https://sourceforge.net/p/judy/bugs/25/), [#28](https://sourceforge.net/p/judy/bugs/28/)。
*   🐞 **修复 `-O3 -fpeel-loops` 未定义行为**：在 `Judy1Set.c` 中使用 `sizeof` 替代硬编码数组边界 —— [#28](https://sourceforge.net/p/judy/bugs/28/), [#30](https://sourceforge.net/p/judy/bugs/30/)。
*   🐞 **修复 JudyTablesGen 包含路径**：在 `JudyLTablesGen` 和 `Judy1TablesGen` 编译规则中添加 `-I$(top_srcdir)/src`，解决头文件找不到的错误。
*   🐞 **修复 64 位 Judy1Tables 生成**：在 64 位系统上禁用 Leaf1 表生成，避免 `cJ1_LEAF1_MAXPOP1` 未定义错误。
*   🐞 **修复 Win64 数据模型**：通过 `INTPTR_C`/`UINTPTR_C` 宏为 MinGW64 构建添加 LLP64 支持。
*   🐞 **修复 `JudyMalloc.c` 头文件解析**：在 `src/JudyCommon/Makefile.am` 的 AM_CPPFLAGS 中添加 `-I$(top_srcdir)/src` 以定位 `Judy.h`。
*   🐞 **修复 `JudyMalloc.c` DLL 导出冲突**：在 MSVC 构建中为 `JudyMalloc.c` 添加 `-DJUDY_DLL_EXPORT`，解决 C2491 `dllimport` 函数定义错误。
*   🐞 **修复 `JudyHSGet` 函数签名**：为 `JudyHSGet` 添加缺失的 `P_JE` 参数，使声明与定义一致。
*   🐞 **修复 `JudyLInsArray` 声明位置**：将 `P_JE` 参数移至函数声明的正确位置。
*   🔧 **修复 MSVC `-o` 弃用警告**：将 MSVC 构建脚本中的 `-o` 选项替换为 `/Fe:`，消除 D9035 警告。
*   🔧 **修复格式字符串警告**：将 `JudyTables.c` 中的 `%ld` 替换为 `%zu`，消除 C4477 警告。

**打包与集成**
*   📦 **MSVC 原生打包**：通过 GitHub Actions 自动生成 `Judy.dll` 和 `Judy.lib`，支持 x64/x86 双架构。
*   📦 **MSYS2 打包支持**：添加 `packaging/msys2/PKGBUILD` 用于在 Windows 上构建和打包。
*   🔗 **pkg-config 文件**：添加 `judy.pc` 方便与其他项目集成。

**文档**
*   📖 **更新文档**：添加 Judy 架构概述和 API 参考。
*   📖 **添加双语支持**：`README.md` (英文) 和 `README-zh_CN.md` (中文)。
*   📖 **添加 CHANGELOG**：使用标准现代的 `CHANGELOG.md` 格式替代旧的 `ChangeLog`。

**示例**
*   💡 **JudyHS 封装**：添加 `examples/judyhs_wrapper.c`，演示如何绕过 JudyHS 的限制 (删除时返回值、内存使用跟踪)。
*   💡 **字符串映射**：添加 `examples/strmap.c`，展示基于 JudyL 的字符串键映射及迭代支持。
*   💡 **测试程序**：添加 `test_strmap.c` 和 `test_wrapper.c` 用于示例验证。

**已知问题与历史局限（待后续跟进）**

* 📌 **[#22](https://sourceforge.net/p/judy/feature-requests/22/)：析构函数缺失**：当 JudyHS 中存储的值为指向动态分配内存的指针时，官方实现缺乏析构机制，用户需借助外部辅助数据结构手动管理内存释放，增加了使用复杂度。
  - 报告者：Demetrios Obenour (2016-05-27)

* 📌 **[#23](https://sourceforge.net/p/judy/feature-requests/23/)：性能与功能局限**：[Netdata](https://github.com/netdata/netdata) 创始人 Costa Tsaousis 在深度使用中反馈了以下问题：
  - **JudySL 遍历性能瓶颈**：`JudySLFirst()`/`JudySLNext()` 等遍历接口每次返回时都会将内部键拷贝到用户提供的缓冲区（`strcpy()`/`memcpy()`）。在大规模数据集（如 10 亿条目）上全量遍历时，拷贝开销巨大，严重限制了 JudySL 在需要全量扫描场景下的实用性。
  - **JudyHS 删除不返回值**：`JudyHSDel()` 仅返回 `int` 类型，无法返回被删除项的原始 `Word_t` 值。用户若需要在删除时清理关联的外部资源，必须额外调用 `JudyHSGet()` 先取值再删除，使删除操作性能大幅下降。
  - *   **状态**：✅ **此问题已在 v1.0.6 中通过新增 `JudyHSDelGet()` API 解决。**
  - **JudyHS 缺乏遍历能力**：官方未提供 `JudyHSFirst()`、`JudyHSNext()` 等遍历接口（因其内部为哈希无序结构）。对于不关心顺序但需要遍历全部元素的场景，用户被迫额外维护双链表，显著增加了内存开销。
  - **缺乏实时内存统计**：`JudyHSFreeArray()` 仅在销毁时返回释放的字节数。用户无法在不销毁数组的情况下获知其当前内存占用量，建议增加 `JudyXMemUsed()` 类接口。
  - 报告者：Costa Tsaousis (2022-05-29)

---

### v1.0.5 (2007年5月) — twh

- 🧹 添加正确的清理目标以支持多次构建
- 📁 添加示例目录
- 🔍 正确检测 32/64 位构建环境
- ⚙️ 允许显式配置 32/64 位环境

### v1.0.4 (2007年5月) — twh

- 🐞 修复 Checkit 问题 `error Judy1PrevEmpty Rcode != 1 = 0`
- 🐞 修复 `JudyMallocIF.c` 中的内存对齐问题
- ✅ 修复 `make check` 的消息输出

### v1.0.3 (2006年2月) — twh

- 🔧 修复 make 文件，将每个复制元素拆分为独立目标
- ♻️ 解决 `make check` 重建整个库的问题

### v1.0.2 (2006年1月) — twh

- 🐞 修复测试程序中对 `signed char` 的错误假设
- 📝 更新 `sh_build`
- 📖 修复从 HTML 生成 man 页面
- ⚙️ 修复 32 位和 64 位配置

### v1.0.1 (2004年12月) — twh

- 📦 修复 bootstrap 以使用更新版本
- 📖 修复 man 页面命名从 `(3X)` 到 `(3)`
- 🔧 代码修改以支持 Microsoft `__inline` 指令
- 📁 从使用符号链接改为使用复制
- 🪟 添加 `build.bat` 以支持 Windows 构建

### v1.0.0 (2004年9月) — twh

- 🔧 完成 Judy 的 Autoconf 化改造
- 🗑️ 移除旧的构建环境
- 📌 版本号提升至 1.0.0 以标识 API 变更

### v0.1.6 (2004年6月) — dlb

- 🔄 端序中立版本
- 🚀 包含 `JudyHS*()` — 非常快速、可扩展的字符串版本 (初步)
- 🐞 所有 `malloc()`/`free()` 通过 `JudyMalloc.c` 中的接口例程完成
- 📁 `Judy.h` 适用于所有符合 ISO 标准的平台
- 📝 将 `<stdint.h>` 改为 `<inttypes.h>` 以提高可移植性
- ✅ 符合标准 C
- 🐞 数百项可移植性改进