#include "merge_sort_mt.h"

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

int *create_data(size_t size)
{
    int *data = malloc(sizeof(int) * size);
    if (!data)
    {
        return NULL;
    }

    srand(time(NULL));

    for (size_t i = 0; i < size; i++)
    {
        data[i] = rand();
    }

    return data;
}

int main(int argc, char **argv)
{
    if (argc < 3)
    {
        printf("Usage: %s DATA_SIZE MT_DEPTH\n", argv[0]);
        return 1;
    }
    size_t size = atol(argv[1]);
    int *data = create_data(size);
    if (!data || merge_sort_mt(data, size, atoi(argv[2])) == MERGE_SORT_STATUS_ERROR)
    {
        printf("Failed to sort array\n");
        return 1;
    }

    return 0;
}