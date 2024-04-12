#ifdef SMALL_DATASET
#define SIZE 10
#endif
#ifdef LARGE_DATASET
#define SIZE 2000
#endif

#ifndef SMALL_DATASET
  #ifndef LARGE_DATASET
    #ifndef MEDIUM_DATASET
      #define MEDIUM_DATASET
    #endif
  #endif
#endif

#ifdef MEDIUM_DATASET
#define SIZE 500
#endif
