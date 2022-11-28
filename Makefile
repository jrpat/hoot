# This file is part of Hoot: A Tcl-powered text preprocessor.
# Copyright (C) 2022 Juan Patten. MIT License (see LICENSE).

CFLAGS := -std=c99
CFLAGS += -O3 -DNDEBUG
CFLAGS += -Wall -Wextra -Werror -pedantic
CFLAGS += -fsanitize=undefined
CFLAGS += -fstrict-aliasing -Wstrict-aliasing=2
CFLAGS += -I./jimtcl -L./jimtcl -ljim

prefix := /usr/local

jimlib := jimtcl/libjim.a


hoot: main.c hoot.h $(jimlib) Makefile
	@echo Building hoot
	@$(CC) $< -o $@ $(CFLAGS)

hoot.h: hoot.tcl Makefile
	@printf "const char hoot_tcl[] = {\n$$(tail -n +3 $< | xxd -i)\n};\n" > $@

$(jimlib): jimtcl/configure
	@echo Building jimtcl
	@cd jimtcl \
		&& ./configure --utf8 --disable-lineedit --math \
		               --with-ext="array,file,glob,interp,regexp" \
									 >/dev/null \
		&& make >/dev/null 2>&1

jimtcl/configure:
	@git submodule update --init


test: $(jimlib)
	@jimtcl/jimsh t/test.tcl && echo PASS || echo FAIL

clean:
	rm -f hoot hoot.h


install: hoot
	@echo Installing hoot to $(prefix)/bin
	@install $< $(prefix)/bin
