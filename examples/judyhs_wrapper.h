#ifndef JUDYHS_WRAPPER_H
#define JUDYHS_WRAPPER_H

#include <Judy.h>
#include <stdlib.h>
#include <string.h>

// JudyHS 封装 - 解决 Bug #23 的问题：
// 1. 删除时返回值
// 2. 内存统计

typedef struct {
    Pvoid_t judy;           // JudyHS 数组
    Word_t  mem_used;       // 手动跟踪的内存使用
    Word_t  entry_count;    // 条目数量
} JudyHS_Wrapper_t;

// 初始化
void judyhs_wrapper_init(JudyHS_Wrapper_t *hs);

// 插入（返回指向值的指针，和原生一样）
Word_t* judyhs_wrapper_insert(JudyHS_Wrapper_t *hs, void *key, Word_t len);

// 查找（和原生一样）
Word_t* judyhs_wrapper_get(JudyHS_Wrapper_t *hs, void *key, Word_t len);

// 删除并返回值 — 解决 Bug #23 问题1
Word_t judyhs_wrapper_delete(JudyHS_Wrapper_t *hs, void *key, Word_t len);

// 获取内存使用 — 解决 Bug #23 问题2
Word_t judyhs_wrapper_mem_used(JudyHS_Wrapper_t *hs);

// 获取条目数量
Word_t judyhs_wrapper_count(JudyHS_Wrapper_t *hs);

// 释放整个数组（返回释放的字节数）
Word_t judyhs_wrapper_free(JudyHS_Wrapper_t *hs);

#endif