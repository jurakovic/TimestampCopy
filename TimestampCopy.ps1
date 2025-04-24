[CmdletBinding(PositionalBinding=$false)]
Param(
    [switch][Alias('h')]$Help,
    [switch][Alias('v')]$Version,
    [switch][Alias('i')]$Install,
    [switch][Alias('q')]$Quiet,
    [switch][Alias('u')]$Uninstall,
    [string][Alias('c')]$Copy,
    [string][Alias('p')]$Paste,
    [string][Alias('pc')]$PasteDateCreated,
    [string][Alias('pm')]$PasteDateModified,
    [switch][Alias('z')]$Undo
)

##### Constants

$homepage = "https://github.com/jurakovic/timestamp-copy"
$versionn = "2.1.0-preview.1"
$scriptPath = "$PSCommandPath"
$iconPath = "$PSScriptRoot\tscp.ico"
$appdataPath = "$env:LOCALAPPDATA\TimestampCopy"
$clipPath = "$appdataPath\clip"
$undoPath = "$appdataPath\clip-undo"
$fRootKey = "HKEY_CLASSES_ROOT\*\shell\TimestampCopy"
$dRootKey = "HKEY_CLASSES_ROOT\Directory\shell\TimestampCopy"
$datetimeFormat = "yyyy-MM-dd HH:mm:ss"

##### Main

function Main {
    if ($Help) {
        Write-Host "For help visit $homepage"
        exit 0
    }

    if ($Version) {
        Write-Host "$versionn"
        exit 0
    }

    if ($(@($Install, $Uninstall | Where-Object { $_ }).Count) -ge 2) {
        Show-Guard-Message "Parameters -Install, -Uninstall cannot be used together."
    }

    if ($Install) {
        Install
        exit 0
    }

    if ($Uninstall) {
        Uninstall
        exit 0
    }

    if ($(@($Copy, $Paste, $PasteDateCreated, $PasteDateModified, $Undo | Where-Object { $_ }).Count) -ge 2) {
        Show-Guard-Message "Parameters -Copy, -Paste, -PasteDateCreated, -PasteDateModified, -Undo cannot be used together."
    }

    if ($Copy) {
        Copy-Timestamps -FilePath "$Copy"
        Pause-Script
        exit 0
    }

    if ($Paste) {
        Paste-Timestamps -FilePath "$Paste"
        Pause-Script
        exit 0
    }

    if ($PasteDateCreated) {
        Paste-DateCreated -FilePath "$PasteDateCreated"
        Pause-Script
        exit 0
    }

    if ($PasteDateModified) {
        Paste-DateModified -FilePath "$PasteDateModified"
        Pause-Script
        exit 0
    }

    if ($Undo) {
        Undo-Timestamps
        Pause-Script
        exit 0
    }

    Show-Menu
}

##### Install/Uninstall Functions

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  Timestamp Copy ($versionn)"
    Write-Host "                            "
    Write-Host "  [i] Install               "
    Write-Host "  [q] Install (Quiet Mode)  "
    Write-Host "  [u] Uninstall             "
    Write-Host "                            "
    Write-Host "  [x] Quit                  "
    Write-Host ""
    $option = Read-Host "Choose option"
    Clear-Host
    Perform-Action -Option $option
    Pause-Script "continue"
    Show-Menu
}

function Perform-Action {
    param (
        [string]$Option
    )

    switch ($Option) {
        "i" { Install }
        "q" { $Quiet=$true; Install }
        "u" { Uninstall }
        "x" { exit 0 }
        default { Write-Host "Unknown option: $Option" }
    }
}

function Pause-Script {
    param (
        [string]$Option = "exit"
    )

    if (-Not $Quiet) {
        Write-Host -NoNewLine "Press any key to $Option..."
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }
}

function Install {
    net session *> $null
    if (-Not $?) {
        Write-Host "Not running as Admin"
        Pause-Script
        exit 1
    }

    $quietMode = If ($Quiet) { " (Quiet Mode)" } Else { "" }
    Write-Host "Installing$quietMode..."
    Create-AppData
    Add-ContextMenu -RootKey "$fRootKey"
    Add-ContextMenu -RootKey "$dRootKey"
    Write-Host "Done"
}

function Create-AppData {
    New-Item -Path "$appdataPath" -ItemType Directory -Force | Out-Null
}

function Add-ContextMenu {
    param (
        [string]$RootKey
    )

    Add-MenuRoot -Key "$RootKey" -Label "Timestamp Copy" -IconPath "$iconPath"
    Add-MenuItem -Key "$RootKey\shell\010CopyTimestamps" -Label "Copy" -Action "Copy '%1'"
    Add-MenuItem -Key "$RootKey\shell\020PasteTimestamps" -Label "Paste" -Action "Paste '%1'"
    Add-MenuItem -Key "$RootKey\shell\030PasteDateCreated" -Label "Paste 'Date Created'" -Action "PasteDateCreated '%1'"
    Add-MenuItem -Key "$RootKey\shell\040PasteDateModified" -Label "Paste 'Date Modified'" -Action "PasteDateModified '%1'"
    Add-MenuItem -Key "$RootKey\shell\050UndoTimestamps" -Label "Undo" -Action "Undo"
}

function Add-MenuRoot {
    param (
        [string]$Key,
        [string]$Label,
        [string]$IconPath
    )

    reg.exe add "$Key" /v MUIVerb /d "$Label" /f | Out-Null
    reg.exe add "$Key" /v SubCommands /f | Out-Null
    reg.exe add "$Key" /v Icon /d "$IconPath" /f | Out-Null
}

function Add-MenuItem {
    param (
        [string]$Key,
        [string]$Label,
        [string]$Action
    )

    $headless = if ($Quiet) { "conhost.exe --headless " } else { "" }
    $q = if ($Quiet) { " -q" } else { "" }

    reg.exe add "$Key" /ve /d "$Label" /f | Out-Null
    reg.exe add "$Key\command" /ve /d "${headless}powershell -ExecutionPolicy ByPass -NoProfile -Command """"& '$scriptPath' -$Action$q""""" /f | Out-Null
}

function Uninstall {
    Write-Host "Uninstalling..."
    Remove-ContextMenu -RootKey "$fRootKey"
    Remove-ContextMenu -RootKey "$dRootKey"
    Remove-Item -Recurse -Force -Path "$appdataPath" *> $null
    Write-Host "Done"
}

function Remove-ContextMenu {
    param (
        [string]$RootKey
    )

    reg.exe delete "$RootKey" /f *> $null
}

##### Context Menu Commands (Copy/Paste Functions)

function Copy-Timestamps {
    param (
        [string]$FilePath
    )

    Path-Exists $FilePath

    $item = Get-Item -Path "$FilePath"
    $dc = $item.CreationTime.ToString("$datetimeFormat")
    $dm = $item.LastWriteTime.ToString("$datetimeFormat")

    Set-Clipboard-Content -Path "$clipPath" -Value "$dc`n$dm"

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Write-Host "Date Created:  $dc"
    Write-Host "Date Modified: $dm"
    Write-Host "---"
    Write-Host "Timestamps copied"
}

function Paste-Timestamps {
    param (
        [string]$FilePath
    )

    Path-Exists $FilePath
    Guard-Clipboard

    $timestamps = Get-Clipboard-Content -Path "$clipPath"
    $dcNew = $timestamps[0]
    $dmNew = $timestamps[1]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Paste-Timestamps-Internal "$FilePath" "$dcOld" "$dcNew" "$dmOld" "$dmNew"
}

function Paste-DateCreated {
    param (
        [string]$FilePath
    )

    Path-Exists $FilePath
    Guard-Clipboard

    $timestamps = Get-Clipboard-Content -Path "$clipPath"
    $dcNew = $timestamps[0]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Paste-Timestamps-Internal "$FilePath" "$dcOld" "$dcNew" "$dmOld" "$dmOld" # We're using here "$dmOld" two times
}

function Paste-DateModified {
    param (
        [string]$FilePath
    )

    Path-Exists $FilePath
    Guard-Clipboard

    $timestamps = Get-Clipboard-Content -Path "$clipPath"
    $dmNew = $timestamps[1]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Paste-Timestamps-Internal "$FilePath" "$dcOld" "$dcOld" "$dmOld" "$dmNew" # We're using here "$dcOld" two times
}

function Paste-Timestamps-Internal {
    param (
        [string]$FilePath,
        [string]$dcOld,
        [string]$dcNew,
        [string]$dmOld,
        [string]$dmNew
    )

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Highlight-Diff -Label "Date Created: " -Old "$dcOld" -New "$dcNew"
    Write-Host "---"
    Highlight-Diff -Label "Date Modified:" -Old "$dmOld" -New "$dmNew"
    Write-Host "---"

    $applyChanges = if ($Quiet) { "y" } else { Read-Host "Apply changes? (y/N)" }
    if ($applyChanges -ieq "y") {
        $item = Get-Item -Path "$FilePath"
        # Changing both values triggers "Refresh" in Windows File Explorer
        $item.CreationTime = [datetime]::ParseExact("$dcNew", "$datetimeFormat", $null)
        $item.LastWriteTime = [datetime]::ParseExact("$dmNew", "$datetimeFormat", $null)
        Set-Clipboard-Content -Path "$undoPath" -Value "$FilePath`n$dcOld`n$dmOld" # Backup old timestamps
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Undo-Timestamps {
    Guard-Undo-Clipboard

    $timestamps = Get-Clipboard-Content -Path "$undoPath"
    $filePath = $timestamps[0]
    $dcNew = $timestamps[1]
    $dmNew = $timestamps[2]

    $item = Get-Item -Path "$filePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Paste-Timestamps-Internal "$filePath" "$dcOld" "$dcNew" "$dmOld" "$dmNew"
}

##### Helper Functions

function Set-Clipboard-Content {
    param (
        [string]$Path,
        [string]$Value
    )

    $encoded  = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$Value"))
    Set-Content -Path "$Path" -Value "$encoded"
}

function Get-Clipboard-Content {
    param (
        [string]$Path
    )

    $encoded = Get-Content -Path "$Path"
    $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded))
    return $decoded -split "`n"
}

function Path-Exists {
    param (
        [string]$FilePath
    )

    if (-Not (Test-Path -Path "$FilePath")) {
        Show-Guard-Message "Cannot find path '$FilePath' because it does not exist."
    }
}

function Guard-Clipboard {
    if (-Not (Test-Path -Path "$clipPath")) {
        Show-Guard-Message "Timestamps clipboard empty. Copy new timestamps.    "
    }

    try {
        $encoded = Get-Content -Path "$clipPath"
        [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded)) | Out-Null
    } catch {
        Show-Guard-Message "Timestamps clipboard corrupted. Copy new timestamps."
    }

    $timestamps = Get-Clipboard-Content -Path "$clipPath"
    if ($timestamps.Count -ne 2) {
        Show-Guard-Message "Timestamps clipboard corrupted. Copy new timestamps."
    }

    try {
        [datetime]::ParseExact($timestamps[0], "$datetimeFormat", $null) | Out-Null
        [datetime]::ParseExact($timestamps[1], "$datetimeFormat", $null) | Out-Null
    } catch {
        Show-Guard-Message "Timestamps clipboard corrupted. Copy new timestamps."
    }
}

function Guard-Undo-Clipboard {
    if (-Not (Test-Path -Path "$undoPath")) {
        Show-Guard-Message "Timestamps undo clipboard empty. Paste some timestamps.   "
    }

    try {
        $encoded = Get-Content -Path "$undoPath"
        [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded)) | Out-Null
    } catch {
        Show-Guard-Message "Timestamps undo clipboard corrupted. Paste new timestamps."
    }

    $timestamps = Get-Clipboard-Content -Path "$undoPath"
    if ($timestamps.Count -ne 3) {
        Show-Guard-Message "Timestamps undo clipboard corrupted. Paste new timestamps."
    }

    try {
        [datetime]::ParseExact($timestamps[1], "$datetimeFormat", $null) | Out-Null
        [datetime]::ParseExact($timestamps[2], "$datetimeFormat", $null) | Out-Null
    } catch {
        Show-Guard-Message "Timestamps undo clipboard corrupted. Paste new timestamps."
    }
}

function Show-Guard-Message {
    param (
        [string]$Message
    )

    if ($Quiet) {
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        [System.Windows.MessageBox]::Show("$Message", "Timestamp Copy", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Exclamation)
    } else {
        Write-Host "$Message"
        Pause-Script
    }
    exit 1
}

function Highlight-Diff {
    param (
        [string]$Label,
        [string]$Old,
        [string]$New
    )

    $changed = $false

    Write-Host "$Label $Old (old)"
    Write-Host -NoNewline "$Label "

    $oldParts = $Old -split "[- :]"
    $newParts = $New -split "[- :]"

    function Color-Part {
        param (
            [string]$OldVal,
            [string]$NewVal
        )
        if ("$OldVal" -eq "$NewVal") {
            Write-Host -NoNewline "$NewVal"
        } else {
            Write-Host -NoNewline "$NewVal" -ForegroundColor Green
            Set-Variable -Name changed -Value $true -Scope 1
        }
    }

    Color-Part $oldParts[0] $newParts[0] # y
    Write-Host -NoNewline "-"
    Color-Part $oldParts[1] $newParts[1] # m
    Write-Host -NoNewline "-"
    Color-Part $oldParts[2] $newParts[2] # d
    Write-Host -NoNewline " "
    Color-Part $oldParts[3] $newParts[3] # H
    Write-Host -NoNewline ":"
    Color-Part $oldParts[4] $newParts[4] # M
    Write-Host -NoNewline ":"
    Color-Part $oldParts[5] $newParts[5] # S

    if ($changed) {
        Write-Host " (new)" -ForegroundColor Green
    } else {
        Write-Host " (new)"
    }
}

Main
