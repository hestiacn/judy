#include "judyhs_wrapper.h"
#include <stdio.h>
#include <string.h>

int main() {
    JudyHS_Wrapper_t hs;
    judyhs_wrapper_init(&hs);
    
    char key1[] = "apple";
    char key2[] = "banana";
    char key3[] = "cherry";
    
    // 插入
    Word_t *p;
    p = judyhs_wrapper_insert(&hs, key1, strlen(key1));
    if (p) *p = 100;
    
    p = judyhs_wrapper_insert(&hs, key2, strlen(key2));
    if (p) *p = 200;
    
    p = judyhs_wrapper_insert(&hs, key3, strlen(key3));
    if (p) *p = 300;
    
    printf("Count: %lu\n", judyhs_wrapper_count(&hs));
    printf("Mem used: %lu bytes\n", judyhs_wrapper_mem_used(&hs));
    
    // 查找
    p = judyhs_wrapper_get(&hs, key2, strlen(key2));
    if (p) printf("banana = %lu\n", *p);
    
    // 🔥 删除并返回值 — Bug #23 问题1 已解决
    Word_t deleted = judyhs_wrapper_delete(&hs, key2, strlen(key2));
    printf("Deleted banana, value = %lu\n", deleted);
    
    printf("After delete, count: %lu\n", judyhs_wrapper_count(&hs));
    printf("After delete, mem: %lu bytes\n", judyhs_wrapper_mem_used(&hs));
    
    // 释放
    Word_t freed = judyhs_wrapper_free(&hs);
    printf("Freed: %lu bytes\n", freed);
    
    return 0;
}