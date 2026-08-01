#!/bin/sh
# ==============================================================================
# 编译引导提示 | Compilation Guide
# ==============================================================================
echo "--- [Compile Kit] Cross-platform build & packaging utility"
echo "--- Requirements: Must be executed directly from inside the 'src' directory"
echo "--- Performance: Completes in a few seconds on modern multi-core systems"
echo "--- Default Configuration: COPT='-O2' (Production Standard)"
echo "--- Pro-Tip: Optimize for your current host CPU by running:"
echo "---          COPT='-O3 -march=native' ./build.sh"

echo "--- Set Compiler"

# ==============================================================================
# 编译器配置 | Compiler Settings
# ==============================================================================
# 注意 | Note：
#   C 与 C++ 编译器必须严格成对使用（家族严禁混用），否则会导致底层链接失败。
#   C and C++ compilers must be strictly paired (do not mix families), otherwise
#   linking errors will occur.
#
# 平台推荐 | Platform Recommendations：
#   - FreeBSD / macOS : CC='clang'  且/and CXX='clang++' (系统原生，推荐 | native, recommended)
#   - Linux (RHEL/Ubuntu): CC='gcc' 且/and CXX='g++'     (系统默认，兼容好 | default, good compatibility)
#
# 说明 | Note：
#   下方代码会自动检测系统。如果是 FreeBSD，会自动指定 CXX='c++'（即 clang++），
#   从而在不修改 configure 文件的前提下，强行覆盖其内部的降级逻辑。
#   The code below auto-detects the system. On FreeBSD, it sets CXX='c++' (clang++)
#   to override the internal fallback logic without modifying configure files.
CC='cc'

# ==============================================================================
# 编译器家族自动探测 | Auto-detect compiler family
# ==============================================================================
# 通过解析编译器版本信息，实现跨平台自动联动切换
# Auto-switch between compiler families by parsing version info
IS_CLANG=$($CC --version 2>&1 | grep -i "clang")

if [ -n "$IS_CLANG" ]; then
    # 自动配对：在 FreeBSD/macOS 上使用系统原生 Clang++ 接口
    # Auto-pair: use native Clang++ on FreeBSD/macOS
    CXX='c++'
    echo "--- Detected Clang Compiler Family"
else
    # 自动配对：在 Linux 上回退至常规的 G++ 编译器
    # Auto-pair: fallback to G++ on Linux
    CXX='g++'
    echo "--- Detected GCC or Other Compiler Family"
fi

echo "--- Set Optimization"
COPT='-O2'
# ==============================================================================
# 位置无关代码配置 | Position Independent Code (PIC)
# ==============================================================================
# -fPIC: 生成位置无关代码，用于编译共享动态库（.so / .dylib）
#        Generate position-independent code for shared libraries (.so / .dylib)
#
# 各平台要求 | Platform Requirements：
#   - FreeBSD (amd64)     : 绝对必须 | Mandatory
#   - Linux (x86_64/ARM64): 绝对必须，否则链接动态库时会触发致命错误
#                           | Mandatory, otherwise linking will fail
#   - macOS (Darwin)      : 系统默认强制开启，显式指定可保持多平台兼容性
#                           | Enabled by default, explicit setting ensures compatibility
#   - Windows (MinGW)     : 不需要（Windows 动态库采用重定位机制，此参数无效）
#                           | Not needed (uses relocation mechanism instead)
CPIC='-fPIC'


echo "--- Compile JudyMalloc - common to Judy1 and JudyL"
echo "--- cd JudyCommon"
cd JudyCommon
rm -f *.o
$CC  $COPT $CPIC -I. -I.. -c JudyMalloc.c 
echo "--- cd .."
cd ..

echo "--- Give Judy1 the proper names"
echo "--- cd Judy1"
cd Judy1
rm -f *.o
ln -sf ../JudyCommon/JudyByCount.c      	Judy1ByCount.c   
ln -sf ../JudyCommon/JudyCascade.c      	Judy1Cascade.c
ln -sf ../JudyCommon/JudyCount.c        	Judy1Count.c
ln -sf ../JudyCommon/JudyCreateBranch.c 	Judy1CreateBranch.c
ln -sf ../JudyCommon/JudyDecascade.c    	Judy1Decascade.c
ln -sf ../JudyCommon/JudyDel.c          	Judy1Unset.c
ln -sf ../JudyCommon/JudyFirst.c        	Judy1First.c
ln -sf ../JudyCommon/JudyFreeArray.c    	Judy1FreeArray.c
ln -sf ../JudyCommon/JudyGet.c          	Judy1Test.c
ln -sf ../JudyCommon/JudyGet.c          	j__udy1Test.c
ln -sf ../JudyCommon/JudyInsArray.c     	Judy1SetArray.c
ln -sf ../JudyCommon/JudyIns.c          	Judy1Set.c
ln -sf ../JudyCommon/JudyInsertBranch.c 	Judy1InsertBranch.c
ln -sf ../JudyCommon/JudyMallocIF.c     	Judy1MallocIF.c
ln -sf ../JudyCommon/JudyMemActive.c    	Judy1MemActive.c
ln -sf ../JudyCommon/JudyMemUsed.c      	Judy1MemUsed.c
ln -sf ../JudyCommon/JudyPrevNext.c     	Judy1Next.c
ln -sf ../JudyCommon/JudyPrevNext.c     	Judy1Prev.c
ln -sf ../JudyCommon/JudyPrevNextEmpty.c	Judy1NextEmpty.c
ln -sf ../JudyCommon/JudyPrevNextEmpty.c	Judy1PrevEmpty.c
ln -sf ../JudyCommon/JudyTables.c	        Judy1TablesGen.c


echo "--- This table is constructed from Judy1.h data to match malloc(3) needs"
echo "--- $CC $COPT  -I. -I.. -I../JudyCommon -DJUDY1 Judy1TablesGen.c -o Judy1TablesGen"
$CC $COPT  -I. -I.. -I../JudyCommon -DJUDY1 Judy1TablesGen.c -o Judy1TablesGen
rm -f *.o
./Judy1TablesGen
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Tables.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Tables.c 

echo "--- Compile the main line Judy1 modules"
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Test.c" 
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Test.c 
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYGETINLINE j__udy1Test.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYGETINLINE j__udy1Test.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Set.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Set.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1SetArray.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1SetArray.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Unset.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Unset.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1First.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1First.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYNEXT Judy1Next.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYNEXT Judy1Next.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYPREV Judy1Prev.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYPREV Judy1Prev.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYNEXT Judy1NextEmpty.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYNEXT Judy1NextEmpty.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYPREV Judy1PrevEmpty.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DJUDYPREV Judy1PrevEmpty.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Count.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Count.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DNOSMARTJBB -DNOSMARTJBU -DNOSMARTJLB Judy1ByCount.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 -DNOSMARTJBB -DNOSMARTJBU -DNOSMARTJLB Judy1ByCount.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1FreeArray.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1FreeArray.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1MemUsed.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1MemUsed.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1MemActive.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1MemActive.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Cascade.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Cascade.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Decascade.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1Decascade.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1CreateBranch.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1CreateBranch.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1InsertBranch.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1InsertBranch.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1MallocIF.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDY1 Judy1MallocIF.c
echo "--- cd .."
cd ..

echo "--- Give JudyL the proper names"
echo "--- cd JudyL"
cd JudyL
rm -f *.o
ln -sf ../JudyCommon/JudyByCount.c      	JudyLByCount.c   
ln -sf ../JudyCommon/JudyCascade.c              JudyLCascade.c
ln -sf ../JudyCommon/JudyCount.c        	JudyLCount.c
ln -sf ../JudyCommon/JudyCreateBranch.c 	JudyLCreateBranch.c
ln -sf ../JudyCommon/JudyDecascade.c    	JudyLDecascade.c
ln -sf ../JudyCommon/JudyDel.c          	JudyLDel.c
ln -sf ../JudyCommon/JudyFirst.c        	JudyLFirst.c
ln -sf ../JudyCommon/JudyFreeArray.c    	JudyLFreeArray.c
ln -sf ../JudyCommon/JudyGet.c          	JudyLGet.c
ln -sf ../JudyCommon/JudyGet.c          	j__udyLGet.c
ln -sf ../JudyCommon/JudyInsArray.c     	JudyLInsArray.c
ln -sf ../JudyCommon/JudyIns.c          	JudyLIns.c
ln -sf ../JudyCommon/JudyInsertBranch.c 	JudyLInsertBranch.c
ln -sf ../JudyCommon/JudyMallocIF.c     	JudyLMallocIF.c
ln -sf ../JudyCommon/JudyMemActive.c    	JudyLMemActive.c
ln -sf ../JudyCommon/JudyMemUsed.c      	JudyLMemUsed.c
ln -sf ../JudyCommon/JudyPrevNext.c     	JudyLNext.c
ln -sf ../JudyCommon/JudyPrevNext.c     	JudyLPrev.c
ln -sf ../JudyCommon/JudyPrevNextEmpty.c	JudyLNextEmpty.c
ln -sf ../JudyCommon/JudyPrevNextEmpty.c	JudyLPrevEmpty.c
ln -sf ../JudyCommon/JudyTables.c	        JudyLTablesGen.c

echo "--- This table is constructed from JudyL.h data to match malloc(3) needs"
echo "--- $CC $COPT  -I. -I.. -I../JudyCommon -DJUDYL JudyLTablesGen.c -o JudyLTablesGen"
$CC $COPT  -I. -I.. -I../JudyCommon -DJUDYL JudyLTablesGen.c -o JudyLTablesGen
rm -f *.o
./JudyLTablesGen 
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLTables.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLTables.c 

echo "--- Compile the main line JudyL modules"
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLGet.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLGet.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYGETINLINE j__udyLGet.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYGETINLINE j__udyLGet.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLIns.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLIns.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLInsArray.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLInsArray.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLDel.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLDel.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLFirst.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLFirst.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYNEXT JudyLNext.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYNEXT JudyLNext.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYPREV JudyLPrev.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYPREV JudyLPrev.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYNEXT JudyLNextEmpty.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYNEXT JudyLNextEmpty.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYPREV JudyLPrevEmpty.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DJUDYPREV JudyLPrevEmpty.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLCount.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLCount.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DNOSMARTJBB -DNOSMARTJBU -DNOSMARTJLB JudyLByCount.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL -DNOSMARTJBB -DNOSMARTJBU -DNOSMARTJLB JudyLByCount.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLFreeArray.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLFreeArray.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLMemUsed.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLMemUsed.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLMemActive.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLMemActive.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLCascade.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLCascade.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLDecascade.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLDecascade.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLCreateBranch.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLCreateBranch.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLInsertBranch.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLInsertBranch.c
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLMallocIF.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c -DJUDYL JudyLMallocIF.c
echo "--- cd .."
cd ..

echo "--- Compile the JudySL routine"
echo "--- cd JudySL"
cd JudySL
rm -f *.o
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c JudySL.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c JudySL.c
echo "--- cd .."
cd ..
echo "--- Compile the JudyHS routine"
echo "--- cd JudyHS"
cd JudyHS
rm -f *.o
echo "--- $CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c JudyHS.c"
$CC  $COPT $CPIC -I. -I.. -I../JudyCommon -c JudyHS.c
echo "--- cd .."
cd ..

# Make a Judy shared library with CPIC='-fPIC' above
echo "--- Make a Judy shared library (libJudy.so)"
$CC -shared -o libJudy.so Judy*/*.o -lm
ls -lh libJudy.so
echo "--- Make a Judy static library (libJudy.a)"
ar -rc libJudy.a Judy*/*.o
ls -lh libJudy.a
echo "--- Install pkg-config copy judy.pc file"
pkg-config --variable=pc_path pkg-config | cut -d: -f1 | xargs -I {} sh -c 'mkdir -p {} && cp judy.pc {} && echo "judy.pc installed to {}"'
echo "--- Done"
