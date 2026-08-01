#ifndef STRMAP_H
#define STRMAP_H

#include <Judy.h>
#include <stdlib.h>
#include <string.h>

// 字符串 → void* 映射（用 JudyL 实现，支持遍历和自动释放）
typedef struct {
    Pvoid_t map;        // JudyL: key_hash → value
    Pvoid_t keys;       // JudyL: id → key_string (用于遍历时获取 key)
    Word_t  next_id;
    int     owns_keys;  // 1 = 释放时自动 free keys
    int     owns_values; // 1 = 释放时自动 free values
} StrMap_t;

// 初始化
void strmap_init(StrMap_t *m, int owns_keys, int owns_values);

// 插入
int strmap_set(StrMap_t *m, const char *key, void *value);

// 查找
void* strmap_get(StrMap_t *m, const char *key);

// 删除（自动释放 key/value 如果 owns 为真）
int strmap_del(StrMap_t *m, const char *key);

// 遍历所有条目
void strmap_foreach(StrMap_t *m, void (*callback)(const char *key, void *value, void *user), void *user);

// 释放全部
void strmap_free(StrMap_t *m);

// 获取大小
Word_t strmap_size(StrMap_t *m);

#endif