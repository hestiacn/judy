#include "strmap.h"

// 简单字符串哈希（从 JudyHS 中借用的）
static Word_t hash_str(const char *s) {
    Word_t h = 0;
    while (*s) h = h * 31 + (unsigned char)*s++;
    return h;
}

void strmap_init(StrMap_t *m, int owns_keys, int owns_values) {
    m->map = NULL;
    m->keys = NULL;
    m->next_id = 1;
    m->owns_keys = owns_keys;
    m->owns_values = owns_values;
}

int strmap_set(StrMap_t *m, const char *key, void *value) {
    Word_t *p;
    Word_t hash = hash_str(key);
    
    // 存储值
    JLI(p, m->map, hash);
    if (p == PJERR) return -1;
    
    // 如果 key 已存在，先释放旧值
    if (*p != 0) {
        if (m->owns_values) free((void *)*p);
        // 注意：没有从 keys 中删除旧 key，为简化略过
        // 实际使用建议先用 strmap_del 删除
    }
    *p = (Word_t)value;
    
    // 存储 key（用于遍历）
    char *key_copy = strdup(key);
    if (!key_copy) return -1;
    
    Word_t *q;
    JLI(q, m->keys, m->next_id++);
    if (q == PJERR) {
        free(key_copy);
        return -1;
    }
    *q = (Word_t)key_copy;
    
    return 0;
}

void* strmap_get(StrMap_t *m, const char *key) {
    Word_t *p;
    Word_t hash = hash_str(key);
    JLG(p, m->map, hash);
    if (p == NULL) return NULL;
    return (void *)*p;
}

int strmap_del(StrMap_t *m, const char *key) {
    Word_t hash = hash_str(key);
    Word_t *p;
    
    // 获取值
    JLG(p, m->map, hash);
    if (p == NULL) return 0;
    
    // 释放值
    if (m->owns_values && *p) free((void *)*p);
    
    // 从 map 中删除
    JLD(p, m->map, hash);
    
    // 注意：没有从 keys 中删除 key
    // 实际使用建议用 strmap_clear 清空重建
    
    return 1;
}

void strmap_foreach(StrMap_t *m, void (*callback)(const char *key, void *value, void *user), void *user) {
    Word_t id = 0;
    Word_t *p;
    char *key;
    void *value;
    Word_t hash;
    
    // 遍历 keys
    JLF(p, m->keys, id);
    while (p != NULL) {
        key = (char *)*p;
        
        // 通过 key 查找对应的值
        hash = hash_str(key);
        Word_t *vp;
        JLG(vp, m->map, hash);
        value = (vp != NULL) ? (void *)*vp : NULL;
        
        if (callback) callback(key, value, user);
        
        JLN(p, m->keys, id);
    }
}

Word_t strmap_size(StrMap_t *m) {
    Word_t *p;
    Word_t count = 0;
    Word_t id = 0;
    
    JLF(p, m->keys, id);
    while (p != NULL) {
        count++;
        JLN(p, m->keys, id);
    }
    return count;
}

void strmap_free(StrMap_t *m) {
    Word_t id = 0;
    Word_t *p;
    char *key;
    void *value;
    Word_t hash;
    Word_t bytes;
    
    // 遍历 keys，释放所有资源
    JLF(p, m->keys, id);
    while (p != NULL) {
        key = (char *)*p;
        
        // 释放值
        if (m->owns_values) {
            hash = hash_str(key);
            Word_t *vp;
            JLG(vp, m->map, hash);
            if (vp != NULL && *vp != 0) {
                free((void *)*vp);
            }
        }
        
        // 释放 key
        if (m->owns_keys) {
            free(key);
        }
        
        // 从 keys 中删除
        JLD(p, m->keys, id);
        JLN(p, m->keys, id);
    }
    
    // 释放 JudyL 数组
    JLFA(bytes, m->keys);
    JLFA(bytes, m->map);
    
    m->map = NULL;
    m->keys = NULL;
    m->next_id = 1;
}