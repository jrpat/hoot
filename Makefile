# This file is part of Hoot: A Tcl-powered text preprocessor.
# Copyright (C) 2022 Juan Patten. MIT License (see LICENSE).

CFLAGS := -std=c99
CFLAGS += -O3 -DNDEBUG
CFLAGS += -Wall -Wextra -Werror -pedantic
CFLAGS += -fsanitize=undefined
CFLAGS += -fstrict-aliasing -Wstrict-aliasing=2
CFLAGS += -I./jimtcl -L./jimtcl -ljim

jimlib := jimtcl/libjim.a


hoot: main.c hoot.h $(jimlib) Makefile
	$(CC) $< -o $@ $(CFLAGS)

hoot.h: hoot.tcl
	xxd -i $< $@

$(jimlib): jimtcl/configure
	cd jimtcl \
		&& ./configure --utf8 --disable-lineedit --math \
		               --with-ext="array,file,glob,interp,regexp" \
		&& make

jimtcl/configure:
	git submodule init

clean:
	rm -f hoot hoot.h
