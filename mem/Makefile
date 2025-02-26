SRC = example.c mem_utils.m
INCLUDE = mem_utils.h
TARGET = mem
CFLAGS = -I.
LDFLAGS = -framework Foundation
CC := clang
CFLAGS ?= -Wall -Werror $(shell pkg-config --cflags libcrypto) -fPIC -Wno-pointer-to-int-cast -Wno-unused-command-line-argument -Wno-deprecated-declarations -framework CoreFoundation
DYLIB_LDFLAGS ?=

ifeq ($(MAKECMDGOALS), ios)
	CFLAGS += -arch arm64 -arch arm64e -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -miphoneos-version-min=11.0
else
	CFLAGS += -mmacosx-version-min=10.13
endif

$(TARGET): $(SRC)
ifeq ($(MAKECMDGOALS), ios)
	$(CC) $(CFLAGS) $(LDFLAGS) $(DYLIB_LDFLAGS) -o $@ $^
else
	$(CC) $(CFLAGS) $(LDFLAGS) $(DYLIB_LDFLAGS) -o $@ $^
endif
