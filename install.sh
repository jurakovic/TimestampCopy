#!/bin/bash

bashPath="C:\Program Files\Git\usr\bin\bash.exe"
scriptPath="$(cygpath -w "$(pwd)")\tschanger.sh"
iconPath="$(cygpath -w "$(pwd)")\tschanger.ico"
#echo $bashPath
#echo $scriptPath
#echo $iconPath

baseKey='HKCR\*\shell'
rootKey="$baseKey\\TimestampChanger"
itemPath="$rootKey\\shell"

function install() {
  add_menu_root "$rootKey" "Timestamp Changer" "$iconPath"
  add_menu_item "$itemPath\\010Backup" "Backup" "Backup..."
  add_menu_item "$itemPath\\020Restore" "Restore" "Restore..."
  add_item_sep  "$itemPath\\020Restore"
  add_menu_item "$itemPath\\030CopyTimestamps" "Copy Timestamps" "Copy Timestamps..."
  add_menu_item "$itemPath\\040PasteDateCreated" "Paste DateCreated" "Paste DateCreated..."
  add_menu_item "$itemPath\\050PasteDateModified" "Paste DateModified" "Paste DateModified..."
  add_menu_item "$itemPath\\060PasteDateCreatedModified" "Paste DateCreated and Modified" "Paste DateCreated and Modified..."
  echo "Install done"
}

function add_menu_root() {
  reg.exe add "$1" -v MUIVerb -d "$2" -f
  reg.exe add "$1" -v SubCommands -d "" -f
  reg.exe add "$1" -v Icon -d "$3" -f
}

function add_menu_item() {
  # key, label, arg
  reg.exe add "$1" -ve -d "$2" -f
  reg.exe add "$1\\command" -ve -d "\"$bashPath\" --login -i \"$scriptPath\" \"$3\"" -f
}

function add_item_sep() {
  reg.exe add "$1" -v CommandFlags -t REG_DWORD -d 0x40 -f # separator
}

function uninstall() {
  if reg.exe query "$rootKey" > /dev/null 2>&1; then
    echo "y" | reg.exe delete "$rootKey" > /dev/null 2>&1
    echo "deleted"
  fi
}

function main() {
  uninstall
  install
}

main
