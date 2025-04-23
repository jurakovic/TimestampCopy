[CmdletBinding(PositionalBinding=$false)]
Param(
    [switch][Alias('h')]$help,
    [switch][Alias('v')]$version,
    [switch][Alias('i')]$install,
    [switch][Alias('q')]$quiet,
    [switch][Alias('u')]$uninstall,
    [string][Alias('a')]$action,
    [string]$path
)

##### Constants
$homepage = "https://github.com/jurakovic/timestamp-copy"
$versionn = "2.1.0-preview.1"
$scriptPath = "$PSCommandPath"
$iconPath = "$PSScriptRoot\tscp.ico"
$clipPath = "$HOME\.tscp"
$fRootKey = "HKEY_CLASSES_ROOT\*\shell\TimestampCopy"
$dRootKey = "HKEY_CLASSES_ROOT\Directory\shell\TimestampCopy"
$datetimeFormat = "yyyy-MM-dd HH:mm:ss"

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
    if ($option -ine "x") {
        Pause-Script "continue"
        Show-Menu
    }
}

function Perform-Action {
    param (
        [string]$Option
    )

    switch ($Option) {
        "i" { Install }
        "q" { $quiet=$true; Install }
        "u" { Uninstall }
        "x" { return }
        default { Write-Host "Unknown option: $Option" }
    }
}

function Pause-Script {
    param (
        [string]$Option = "exit"
    )
    Write-Host -NoNewLine "Press any key to $Option..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Install {
    net session *> $null
    if (-Not $?) {
        Write-Host "Not running as Admin"
        Pause-Script "exit"
        exit 1
    }

    $quietMode = If ($quiet) { "(Quiet Mode)" } Else { "" }
    Write-Host "Installing $quietMode..."
    Install-Internal -RootKey "$fRootKey"
    Install-Internal -RootKey "$dRootKey"
    Write-Host "Done"
}

function Install-Internal {
    param (
        [string]$RootKey
    )

    $itemPath = "$RootKey\shell"
    Add-MenuRoot -Key "$RootKey" -Label "Timestamp Copy" -Icon "$iconPath"
    Add-MenuItem -Key "$itemPath\010CopyTimestamps" -Label "Copy" -Action "Copy-Timestamps"
    Add-MenuItem -Key "$itemPath\020PasteTimestamps" -Label "Paste" -Action "Paste-Timestamps"
    Add-MenuItem -Key "$itemPath\030PasteDateCreated" -Label "Paste 'Date Created'" -Action "Paste-DateCreated"
    Add-MenuItem -Key "$itemPath\040PasteDateModified" -Label "Paste 'Date Modified'" -Action "Paste-DateModified"
}

function Add-MenuRoot {
    param (
        [string]$Key,
        [string]$Label,
        [string]$Icon
    )

    reg.exe add "$Key" /v MUIVerb /d "$Label" /f | Out-Null
    reg.exe add "$Key" /v SubCommands /f | Out-Null
    reg.exe add "$Key" /v Icon /d "$Icon" /f | Out-Null
}

function Add-MenuItem {
    param (
        [string]$Key,
        [string]$Label,
        [string]$Action
    )

    $headless = if ($quiet) { "conhost.exe --headless " } else { "" }
    $q = if ($quiet) { " -q" } else { "" }

    reg.exe add "$Key" /ve /d "$Label" /f | Out-Null
    reg.exe add "$Key\command" /ve /d "${headless}powershell -ExecutionPolicy ByPass -NoProfile -Command """"& '$scriptPath' -action ""'$Action'"" -path ""'%1'""$q""""" /f | Out-Null
}

function Uninstall {
    Write-Host "Uninstalling..."
    Uninstall-Internal -RootKey "$fRootKey"
    Uninstall-Internal -RootKey "$dRootKey"
    Remove-Item -Force -Path "$clipPath" *> $null
    Write-Host "Done"
}

function Uninstall-Internal {
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

    $item = Get-Item -Path "$FilePath"
    $dc = $item.CreationTime.ToString("$datetimeFormat")
    $dm = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Write-Host "Date Created:  $dc"
    Write-Host "Date Modified: $dm"

    Set-Content -Path "$clipPath" -Value "$dc`n$dm"

    Write-Host "---"
    Write-Host "Timestamps copied"
}

function Paste-Timestamps {
    param (
        [string]$FilePath
    )

    Guard-Clipboard

    $timestamps = Get-Content -Path "$clipPath"
    $dcNew = $timestamps[0]
    $dmNew = $timestamps[1]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Highlight-Diff -Label "Date Created: " -Old "$dcOld" -New "$dcNew"
    Write-Host "---"
    Highlight-Diff -Label "Date Modified:" -Old "$dmOld" -New "$dmNew"
    Write-Host "---"

    $applyChanges = if ($quiet) { "y" } else { Read-Host "Apply changes? (y/N)" }
    if ($applyChanges -ieq "y") {
        $item.CreationTime = [datetime]::ParseExact("$dcNew", "$datetimeFormat", $null)
        $item.LastWriteTime = [datetime]::ParseExact("$dmNew", "$datetimeFormat", $null)
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Paste-DateCreated {
    param (
        [string]$FilePath
    )

    Guard-Clipboard

    $timestamps = Get-Content -Path "$clipPath"
    $dcNew = $timestamps[0]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Highlight-Diff -Label "Date Created: " -Old "$dcOld" -New "$dcNew"
    Write-Host "---"
    Highlight-Diff -Label "Date Modified:" -Old "$dmOld" -New "$dmOld"
    Write-Host "---"

    $applyChanges = if ($quiet) { "y" } else { Read-Host "Apply changes? (y/N)" }
    if ($applyChanges -ieq "y") {
        $item.CreationTime = [datetime]::ParseExact("$dcNew", "$datetimeFormat", $null)
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Paste-DateModified {
    param (
        [string]$FilePath
    )

    Guard-Clipboard

    $timestamps = Get-Content -Path "$clipPath"
    $dmNew = $timestamps[1]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Highlight-Diff -Label "Date Created: " -Old "$dcOld" -New "$dcOld"
    Write-Host "---"
    Highlight-Diff -Label "Date Modified:" -Old "$dmOld" -New "$dmNew"
    Write-Host "---"

    $applyChanges = if ($quiet) { "y" } else { Read-Host "Apply changes? (y/N)" }
    if ($applyChanges -ieq "y") {
        $item.LastWriteTime = [datetime]::ParseExact("$dmNew", "$datetimeFormat", $null)
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Guard-Clipboard {
    if (-Not (Test-Path -Path "$clipPath")) {
        Write-Host "Timestamps clipboard empty."
        Pause-Script "exit"
        exit 0
    }

    $timestamps = Get-Content -Path "$clipPath"
    if ($timestamps.Count -ne 2) {
        Write-Host "Timestamps clipboard corrupted. Copy new timestamps."
        Pause-Script "exit"
        exit 0
    }

    try {
        [datetime]::ParseExact($timestamps[0], "$datetimeFormat", $null) | Out-Null
        [datetime]::ParseExact($timestamps[1], "$datetimeFormat", $null) | Out-Null
    } catch {
        Write-Host "Timestamps clipboard corrupted. Copy new timestamps."
        Pause-Script "exit"
        exit 0
    }
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

##### Main

if ($help) {
    Write-Host "For help visit $homepage"
    exit 0
}

if ($version) {
    Write-Host "$versionn"
    exit 0
}

if ($install) {
    Install
    exit 0
}

if ($uninstall) {
    Uninstall
    exit 0
}

if ($action -And $path) {
    Invoke-Expression "$($action) ""$($path)"""

    if (-Not $quiet) {
        Pause-Script
    }
    exit 0
}

Show-Menu
