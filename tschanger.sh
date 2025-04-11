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
  dc_old="$(powershell.exe -Command '(Get-Item '$1').CreationTime.ToString("yyyy-MM-dd HH:mm:ss")')"
  dm_old="$(powershell.exe -Command '(Get-Item '$1').LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")')"
  dc_new=$(sed -n '1p' "$clip_file")
  dm_new=$(sed -n '2p' "$clip_file")
  echo "File:         $1"
  echo "DateCreated:  $dc_old (old)"
  echo "DateCreated:  $dc_new (new)"
  echo "DateModified: $dm_old (old)"
  echo "DateModified: $dm_new (new)"

  read -p "Apply changes? (y/n) " yn
  if [ "${yn,,}" = "y" ]
  then
    powershell.exe -Command "(Get-Item '$1').CreationTime=[datetime]::ParseExact('$dc_new', 'yyyy-MM-dd HH:mm:ss', \$null)"
    echo "Done"
  else
    echo "Cancel"
  fi
}

function pastedm {
  echo "this is pastedm:"
}

function pastedcdm {
  echo "this is pastedcdm:"
}

main "$@"
