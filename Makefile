# This file is part of Hoot: A Tcl-powered text preprocessor.
# Copyright (C) 2022 Juan Patten. MIT License (see LICENSE).

CFLAGS := -std=c99
CFLAGS += -O3 -DNDEBUG
CFLAGS += -Wall -Wextra -Werror -pedantic
CFLAGS += -fsanitize=undefined
CFLAGS += -fstrict-aliasing -Wstrict-aliasing=2
CFLAGS += -I./jimtcl -L./jimtcl -ljim
CFLAGS += -lm

prefix := /usr/local

jimlib := jimtcl/libjim.a


hoot: main.c hoot.h $(jimlib) Makefile
	@echo Building hoot
	@$(CC) $< -o $@ $(CFLAGS)

hoot.h: hoot.tcl Makefile
	@printf "const char hoot_tcl[] = {\n$$(tail -n +3 $< | xxd -i), 0x00\n};\n" > $@

$(jimlib): jimtcl/configure
	@echo Building jimtcl
	@cd jimtcl \
		&& ./configure --minimal \
							     --utf8 --disable-lineedit --math \
		               --with-ext="array,file,glob,interp,regexp" \
									 --without-ext="eventloop,history,oo,package,signal,syslog,tree,zlib" \
									 >/dev/null \
		&& make >/dev/null 2>&1

jimtcl/configure:
	@git submodule update --init


test: hoot
	@jimtcl/jimsh t/test.tcl && echo PASS || echo FAIL

clean:
	rm -f hoot hoot.h

reset: clean
	cd jimtcl && git reset --hard HEAD && git clean -f -d -x


install: hoot
	@echo Installing hoot to $(prefix)/bin
	@install $< $(prefix)/bin
