#!/bin/bash

bashPath="C:\Program Files\Git\usr\bin\bash.exe"
scriptPath="$(cygpath -w "$(pwd)")\tschanger.sh"
iconPath="$(cygpath -w "$(pwd)")\tschanger.ico"
#echo $bashPath
#echo $scriptPath
#echo $iconPath

fRootKey='HKEY_CLASSES_ROOT\*\shell\TimestampChanger'
dRootKey='HKEY_CLASSES_ROOT\Directory\shell\TimestampChanger'

function main() {
  if [ "$#" -eq 1 ]
  then
    case $1 in
      "-i") install ;;
      "-u") uninstall ;;
    esac
  else
    show_menu
  fi
}

function show_menu() {
  set +e
  clear
  echo
  echo -e "Timestamp Changer"
  echo "                            "
  echo "  [i] Install               "
  echo "  [u] Uninstall             "
  echo "                            "
  echo "  [q] Quit                  "
  echo
  read -p "Choose option: " option
  clear
  __perform_action $option
  if [ $option != "q" ] # else "quit"
  then
    __pause
    show_menu
  fi
}

function __perform_action() {
  case $1 in
    "i") install ;;
    "u") uninstall ;;
    "q") ;; # do nothing, will quit
    *)   echo "unknown option: $1" ;;
  esac
}

function __pause() {
  read -p "Press any key to continue..." -n1 -s; echo
}

function install() {
  install_internal "$fRootKey"
  install_internal "$dRootKey"
  echo "Install done"
}

function install_internal() {
  itemPath="$1\\shell"
  add_menu_root "$1" "Timestamp Changer" "$iconPath"
  #add_menu_item "$itemPath\\010Backup" "Backup" "backup"
  #add_menu_item "$itemPath\\020Restore" "Restore" "restore"
  #add_item_sep  "$itemPath\\020Restore"
  add_menu_item "$itemPath\\030CopyTimestamps" "Copy Timestamps" "copy"
  add_menu_item "$itemPath\\040PasteDateCreated" "Paste DateCreated" "pastedc"
  add_menu_item "$itemPath\\050PasteDateModified" "Paste DateModified" "pastedm"
  add_menu_item "$itemPath\\060PasteDateCreatedModified" "Paste DateCreated and Modified" "pastedcdm"
}

function add_menu_root() {
  reg.exe add "$1" -v MUIVerb -d "$2" -f
  reg.exe add "$1" -v SubCommands -d "" -f
  reg.exe add "$1" -v Icon -d "$3" -f
}

function add_menu_item() {
  # key, label, arg
  reg.exe add "$1" -ve -d "$2" -f
  reg.exe add "$1\\command" -ve -d "\"$bashPath\" --login -i \"$scriptPath\" \"$3\" \"%1\"" -f
}

function add_item_sep() {
  reg.exe add "$1" -v CommandFlags -t REG_DWORD -d 0x40 -f # separator
}

function uninstall() {
  uninstall_internal "$fRootKey"
  uninstall_internal "$dRootKey"
  echo "Uninstall done"
}

function uninstall_internal() {
  if reg.exe query "$1" > /dev/null 2>&1; then
    echo "y" | reg.exe delete "$1" > /dev/null 2>&1
    echo "deleted $fRootKey"
  fi
}

main "$@"
