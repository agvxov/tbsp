.PHONY: main test

CFLAGS := -std=c2x -Wall -Wpedantic

ifeq (${DEBUG}, 1)
  LFLAGS   += --debug --trace
  YFLAGS   += --debug
  CFLAGS   += -O0 -ggdb -fno-inline
  CPPFLAGS += -DDEBUG
else
  CFLAGS += -O3 -flto=auto -fno-stack-protector
endif

OUT := tbsp

main:
	bison ${YFLAGS} --header=object/tbsp.tab.h -o object/tbsp.tab.c source/tbsp.y
	flex ${LFLAGS} --header-file=object/tbsp.yy.h -o object/tbsp.yy.c source/tbsp.l
	gcc ${CPPFLAGS} ${CFLAGS} -Iobject -Ilibrary object/tbsp.tab.c object/tbsp.yy.c source/tbsp.c library/sds.c -o ${OUT}

run:
	./${OUT} test/convert.tbsp > object/test.cpp
	bake object/test.cpp
	./object/test.out test/input.md
