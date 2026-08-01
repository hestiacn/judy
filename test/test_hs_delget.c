// @(#) $Revision: 1.0 $ $Source: /judy/test/test_hs_delget.c $
//
// Test JudyHSDelGet functionality
// Verify that deletion correctly returns the deleted value
//
// Compile:
//   gcc -o test_hs_delget test_hs_delget.c -I../src -L../src/libobj/.libs -lJudy
//
// Run:
//   LD_LIBRARY_PATH=../src/libobj/.libs ./test_hs_delget

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <Judy.h>

static int tests_passed = 0;
static int tests_failed = 0;

#define TEST_PASS(msg) do { printf("  ✅ %s\n", msg); tests_passed++; } while(0)
#define TEST_FAIL(msg) do { printf("  ❌ %s\n", msg); tests_failed++; } while(0)

#define TEST_ASSERT(cond, msg) \
    do { if (cond) { TEST_PASS(msg); } else { TEST_FAIL(msg); } } while(0)

#define TEST_ASSERT_EQ(actual, expected, msg) \
    do { \
        if ((actual) == (expected)) { \
            printf("  ✅ %s (got %lu, expected %lu)\n", msg, (unsigned long)(actual), (unsigned long)(expected)); \
            tests_passed++; \
        } else { \
            printf("  ❌ %s (got %lu, expected %lu)\n", msg, (unsigned long)(actual), (unsigned long)(expected)); \
            tests_failed++; \
        } \
    } while(0)

// ============================================================================
// Test 1: Basic insert and delete with return value
// ============================================================================
static void test_basic_insert_delete(void)
{
    Pvoid_t PJArray = (Pvoid_t)NULL;
    PPvoid_t PValue;
    Word_t deleted;
    int rc;

    printf("\n📋 Test 1: Basic insert and delete with return value\n");
    printf("----------------------------------------\n");

    JHSI(PValue, PJArray, "apple", 5);
    TEST_ASSERT(PValue != NULL && PValue != PJERR, "Insert 'apple' successful");
    if (PValue && PValue != PJERR) *(PWord_t)PValue = 100;

    JHSI(PValue, PJArray, "banana", 6);
    TEST_ASSERT(PValue != NULL && PValue != PJERR, "Insert 'banana' successful");
    if (PValue && PValue != PJERR) *(PWord_t)PValue = 200;

    JHSI(PValue, PJArray, "cherry", 6);
    TEST_ASSERT(PValue != NULL && PValue != PJERR, "Insert 'cherry' successful");
    if (PValue && PValue != PJERR) *(PWord_t)PValue = 300;

    // Key fix: JudyHSDelGet returns the deleted value, not a success flag
    deleted = JudyHSDelGet(&PJArray, "banana", 6, &deleted, PJE0);
    TEST_ASSERT_EQ(deleted, 200, "JudyHSDelGet returns deleted value (200)");

    JHSG(PValue, PJArray, "banana", 6);
    TEST_ASSERT(PValue == NULL, "'banana' has been deleted");

    JHSG(PValue, PJArray, "apple", 5);
    TEST_ASSERT(PValue != NULL, "'apple' still exists");
    if (PValue) TEST_ASSERT_EQ(*(PWord_t)PValue, 100, "'apple' value correct");

    JHSG(PValue, PJArray, "cherry", 6);
    TEST_ASSERT(PValue != NULL, "'cherry' still exists");
    if (PValue) TEST_ASSERT_EQ(*(PWord_t)PValue, 300, "'cherry' value correct");

    JHSFA(rc, PJArray);
}

// ============================================================================
// Test 2: Delete non-existent key
// ============================================================================
static void test_delete_not_found(void)
{
    Pvoid_t PJArray = (Pvoid_t)NULL;
    PPvoid_t PValue;
    Word_t deleted;
    int rc;

    printf("\n📋 Test 2: Delete non-existent key\n");
    printf("----------------------------------------\n");

    JHSI(PValue, PJArray, "hello", 5);
    TEST_ASSERT(PValue != NULL && PValue != PJERR, "Insert 'hello' successful");
    if (PValue && PValue != PJERR) *(PWord_t)PValue = 42;

    deleted = JudyHSDelGet(&PJArray, "world", 5, &deleted, PJE0);
    TEST_ASSERT_EQ(deleted, 0, "Delete non-existent key returns 0");

    JHSG(PValue, PJArray, "hello", 5);
    TEST_ASSERT(PValue != NULL, "'hello' still exists");
    if (PValue) TEST_ASSERT_EQ(*(PWord_t)PValue, 42, "'hello' value correct");

    JHSFA(rc, PJArray);
}

// ============================================================================
// Test 3: Delete key with value 0 (edge case)
// ============================================================================
static void test_delete_zero_value(void)
{
    Pvoid_t PJArray = (Pvoid_t)NULL;
    PPvoid_t PValue;
    Word_t deleted;
    int rc;

    printf("\n📋 Test 3: Delete key with value 0 (edge case)\n");
    printf("----------------------------------------\n");

    JHSI(PValue, PJArray, "zero", 4);
    TEST_ASSERT(PValue != NULL && PValue != PJERR, "Insert 'zero' successful");
    if (PValue && PValue != PJERR) *(PWord_t)PValue = 0;

    deleted = JudyHSDelGet(&PJArray, "zero", 4, &deleted, PJE0);
    TEST_ASSERT_EQ(deleted, 0, "Delete value=0 key returns 0 (cannot distinguish from not found)");

    JHSG(PValue, PJArray, "zero", 4);
    TEST_ASSERT(PValue == NULL, "'zero' has been deleted");

    JHSFA(rc, PJArray);
}

// ============================================================================
// Test 4: Multiple insert/delete operations
// ============================================================================
static void test_multi_operations(void)
{
    Pvoid_t PJArray = (Pvoid_t)NULL;
    PPvoid_t PValue;
    Word_t deleted;
    int rc;
    char key[32];

    printf("\n📋 Test 4: Multiple insert/delete operations\n");
    printf("----------------------------------------\n");

    for (int i = 0; i < 5; i++) {
        sprintf(key, "key_%d", i);
        JHSI(PValue, PJArray, key, strlen(key));
        if (PValue && PValue != PJERR) *(PWord_t)PValue = i * 100;
    }
    TEST_PASS("Inserted 5 keys");

    for (int i = 0; i < 5; i++) {
        sprintf(key, "key_%d", i);
        deleted = JudyHSDelGet(&PJArray, key, strlen(key), &deleted, PJE0);
        TEST_ASSERT_EQ(deleted, i * 100, "Delete key_%d returns correct value");
    }

    Word_t count = 0;
    Word_t id = 0;
    JLF(PValue, PJArray, id);
    while (PValue != NULL) { count++; JLN(PValue, PJArray, id); }
    TEST_ASSERT_EQ(count, 0, "All keys have been deleted");

    JHSFA(rc, PJArray);
}

// ============================================================================
// Test 5: Using JHSDG macro
// ============================================================================
static void test_macro_usage(void)
{
    Pvoid_t PJArray = (Pvoid_t)NULL;
    PPvoid_t PValue;
    Word_t value = 0;
    int rc;

    printf("\n📋 Test 5: Using JHSDG macro\n");
    printf("----------------------------------------\n");

    JHSI(PValue, PJArray, "macro_test", 10);
    TEST_ASSERT(PValue != NULL && PValue != PJERR, "Insert successful");
    if (PValue && PValue != PJERR) *(PWord_t)PValue = 999;

    // JHSDG macro: first parameter receives the deleted value
    JHSDG(rc, PJArray, "macro_test", 10, value);
    TEST_ASSERT_EQ(rc, 999, "JHSDG macro returns deleted value (999)");
    TEST_ASSERT_EQ(value, 999, "JHSDG macro output parameter correct");

    JHSG(PValue, PJArray, "macro_test", 10);
    TEST_ASSERT(PValue == NULL, "key has been deleted");

    JHSFA(rc, PJArray);
}

// ============================================================================
// Main
// ============================================================================
int main(void)
{
    printf("\n");
    printf("╔══════════════════════════════════════════════════════════╗\n");
    printf("║     JudyHSDelGet Function Test                         ║\n");
    printf("║     Verify deletion correctly returns the deleted value║\n");
    printf("╚══════════════════════════════════════════════════════════╝\n");

    test_basic_insert_delete();
    test_delete_not_found();
    test_delete_zero_value();
    test_multi_operations();
    test_macro_usage();

    printf("\n");
    printf("═══════════════════════════════════════════════════════════\n");
    printf("  Test Results: ✅ %d passed, ❌ %d failed\n", tests_passed, tests_failed);
    printf("═══════════════════════════════════════════════════════════\n");

    return (tests_failed > 0) ? 1 : 0;
}