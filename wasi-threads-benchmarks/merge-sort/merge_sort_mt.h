#ifndef MERGE_SORT_MT_H
#define MERGE_SORT_MT_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
    MERGE_SORT_STATUS_OK = 0,
    MERGE_SORT_STATUS_ERROR = 1
} merge_sort_status_t;

merge_sort_status_t merge_sort_mt(int *data, size_t size, size_t max_depth);

#ifdef __cplusplus
}
#endif

#endif