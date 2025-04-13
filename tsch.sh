#!/bin/bash

##### constants
homepage="https://github.com/jurakovic/timestamp-changer"
version="1.0.0"
bashPath="C:\Program Files\Git\usr\bin\bash.exe"
scriptPath="$(cygpath -w "$(pwd)")\tsch.sh"
iconPath="$(cygpath -w "$(pwd)")\tsch.ico"
fRootKey="HKEY_CLASSES_ROOT\*\shell\TimestampChanger"
dRootKey="HKEY_CLASSES_ROOT\Directory\shell\TimestampChanger"
clip_file="$HOME/.tsch"
datetime_format="yyyy-MM-dd HH:mm:ss"

function main() {
  if [ "$#" -eq 1 ] # cli arguments
  then
    case $1 in
      -i|--install) install ;;
      -u|--uninstall) uninstall ;;
      -v|--version) echo "$version" ;;
      -h|--help) echo "For help visit $homepage" ;;
    esac
  elif [ "$#" -eq 2 ] # context menu commands
  then
    $1 "$2"
    read -p "Press any key to exit..." -n1 -s; echo
  else
    show_menu
  fi
}

##### install/uninstall functions

function show_menu() {
  set +e
  clear
  echo
  echo -e "Timestamp Changer ($version)"
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
    read -p "Press any key to continue..." -n1 -s; echo
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

function install() {
  net session 1>/dev/null 2>/dev/null
  if [ ! $? -eq 0 ]; then
    read -p "Not running as Admin. Press any key to exit..." -n1 -s; echo
    exit 1
  fi

  echo "Installing..."
  install_internal "$fRootKey"
  install_internal "$dRootKey"
  echo "Done"
}

function install_internal() {
  itemPath="$1\\shell"
  add_menu_root "$1" "Timestamp Changer" "$iconPath"
  add_menu_item "$itemPath\\010CopyDateCreatedModified" "Copy" "copy"
  add_menu_item "$itemPath\\020PasteDateCreatedModified" "Paste" "paste"
  add_menu_item "$itemPath\\030PasteDateCreated" "Paste 'Date Created'" "pastedc"
  add_menu_item "$itemPath\\040PasteDateModified" "Paste 'Date Modified'" "pastedm"
}

function add_menu_root() {
  reg.exe add "$1" -v MUIVerb -d "$2" -f > /dev/null 2>&1
  reg.exe add "$1" -v SubCommands -d "" -f > /dev/null 2>&1
  reg.exe add "$1" -v Icon -d "$3" -f > /dev/null 2>&1
}

function add_menu_item() {
  # key, label, arg
  reg.exe add "$1" -ve -d "$2" -f > /dev/null 2>&1
  reg.exe add "$1\\command" -ve -d "\"$bashPath\" --login -i \"$scriptPath\" \"$3\" \"%1\"" -f > /dev/null 2>&1
}

function uninstall() {
  echo "Uninstalling..."
  uninstall_internal "$fRootKey"
  uninstall_internal "$dRootKey"
  rm -f "$clip_file"
  echo "Done"
}

function uninstall_internal() {
  if reg.exe query "$1" > /dev/null 2>&1; then
    echo "y" | reg.exe delete "$1" > /dev/null 2>&1
  fi
}

##### context menu commands (copy/paste functions)

function copy {
  dc="$(powershell.exe -Command '(Get-Item '\"$1\"').CreationTime.ToString('\"$datetime_format\"')')"
  dm="$(powershell.exe -Command '(Get-Item '\"$1\"').LastWriteTime.ToString('\"$datetime_format\"')')"
  echo "File/Folder:   $1"
  echo "---"
  echo "Date Created:  $dc"
  echo "Date Modified: $dm"

  echo "$dc" >  "$clip_file"
  echo "$dm" >> "$clip_file"
  echo "---"
  echo "Timestamps copied"
}

function pastedc {
  guard
  dc_old="$(powershell.exe -Command '(Get-Item '\"$1\"').CreationTime.ToString('\"$datetime_format\"')')"
  dm_old="$(powershell.exe -Command '(Get-Item '\"$1\"').LastWriteTime.ToString('\"$datetime_format\"')')"
  dc_new=$(sed -n '1p' "$clip_file")
  dm_new=$(sed -n '2p' "$clip_file")
  echo "File/Folder:   $1"
  echo "---"
  highlight_diff "Date Created: " "$dc_old" "$dc_new"
  echo "---"
  highlight_diff "Date Modified:" "$dm_old" "$dm_old"
  echo "---"
  read -p "Apply changes? (y/N) " yn
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
  echo "File/Folder:   $1"
  echo "---"
  highlight_diff "Date Created: " "$dc_old" "$dc_old"
  echo "---"
  highlight_diff "Date Modified:" "$dm_old" "$dm_new"
  echo "---"
  read -p "Apply changes? (y/N) " yn
  if [ "${yn,,}" = "y" ]
  then
    powershell.exe -Command "(Get-Item '$1').LastWriteTime=[datetime]::ParseExact('$dm_new', '$datetime_format', \$null)"
    echo "Done"
  else
    echo "Canceled"
  fi
}

function paste {
  guard
  dc_old="$(powershell.exe -Command '(Get-Item '\"$1\"').CreationTime.ToString('\"$datetime_format\"')')"
  dm_old="$(powershell.exe -Command '(Get-Item '\"$1\"').LastWriteTime.ToString('\"$datetime_format\"')')"
  dc_new=$(sed -n '1p' "$clip_file")
  dm_new=$(sed -n '2p' "$clip_file")
  echo "File/Folder:   $1"
  echo "---"
  highlight_diff "Date Created: " "$dc_old" "$dc_new"
  echo "---"
  highlight_diff "Date Modified:" "$dm_old" "$dm_new"
  echo "---"
  read -p "Apply changes? (y/N) " yn
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

function highlight_diff() {
  local label="$1"
  local old="$2"
  local new="$3"

  local reset="\033[0m"
  local green="\033[1;32m"
  local changed=0

  echo -e "$label $old (old)$reset"

  echo -n "$label "

  IFS='- :'
  read -r old_y old_m old_d old_H old_M old_S <<< "$old"
  read -r new_y new_m new_d new_H new_M new_S <<< "$new"
  unset IFS

  color_part() {
    local old_val="$1"
    local new_val="$2"
    if [[ "$old_val" == "$new_val" ]]; then
      echo -ne "${new_val}${reset}"
    else
      echo -ne "${green}${new_val}${reset}"
      changed=1
    fi
  }

  color_part "$old_y" "$new_y"
  echo -ne "-"
  color_part "$old_m" "$new_m"
  echo -ne "-"
  color_part "$old_d" "$new_d"
  echo -n " "
  color_part "$old_H" "$new_H"
  echo -ne ":"
  color_part "$old_M" "$new_M"
  echo -ne ":"
  color_part "$old_S" "$new_S"

  if [[ "$changed" -eq 1 ]]; then
    echo -e " ${green}(new)${reset}"
  else
    echo -e " (new)${reset}"
  fi
}

main "$@"
