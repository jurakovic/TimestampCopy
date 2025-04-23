[CmdletBinding(PositionalBinding=$false)]
Param(
    [switch][Alias('h')]$help,
    [switch][Alias('v')]$version,
    [switch][Alias('i')]$install,
    [switch][Alias('u')]$uninstall,
    [string][Alias('a')]$action,
    [string]$path
)

##### Constants
$homepage = "https://github.com/jurakovic/timestamp-copy"
$versionn = "2.1.0-preview.1"
$appdataPath = "$env:LOCALAPPDATA\TimestampCopy"
$scriptPath = "$appdataPath\tscp.ps1"
$iconPath = "$appdataPath\icon.ico"
$clipFile = "$appdataPath\clip"
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

    Write-Host "Installing..."
    Setup-AppData
    Install-Internal -RootKey "$fRootKey"
    Install-Internal -RootKey "$dRootKey"
    Write-Host "Done"
}

function Setup-AppData {
    New-Item -Path "$appdataPath" -ItemType Directory -Force | Out-Null
    Copy-Item "$PSCommandPath" -Destination "$scriptPath"
    $iconBytes = Get-Icon
    [IO.File]::WriteAllBytes($iconPath, $iconBytes)
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

    reg.exe add "$Key" /ve /d "$Label" /f | Out-Null
    reg.exe add "$Key\command" /ve /d "powershell -ExecutionPolicy ByPass -NoProfile -Command """"& '$scriptPath' -action ""'$Action'"" -path ""'%1'""""""" /f | Out-Null
}

function Uninstall {
    Write-Host "Uninstalling..."
    Uninstall-Internal -RootKey "$fRootKey"
    Uninstall-Internal -RootKey "$dRootKey"
    Remove-Item -Recurse -Force -Path "$appdataPath" *> $null
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

    Set-Content -Path "$clipFile" -Value "$dc`n$dm"

    Write-Host "---"
    Write-Host "Timestamps copied"
}

function Paste-Timestamps {
    param (
        [string]$FilePath
    )

    Guard-Clipboard

    $timestamps = Get-Content -Path "$clipFile"
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

    $applyChanges = Read-Host "Apply changes? (y/N)"
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

    $timestamps = Get-Content -Path "$clipFile"
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

    $applyChanges = Read-Host "Apply changes? (y/N)"
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

    $timestamps = Get-Content -Path "$clipFile"
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

    $applyChanges = Read-Host "Apply changes? (y/N)"
    if ($applyChanges -ieq "y") {
        $item.LastWriteTime = [datetime]::ParseExact("$dmNew", "$datetimeFormat", $null)
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Guard-Clipboard {
    if (-Not (Test-Path -Path "$clipFile")) {
        Write-Host "Timestamps clipboard empty."
        Pause-Script "exit"
        exit 0
    }

    $timestamps = Get-Content -Path "$clipFile"
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

function Get-Icon {
    $iconCompressedBase64 = @'
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
'@
    $compressedBytes = [Convert]::FromBase64String($iconCompressedBase64)
    $inMs  = [System.IO.MemoryStream]::new([byte[]]$compressedBytes)
    $outMs = [System.IO.MemoryStream]::new()
    $gzip  = [IO.Compression.GZipStream]::new($inMs, [IO.Compression.CompressionMode]::Decompress)
    $gzip.CopyTo($outMs)
    $gzip.Close()
    return $outMs.ToArray()
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
    Pause-Script
    exit 0
}

Show-Menu
