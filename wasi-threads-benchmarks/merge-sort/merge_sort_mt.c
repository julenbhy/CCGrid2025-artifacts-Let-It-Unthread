#include "merge_sort_mt.h"

#include <pthread.h>
#include <stdlib.h>
#include <string.h>

typedef struct
{
    int *data;
    int *temp;
    int size;
    int depth;
} thread_context_t;

static void fill_remaining(int *dest, size_t dest_idx, int *src, size_t src_idx, size_t size)
{
    size_t bytes_to_copy = (size - src_idx) * sizeof(int);
    memcpy(dest + dest_idx, src + src_idx, bytes_to_copy);
}

static void merge(int *a, size_t size_a, int *b, size_t size_b, int *c)
{
    size_t ia = 0, ib = 0, ic = 0;
    while (ia < size_a && ib < size_b)
    {
        c[ic++] = a[ia] <= b[ib] ? a[ia++] : b[ib++];
    }
    fill_remaining(c, ic, a, ia, size_a);
    fill_remaining(c, ic, b, ib, size_b);
}

static void merge_sort_aux_mt(int *data, int *temp, int size, int depth);

void *merge_sort_mt_thread(void *param)
{
    thread_context_t *ctx = (thread_context_t *)param;

    merge_sort_aux_mt(ctx->data, ctx->temp, ctx->size, ctx->depth);

    return NULL;
}

static void merge_sort_aux_mt(int *data, int *temp, int size, int depth)
{
    if (size < 2)
    {
        return;
    }

    int left = size / 2;
    if (depth > 0)
    {
        pthread_t t1;
        thread_context_t ctx1 = {data, temp, left, depth - 1};
        pthread_create(&t1, NULL, merge_sort_mt_thread, &ctx1);

        pthread_t t2;
        thread_context_t ctx2 = {data + left, temp + left, size - left, depth - 1};
        pthread_create(&t2, NULL, merge_sort_mt_thread, &ctx2);

        pthread_join(t1, NULL);
        pthread_join(t2, NULL);
    }
    else
    {
        merge_sort_aux_mt(data, temp, left, 0);
        merge_sort_aux_mt(data + left, temp + left, size - left, 0);
    }
    merge(data, left, data + left, size - left, temp);
    memcpy(data, temp, size * sizeof(int));
}

merge_sort_status_t merge_sort_mt(int *data, size_t size, size_t max_depth)
{
    int *temp = (int *)malloc(sizeof(int) * size);
    if (!temp)
    {
        return MERGE_SORT_STATUS_ERROR;
    }

    merge_sort_aux_mt(data, temp, size, max_depth);

    free(temp);

    return MERGE_SORT_STATUS_OK;
}
