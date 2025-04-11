#!/bin/bash

clip_file="$HOME/.tsch"
datetime_format="yyyy-MM-dd HH:mm:ss"

function main {
  #echo "number of args: $#"
  #echo "func: $1"
  #echo "file: $2"

  $1 "$2"

  read -p "Press any key to continue..." -n1 -s; echo
}

function copy {
  dc="$(powershell.exe -Command '(Get-Item '\"$1\"').CreationTime.ToString('\"$datetime_format\"')')"
  dm="$(powershell.exe -Command '(Get-Item '\"$1\"').LastWriteTime.ToString('\"$datetime_format\"')')"
  echo "File:         $1"
  echo "DateCreated:  $dc"
  echo "DateModified: $dm"

  echo "$dc" >  "$clip_file"
  echo "$dm" >> "$clip_file"
  echo "Timestamps copied"
}

function pastedc {
  guard
  dc_old="$(powershell.exe -Command '(Get-Item '\"$1\"').CreationTime.ToString('\"$datetime_format\"')')"
  dm_old="$(powershell.exe -Command '(Get-Item '\"$1\"').LastWriteTime.ToString('\"$datetime_format\"')')"
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
    powershell.exe -Command "(Get-Item '$1').CreationTime=[datetime]::ParseExact('$dc_new', '$datetime_format', \$null)"
    echo "Done"
  else
    echo "Canceled"
  fi
}

function pastedm {
  guard
  dc_old="$(powershell.exe -Command '(Get-Item '\"$1\"').CreationTime.ToString('\"$datetime_format\"')')"
  dm_old="$(powershell.exe -Command '(Get-Item '\"$1\"').LastWriteTime.ToString('\"$datetime_format\"')')"
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
    powershell.exe -Command "(Get-Item '$1').LastWriteTime=[datetime]::ParseExact('$dm_new', '$datetime_format', \$null)"
    echo "Done"
  else
    echo "Canceled"
  fi
}

function pastedcdm {
  guard
  dc_old="$(powershell.exe -Command '(Get-Item '\"$1\"').CreationTime.ToString('\"$datetime_format\"')')"
  dm_old="$(powershell.exe -Command '(Get-Item '\"$1\"').LastWriteTime.ToString('\"$datetime_format\"')')"
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
    powershell.exe -Command "(Get-Item '$1').CreationTime=[datetime]::ParseExact('$dc_new', '$datetime_format', \$null)"
    powershell.exe -Command "(Get-Item '$1').LastWriteTime=[datetime]::ParseExact('$dm_new', '$datetime_format', \$null)"
    echo "Done"
  else
    echo "Canceled"
  fi
}

function guard() {
  if ! [ -f "$clip_file" ]; then
    echo "Timestamps clipboard empty."
    read -p "Press any key to exit..." -n1 -s; echo
    exit 0
  fi

  dc=$(sed -n '1p' "$clip_file")
  dm=$(sed -n '2p' "$clip_file")
  powershell.exe -Command "[datetime]::ParseExact('$dc', '$datetime_format', \$null)" > /dev/null &&
  powershell.exe -Command "[datetime]::ParseExact('$dm', '$datetime_format', \$null)" > /dev/null

  if [ ! $? -eq 0 ];
  then
    echo "Timestamps clipboard corrupted. Copy new timestamps."
    read -p "Press any key to exit..." -n1 -s; echo
    exit 0
  fi
}

main "$@"
