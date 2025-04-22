
##### constants
$homepage = "https://github.com/jurakovic/timestamp-copy"
$version = "2.0.0-preview.1"
$psPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$scriptPath = "$PSCommandPath"
$iconPath = "$(Split-Path -Parent $PSCommandPath)\tscp.ico"
$fRootKey = "HKEY_CLASSES_ROOT\*\shell\TimestampCopy"
$dRootKey = "HKEY_CLASSES_ROOT\Directory\shell\TimestampCopy"
$clip_file = "$HOME\.tscp"
$datetime_format = "yyyy-MM-dd HH:mm:ss"

##### install/uninstall functions

function show_menu() {
    clear
    echo ""
    echo "  Timestamp Copy ($version)"
    echo "                            "
    echo "  [i] Install               "
    echo "  [u] Uninstall             "
    echo "                            "
    echo "  [q] Quit                  "
    echo ""
    $option = Read-Host "Choose option"
    clear
    __perform_action $option
    if ($option -ne "q") {
        __pause "continue"
        show_menu
    }
}

function __perform_action() {
    param (
        [string]$option
    )

    switch ($option) {
        "i" { install }
        "u" { uninstall }
        "q" { return }
        default { echo "unknown option: $option" }
    }
}

function __pause() {
    param (
        [string]$option="exit"
    )
    Write-Host -NoNewLine "Press any key to $option...";
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

function install() {
    net session *> $null
    if ($? -ne $True) {
        echo "Not running as Admin"
        __pause "exit"
        exit 1
    }

    echo "Installing..."
    install_internal "$fRootKey"
    install_internal "$dRootKey"
    echo "Done"
}

function install_internal() {
    param (
        [string]$rootKey
    )

    $itemPath = "$rootKey\shell"
    add_menu_root "$rootKey" "Timestamp Copy" "$iconPath"
    add_menu_item "$itemPath\010CopyDateCreatedModified" "Copy" "copy1"
    add_menu_item "$itemPath\020PasteDateCreatedModified" "Paste" "paste"
    add_menu_item "$itemPath\030PasteDateCreated" "Paste 'Date Created'" "pastedc"
    add_menu_item "$itemPath\040PasteDateModified" "Paste 'Date Modified'" "pastedm"
}

function add_menu_root() {
    param (
        [string]$key,
        [string]$label,
        [string]$icon
    )

    reg.exe add "$key" /v MUIVerb /d "$label" /f | Out-Null
    reg.exe add "$key" /v SubCommands /f | Out-Null
    reg.exe add "$key" /v Icon /d "$icon" /f | Out-Null
}

function add_menu_item() {
    param (
        [string]$key,
        [string]$label,
        [string]$arg
    )

    reg.exe add "$key" /ve /d "$label" /f | Out-Null
    reg.exe add "$key\command" /ve /d """$psPath"" ""$scriptPath"" ""$arg"" ""%1""" /f | Out-Null
}

function uninstall() {
  echo "Uninstalling..."
  uninstall_internal "$fRootKey"
  uninstall_internal "$dRootKey"
  rm -Force "$clip_file" *> $null
  echo "Done"
}

function uninstall_internal() {
    param (
        [string]$rootKey
    )

    reg.exe delete "$rootKey" /f *> $null
}

##### context menu commands (copy/paste functions)

function copy1 {
    param (
        [string]$filePath
    )

    $item = Get-Item "$filePath"
    $dc = $item.CreationTime.ToString($datetime_format)
    $dm = $item.LastWriteTime.ToString($datetime_format)

    echo "File/Folder:   $filePath"
    echo "---"
    echo "Date Created:  $dc"
    echo "Date Modified: $dm"

    Set-Content -Path "$clip_file" -Value "$dc`n$dm"

    echo "---"
    echo "Timestamps copied"
}

function pastedc {
    param (
        [string]$filePath
    )

    guard

    $timestamps = Get-Content -Path "$clip_file"
    $dc_new = $timestamps[0]

    $item = Get-Item "$filePath"
    $dc_old = $item.CreationTime.ToString($datetime_format)
    $dm_old = $item.LastWriteTime.ToString($datetime_format)

    echo "File/Folder:   $filePath"
    echo "---"
    highlight_diff "Date Created: " "$dc_old" "$dc_new"
    echo "---"
    highlight_diff "Date Modified:" "$dm_old" "$dm_old"
    echo "---"

    $applyChanges = Read-Host "Apply changes? (y/N)"
    if ($applyChanges -eq "y") {
        $item.CreationTime = [datetime]::ParseExact($dc_new, $datetime_format, $null)
        echo "Done"
    } else {
        echo "Canceled"
    }
}

function pastedm {
    param (
        [string]$filePath
    )

    guard

    $timestamps = Get-Content -Path "$clip_file"
    $dm_new = $timestamps[1]

    $item = Get-Item "$filePath"
    $dc_old = $item.CreationTime.ToString($datetime_format)
    $dm_old = $item.LastWriteTime.ToString($datetime_format)

    echo "File/Folder:   $filePath"
    echo "---"
    highlight_diff "Date Created: " "$dc_old" "$dc_old"
    echo "---"
    highlight_diff "Date Modified:" "$dm_old" "$dm_new"
    echo "---"

    $applyChanges = Read-Host "Apply changes? (y/N)"
    if ($applyChanges -eq "y") {
        $item.LastWriteTime = [datetime]::ParseExact($dm_new, $datetime_format, $null)
        echo "Done"
    } else {
        echo "Canceled"
    }
}

function paste {
    param (
        [string]$filePath
    )

    guard

    $timestamps = Get-Content -Path "$clip_file"
    $dc_new = $timestamps[0]
    $dm_new = $timestamps[1]

    $item = Get-Item "$filePath"
    $dc_old = $item.CreationTime.ToString($datetime_format)
    $dm_old = $item.LastWriteTime.ToString($datetime_format)

    echo "File/Folder:   $filePath"
    echo "---"
    highlight_diff "Date Created: " "$dc_old" "$dc_new"
    echo "---"
    highlight_diff "Date Modified:" "$dm_old" "$dm_new"
    echo "---"

    $applyChanges = Read-Host "Apply changes? (y/N)"
    if ($applyChanges -eq "y") {
        $item.CreationTime = [datetime]::ParseExact($dc_new, $datetime_format, $null)
        $item.LastWriteTime = [datetime]::ParseExact($dm_new, $datetime_format, $null)
        echo "Done"
    } else {
        echo "Canceled"
    }
}

function guard() {
    if (-not (Test-Path "$clip_file")) {
        echo "Timestamps clipboard empty."
        __pause "exit"
        exit 0
    }

    $timestamps = Get-Content -Path "$clip_file"
    if ($timestamps.Count -ne 2) {
        echo "Timestamps clipboard corrupted. Copy new timestamps."
        __pause "exit"
        exit 0
    }

    $dc = $timestamps[0]
    $dm = $timestamps[1]

    try {
        [datetime]::ParseExact($dc, $datetime_format, $null) | Out-Null
        [datetime]::ParseExact($dm, $datetime_format, $null) | Out-Null
    } catch {
        echo "Timestamps clipboard corrupted. Copy new timestamps."
        __pause "exit"
        exit 0
    }
}

function highlight_diff() {
    param (
        [string]$label,
        [string]$old,
        [string]$new
    )

    $changed = $false

    Write-Host "$label $old (old)"
    Write-Host -NoNewline "$label "

    $oldParts = $old -split '[- :]'
    $newParts = $new -split '[- :]'

    function color_part {
        param (
            [string]$oldVal,
            [string]$newVal
        )
        if ($oldVal -eq $newVal) {
            Write-Host -NoNewline $newVal
        } else {
            Write-Host -NoNewline $newVal -ForegroundColor Green
            Set-Variable -Name changed -Value $true -Scope 1
        }
    }

    color_part $oldParts[0] $newParts[0] # y
    Write-Host -NoNewline "-"
    color_part $oldParts[1] $newParts[1] # m
    Write-Host -NoNewline "-"
    color_part $oldParts[2] $newParts[2] # d
    Write-Host -NoNewline " "
    color_part $oldParts[3] $newParts[3] # H
    Write-Host -NoNewline ":"
    color_part $oldParts[4] $newParts[4] # M
    Write-Host -NoNewline ":"
    color_part $oldParts[5] $newParts[5] # S

    if ($changed) {
        Write-Host " (new)" -ForegroundColor Green
    } else {
        Write-Host " (new)"
    }
}

##### Main

if ($args.Count -eq 1) { # cli arguments
    <##>if ($args[0] -in @("-v", "--version")) {
        Write-Output $version
    }
    elseif ($args[0] -in @("-i", "--install")) {
        install
    }
    elseif ($args[0] -in @("-u", "--uninstall")) {
        uninstall
    }
    elseif ($args[0] -in @("-h", "--help", "-?")) {
        echo "For help visit $homepage"
    }
} elseif ($args.Count -eq 2) { # context menu commands
    Invoke-Expression "$($args[0]) $($args[1])"
    __pause
} else {
    show_menu
}
