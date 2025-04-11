#!/bin/bash

clip_file="$HOME/.tsch"

function main {
  #echo "number of args: $#"
  #echo "func: $1"
  #echo "file: $2"

  $1 "$2"

  read -p "Press any key to continue..." -n1 -s; echo
}

function copy {
  dc="$(powershell.exe -Command '(Get-Item '$1').CreationTime.ToString("yyyy-MM-dd HH:mm:ss")')"
  dm="$(powershell.exe -Command '(Get-Item '$1').LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")')"
  echo "File:         $1"
  echo "DateCreated:  $dc"
  echo "DateModified: $dm"

  echo "$dc" >  "$clip_file"
  echo "$dm" >> "$clip_file"
  echo "Timestamps copied"
}

function pastedc {
  echo "this is pastedc:"
}

function pastedm {
  echo "this is pastedm:"
}

function pastedcdm {
  echo "this is pastedcdm:"
}

main "$@"
