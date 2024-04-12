/* Support macros for making weak and strong aliases for symbols,
   and for using symbol sets and linker warnings with GNU ld.
   Copyright (C) 1995-2019 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

#ifndef _LIBC_SYMBOLS_H
#define _LIBC_SYMBOLS_H	1

/* This file is included implicitly in the compilation of every source file,
   using -include.  It includes config.h.  */

/* Enable declarations of GNU extensions, since we are compiling them.  */
#define _GNU_SOURCE 1

#include <sys/stat.h>

#define IS_IN(lib) 0

#endif /* libc-symbols.h */
