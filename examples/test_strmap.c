#include "strmap.h"
#include <stdio.h>

// 遍历回调函数
void print_entry(const char *key, void *value, void *user) {
    printf("  %s → %d\n", key, *(int *)value);
}

int main() {
    StrMap_t map;
    strmap_init(&map, 1, 1);  // 自动释放 key 和 value
    
    // 插入
    int *v1 = malloc(sizeof(int));
    *v1 = 100;
    strmap_set(&map, "apple", v1);
    
    int *v2 = malloc(sizeof(int));
    *v2 = 200;
    strmap_set(&map, "banana", v2);
    
    int *v3 = malloc(sizeof(int));
    *v3 = 300;
    strmap_set(&map, "cherry", v3);
    
    // 查找
    int *found = strmap_get(&map, "banana");
    if (found) printf("banana = %d\n", *found);
    
    // 遍历
    printf("All entries:\n");
    strmap_foreach(&map, print_entry, NULL);
    
    // 大小
    printf("Size: %lu\n", strmap_size(&map));
    
    // 释放（自动调用 free）
    strmap_free(&map);
    
    return 0;
}