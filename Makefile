.PHONY: main test clean

# --- Paths / files
SOURCE.d  := source
OBJECT.d  := object
LIB.d     := library/

SOURCE    := main.c cli.c
OBJECT    := $(addprefix ${OBJECT.d}/,${SOURCE})
OBJECT    := ${OBJECT:.c=.o}

LIBS      := sds.o
LIBS      := $(addprefix ${OBJECT.d}/,${LIBS})

GENSOURCE := tbsp.yy.c tbsp_c.yy.c tbsp.tab.c
GENSOURCE := $(addprefix ${OBJECT.d}/,${GENSOURCE})
GENOBJECT := $(subst .c,.o,${GENSOURCE})

OUT := tbsp

# --- Flags
ifeq (${DEBUG}, 1)
  LFLAGS   += --debug --trace
  YFLAGS   += --debug
  CFLAGS   += -O0 -ggdb -fno-inline
  CPPFLAGS += -DDEBUG
else
  CFLAGS += -O3 -flto=auto -fno-stack-protector
endif

CFLAGS   += -std=c2x -Wall -Wpedantic
CPPFLAGS += -Isource -Iobject -Ilibrary

# --- Rule Section ---
${OUT}: ${GENSOURCE} ${GENOBJECT} ${OBJECT} ${LIBS}
	${LINK.c} -o $@ ${OBJECT} ${GENOBJECT} ${LIBS}

${OBJECT.d}/%.yy.c: ${SOURCE.d}/%.l
	flex --header-file=object/$(basename $(notdir $<)).yy.h ${LFLAGS} -o $@ $<

${OBJECT.d}/%.tab.c: ${SOURCE.d}/%.y
	bison ${YFLAGS} --header=object/$(basename $(notdir $<)).tab.h -o $@ $<

${OBJECT.d}/%.yy.o: ${OBJECT.d}/%.yy.c
	${COMPILE.c} -o $@ $<

${OBJECT.d}/%.tab.o: ${OBJECT.d}/%.tab.c
	${COMPILE.c} -o $@ $<

${OBJECT.d}/%.o: ${SOURCE.d}/%.c
	${COMPILE.c} -o $@ $<

${OBJECT.d}/%.o: ${LIB.d}/%.c
	${COMPILE.c} -o $@ $<

test: ${OUT}
	cmdtest --fast

clean:
	-rm ${GENSOURCE}
	-rm ${OBJECT}
	-rm ${OUT}
	-rm test/*.tb.*
