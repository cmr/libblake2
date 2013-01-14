CC=gcc
AR=ar
CFLAGS=-std=c99 -Wall -pedantic -O3 -march=native

all:		static dynamic

build: lib/blake2b.c lib/blake2s.c lib/blake2bp.c lib/blake2sp.c
	$(CC) $(CFLAGS) -fPIC -static -c lib/blake2b.c lib/blake2s.c lib/blake2bp.c lib/blake2sp.c

static: build
	$(AR) rcs libblake2.a blake2b.o blake2s.o blake2bp.o blake2sp.o

dynamic: build
	$(CC) -shared -Wl,-soname,libblake2.so.0 -o libblake2.so.0 blake2b.o blake2s.o blake2bp.o blake2sp.o 

clean:		
		rm -f *.o *.so* *.a actual_d actual_s test_d test_s

test: static dynamic test.c
	$(CC) -static -L. -o test_s test.c -lblake2
	$(CC) -L. -o test_d test.c -lblake2
	LD_LIBRARY_PATH=. ./test_d > actual_d
	./test_s > actual_s
	echo "If you see a diff, the test failed"
	diff actual_d expected
	diff actual_s expected

.PHONY: all build static dynamic clean test
