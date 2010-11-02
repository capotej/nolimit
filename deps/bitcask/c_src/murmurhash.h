/*
  Murmurhash from http://sites.google.com/site/murmurhash/

  All code is released to the public domain. For business purposes, Murmurhash is
  under the MIT license.
*/
#ifndef MURMURHASH_H
#define MURMURHASH_H

#include <stdint.h>

#if defined(__x86_64__)
#define MURMUR_HASH MurmurHash64A
uint64_t MurmurHash64A ( const void * key, int len, unsigned int seed );

#elif defined(__i386__)
#define MURMUR_HASH MurmurHash2
unsigned int MurmurHash2 ( const void * key, int len, unsigned int seed );

#else
#define MURMUR_HASH MurmurHashNeutral2
unsigned int MurmurHashNeutral2 ( const void * key, int len, unsigned int seed );
#endif

#endif /* MURMURHASH_H */
