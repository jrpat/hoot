/* This file is part of Hoot: A Tcl-powered text preprocessor. 
** Copyright (C) 2022 Juan Patten. MIT License (see LICENSE). */

#include <stdio.h>
#include <string.h>

#include <jim.h>

#include "hoot.h"


#define DIE(rc, f, ...) do{ fprintf(f, __VA_ARGS__); exit(rc); }while(0)
#define EXIT(...) DIE(0, stdout, __VA_ARGS__)
#define FAIL(...) DIE(1, stderr, __VA_ARGS__)

#define OK(x) ((x) == JIM_OK)
#define RESULT() Jim_String(Jim_GetResult(jim))

const char *usage =
  "Usage: \n"
  "  hoot -           Process input from stdin\n"
  "  hoot <path>      Process file at <path>\n"
  "  hoot -t/--tcl    Output Hoot Tcl code\n"
  "  hoot -h/--help   Print this message\n"
;

Jim_Interp *jim;


void render_stdin() {
  if (!OK( Jim_Eval(jim, "stdin read") ))
    FAIL("Error reading input: %s\n", RESULT());

  Jim_Obj *script = Jim_NewStringObj(jim, "render {", -1);
  Jim_AppendString(jim, script, RESULT(), -1);
  Jim_AppendString(jim, script, "}", -1);

  if (!OK( Jim_EvalObj(jim, script) ))
    FAIL("Error: %s\n", RESULT());

  fputs(RESULT(), stdout);
}


void render_file(const char *filename) {
  Jim_Obj *script = Jim_NewStringObj(jim, "renderfile ", -1);
  Jim_AppendString(jim, script, filename, -1);

  if (!OK( Jim_EvalObj(jim, script) ))
    FAIL("Error: %s\n", RESULT());

  fputs(RESULT(), stdout);
}


int main(int argc, const char *argv[]) {
  if (argc != 2)
    FAIL("%s", usage);

  int from_stdin = 0;
  const char *arg = argv[1];

  if (arg[0] == '-') {
    if (strlen(arg) == 1)
      from_stdin = 1;
    else if (!strcmp(arg, "-h") || !strcmp(arg, "--help"))
      EXIT("%s", usage);
    else if (!strcmp(arg, "-t") || !strcmp(arg, "--tcl"))
      EXIT("%s", hoot_tcl);
    else
      FAIL("Unrecognized option: %s\n\n%s", arg, usage);
  }

  jim = Jim_CreateInterp();
  Jim_RegisterCoreCommands(jim);
  if (Jim_InitStaticExtensions(jim) != JIM_OK)
    FAIL("%s\n", RESULT());
  if (Jim_Eval(jim, hoot_tcl) != JIM_OK)
    FAIL("Hoot Internal Error: %s\n", RESULT());

  if (from_stdin)
    render_stdin();
  else
    render_file(arg);

  return 0;
}
