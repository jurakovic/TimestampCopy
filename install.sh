#!/bin/bash

# === Configuration ===
submenuKey="TimestampChanger"
submenuLabel="Timestamp Changer"

baseKey='HKCR\*\shell'
submenuPath="${baseKey}\\${submenuKey}"
submenuShellPath="${submenuPath}\\shell"

# === Submenu Item 1 ===
item1Key="${submenuShellPath}\\010Backup"
item1Cmd="${item1Key}\\command"
item1Label="Backup"
item1Command='"C:\Program Files\Git\usr\bin\bash.exe" --login -i "E:\git\timestamp-changer\tschanger.sh" "Backup..."'

# === Submenu Item 2 ===
item2Key="${submenuShellPath}\\020Restore"
item2Cmd="${item2Key}\\command"
item2Label="Restore"
item2Command='"C:\Program Files\Git\usr\bin\bash.exe" --login -i "E:\git\timestamp-changer\tschanger.sh" "Restore..."'

# === Submenu Item 3 ===
item3Key="${submenuShellPath}\\030CopyTimestamps"
item3Cmd="${item3Key}\\command"
item3Label="Copy Timestamps"
item3Command='"C:\Program Files\Git\usr\bin\bash.exe" --login -i "E:\git\timestamp-changer\tschanger.sh" "Copy Timestamps..."'

# === Submenu Item 4 ===
item4Key="${submenuShellPath}\\040PasteDateCreated"
item4Cmd="${item4Key}\\command"
item4Label="Paste DateCreated"
item4Command='"C:\Program Files\Git\usr\bin\bash.exe" --login -i "E:\git\timestamp-changer\tschanger.sh" "Paste DateCreated..."'

# === Submenu Item 5 ===
item5Key="${submenuShellPath}\\050PasteDateModified"
item5Cmd="${item5Key}\\command"
item5Label="Paste DateModified"
item5Command='"C:\Program Files\Git\usr\bin\bash.exe" --login -i "E:\git\timestamp-changer\tschanger.sh" "Paste DateModified..."'

# === Submenu Item 6 ===
item6Key="${submenuShellPath}\\060PasteDateCreatedModified"
item6Cmd="${item6Key}\\command"
item6Label="Paste DateCreated and Modified"
item6Command='"C:\Program Files\Git\usr\bin\bash.exe" --login -i "E:\git\timestamp-changer\tschanger.sh" "Paste DateCreated and Modified..."'

echo "Creating submenu \"$submenuLabel\"..."

# Remove existing key
#echo "y" | reg.exe delete "$submenuPath"

if reg.exe query "$submenuPath" > /dev/null 2>&1; then
  #echo "y" | reg.exe delete "$submenuPath"
  echo "y" | reg.exe delete "$submenuPath" > /dev/null 2>&1
  echo "deleted"
fi

#exit

# Create submenu root
reg.exe add "$submenuPath" -v MUIVerb -d "$submenuLabel" -f
reg.exe add "$submenuPath" -v SubCommands -d "" -f
reg.exe add "$submenuPath" -v Icon -d "E:\git\timestamp-changer\tschanger.ico" -f

# Create submenu items
reg.exe add "$item1Key" -ve -d "$item1Label" -f
reg.exe add "$item1Cmd" -ve -d "$item1Command" -f

reg.exe add "$item2Key" -ve -d "$item2Label" -f
reg.exe add "$item2Cmd" -ve -d "$item2Command" -f
reg.exe add "$item2Key" -v CommandFlags -t REG_DWORD -d 0x40 -f # separator

reg.exe add "$item3Key" -ve -d "$item3Label" -f
reg.exe add "$item3Cmd" -ve -d "$item3Command" -f

reg.exe add "$item4Key" -ve -d "$item4Label" -f
reg.exe add "$item4Cmd" -ve -d "$item4Command" -f

reg.exe add "$item5Key" -ve -d "$item5Label" -f
reg.exe add "$item5Cmd" -ve -d "$item5Command" -f

reg.exe add "$item6Key" -ve -d "$item6Label" -f
reg.exe add "$item6Cmd" -ve -d "$item6Command" -f

echo "Done"
