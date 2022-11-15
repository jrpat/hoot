/* This file is part of Hoot: A Tcl-powered text preprocessor. 
** Copyright (C) 2022 Juan Patten. MIT License (see LICENSE). */

#include <stdio.h>
#include <jim.h>

#include "hoot.h"


#define ERROR(...) do{ fprintf(stderr, __VA_ARGS__); exit(1); }while(0)


int main(int argc, const char *argv[]) {
  if (argc != 2)
    ERROR("Usage: hoot <input-file>\n");

  const char *filename = argv[1];

  Jim_Interp *jim = Jim_CreateInterp();
  Jim_RegisterCoreCommands(jim);
  Jim_InitStaticExtensions(jim);
  Jim_Eval(jim, (char*)hoot_tcl);

  Jim_Obj *render = Jim_NewStringObj(jim, "renderfile ", -1);
  Jim_AppendString(jim, render, filename, -1);
  int rc = Jim_EvalObj(jim, render);
  const char *result = Jim_String(Jim_GetResult(jim));

  if (rc != JIM_OK)
    ERROR("Error processing %s: %s\n", filename, result);

  fputs(result, stdout);
  return 0;
}

