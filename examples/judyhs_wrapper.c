#include "judyhs_wrapper.h"

void judyhs_wrapper_init(JudyHS_Wrapper_t *hs) {
    hs->judy = NULL;
    hs->mem_used = 0;
    hs->entry_count = 0;
}

Word_t* judyhs_wrapper_insert(JudyHS_Wrapper_t *hs, void *key, Word_t len) {
    Word_t *PValue;
    
    JHSI(PValue, hs->judy, key, len);
    if (PValue == PJERR) return NULL;
    
    // 如果是新插入的条目，更新统计
    if (*PValue == 0) {  // 新条目（值初始为 0）
        hs->entry_count++;
        // 估算内存：key + value + Judy 开销（粗略）
        // 精确值需要知道 Judy 内部结构，这里用估算
        hs->mem_used += len + sizeof(Word_t);
    }
    
    return PValue;
}

Word_t* judyhs_wrapper_get(JudyHS_Wrapper_t *hs, void *key, Word_t len) {
    Word_t *PValue;
    JHSG(PValue, hs->judy, key, len);
    return PValue;
}

// 🔥 删除并返回值 — 解决 Bug #23 问题1
Word_t judyhs_wrapper_delete(JudyHS_Wrapper_t *hs, void *key, Word_t len) {
    Word_t *PValue;
    Word_t value = 0;
    int ret;
    
    // 1. 先获取值
    PValue = judyhs_wrapper_get(hs, key, len);
    if (PValue != NULL) {
        value = *PValue;
    } else {
        return 0;  // 不存在
    }
    
    // 2. 删除
    ret = JHSD(hs->judy, key, len);
    if (ret == 1) {
        hs->entry_count--;
        if (hs->mem_used >= len + sizeof(Word_t)) {
            hs->mem_used -= len + sizeof(Word_t);
        }
        return value;
    }
    
    return 0;
}

// 🔥 获取内存使用 — 解决 Bug #23 问题2
Word_t judyhs_wrapper_mem_used(JudyHS_Wrapper_t *hs) {
    return hs->mem_used;
}

Word_t judyhs_wrapper_count(JudyHS_Wrapper_t *hs) {
    return hs->entry_count;
}

Word_t judyhs_wrapper_free(JudyHS_Wrapper_t *hs) {
    Word_t bytes;
    
    // 注意：这个释放的是 Judy 内部结构，不包括用户数据
    // 如果值指向 malloc 内存，需要先遍历释放
    bytes = JHSFA(hs->judy);
    
    hs->judy = NULL;
    hs->mem_used = 0;
    hs->entry_count = 0;
    
    return bytes;
}