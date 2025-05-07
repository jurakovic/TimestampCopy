
# Timestamp Copy

[`TimestampCopy.ps1`](./TimestampCopy.ps1) is PowerShell script that integrates directly into the Windows File Explorer context menu, enabling you to **copy** and **paste** file and folder timestamps with ease.

This solution is especially useful when you need to preserve or replicate Date Created and Date Modified values across files or folders – ideal for organizing backups, restoring files, or syncing metadata.

![ContextMenu](img/contextmenu.png)  
<sup>(Context Menu)</sup>

### Download

[![GitHub Release](https://img.shields.io/github/v/release/jurakovic/timestamp-copy?include_prereleases)](https://github.com/jurakovic/timestamp-copy/releases/latest)

### Usage (Context Menu)

Right-click on a file or folder under the context menu and choose:

- `Copy` – to copy the selected file or folder's Date Created and Date Modified timestamps to a clipboard.

Right-click on another file or folder and choose:

- `Paste` – to apply previously copied timestamps.
- `Paste "Date Created"` – to apply only the Date Created.
- `Paste "Date Modified"` – to apply only the Date Modified.

Right-click on the same (or any other) file or folder and choose:

- `Undo` – to restore the previously overwritten timestamp(s).

### Usage (CLI)

The script is made to be run from the context menu, but it can also be run directly from the command line.

Parameters:
```text
-Help (-h)                       Print help.
-Version (-v)                    Print the current version of the script.
-Install (-i)                    Install the context menu entries for the script in Standalone Mode.
-InstallBackgroundMode (-b)      Install the context menu entries for the script in Background Mode (runs without a terminal window).
-Uninstall (-u)                  Uninstall the context menu entries and remove related data.
-Copy (-c) <path>                Copy timestamps of the specified file or folder to the clipboard.
-Paste (-p) <path>               Paste the copied timestamps to the specified file or folder.
-PasteDateCreated (-pc) <path>   Paste only the copied Date Created timestamp to the specified file or folder.
-PasteDateModified (-pm) <path>  Paste only the copied Date Modified timestamp to the specified file or folder.
-Undo (-z)                       Restore the previous timestamps of the last modified file or folder.
-Quiet (-q)                      Suppress output messages. After run check $LastExitCode or $? for exit code.
-SkipConfirm (-y)                Skip confirmation prompts when applying changes.
*none*                           Show the install/uninstall menu.
```

Some examples:
```powershell
# Copy timestamps
.\TimestampCopy.ps1 -c "C:\Foo.txt"

# Paste timestamps
.\TimestampCopy.ps1 -p "D:\Bar.txt"

# Paste timestamps without output messages (confirm prompt still shown)
.\TimestampCopy.ps1 -p "D:\Bar.txt" -q

# Paste timestamps without output messages and confirm prompt
.\TimestampCopy.ps1 -p "D:\Bar.txt" -q -y

# Paste Date Created
.\TimestampCopy.ps1 -pc "D:\Bar.txt"

# Paste Date Modified
.\TimestampCopy.ps1 -pm "D:\Bar.txt"

# Undo
.\TimestampCopy.ps1 -z
```

It can also be run without any argument, which will show the install/uninstall menu:

```text
Timestamp Copy (2.1.0)

[i] Install
[b] Install (Background Mode)
[u] Uninstall
[h] Help

[q] Quit

Choose option:
```

### Requirements

- Windows 10/11
- PowerShell 5.1 or later  
- Administrator privileges (required for installation)

### Installation

1. Clone the repository.
	```powershell
	git clone https://github.com/jurakovic/timestamp-copy.git
	```
2. Open an elevated Powershell terminal ('Run as Administrator').
3. Navigate to the directory where you cloned the repository.
	```powershell
	cd timestamp-copy
	```

> If already not set, you may need to change the execution policy to allow running scripts.
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser Unrestricted
> ```
> More details about the PowerShell execution policies can be found [here](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.5) and [here](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.5#parameters).

4. Install the context menu entries.  
	Run the script with the `-i` option
	```powershell
	.\TimestampCopy.ps1 -i
	```
	or with the `-b` option to install it in Background Mode (without a terminal window)
	```powershell
	.\TimestampCopy.ps1 -b
	```

> If you set different execution policy, you may need to revert it back to the default.
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser Restricted
> ```

### Implementation Details

#### Operations

The script implements five main operations:

**`Copy`**
- Copies the Date Created and Date Modified timestamps of a specified file or folder to the clipboard.
- It will output the specified file or folder's path and the copied timestamps.

**`Paste`**
- Applies the copied timestamps to a specified file or folder.
- It will output the specified file or folder's path and the current ("old") and copied ("new") timestamps.
- It will ask for confirmation before applying the changes.

**`Paste "Date Created"`**
- Applies only the copied Date Created timestamp to a specified file or folder.
- The rest of the logic is the same as for the `Paste` operation.

**`Paste "Date Modified"`**
- Applies only the copied Date Modified timestamp to a specified file or folder.
- The rest of the logic is the same as for the `Paste` operation.

**`Undo`**
- Restores the previous timestamps of the last modified file or folder.
- It is avaliable on all files and folders, but it will only restore the timestamps for the file or folder that was last used in the `Paste` (or `Undo`) operation.
- Each `Paste` operation, before overwriting timestamps with the previously copied ("new") ones, stores the specified file or folder's path and the current ("old") timestamps to an "undo-clipboard". (More details below.)
- The `Undo` itself then does the same as the `Paste` operation – it stores the restored file or folder's path and the current timestamps to a temporary location. If you again choose `Undo`, it will restore the timestamps back to the "new" values.
- That means if you choose `Undo` repeatedly, it will for the same file or folder rotate the timestamps between the "old" and "new" values.

#### Script Modes

The script can operate in three different modes, and each mode defines slightly different behavior of the script.  
The mode is determined by the way the script is executed, and although there is a parameter for that it's not meant to be set by the user. The default is *Terminal* and the script will set the desired mode for the context menu integration based on installation user input.  

***`Terminal`***
- If the script is run from the terminal, it will use the existing terminal window to display output messages.
- It won't use *Pause* at the end of the operation, because the terminal will stay open anyway and you will see all messages.
- If `-q` option is used, it will suppress all output messages, but it will still show the confirmation prompt.
- If `-y` option is used, it will show output messages, but it will suppress the confirmation prompt and script will automatically proceed with the operation as if the user has confirmed prompt.
- If both `-q` and `-y` options are used, it will suppress both output messages and the confirmation prompt and script will automatically proceed with the operation as if the user has confirmed prompt.

***`Standalone`***
- This is the default mode for context menu integration.
- Each operation will run in a new terminal window.
- It will use *Pause* at the end of the operation to prevent automatically closing the window, so you can see the output messages.
- The window will close after pressing any key.
- No `-q` or `-y` options are used, so the script will show output messages and confirmation prompt.

***`Background`***
- This is an alternative option for context menu integration.
- The script will run in the background, without a terminal window.
- There are no output messages or confirmation prompts, script will automatically proceed with the operation as if the user has confirmed prompt.
- If there were any errors, error message will be shown in a *MessageBox*.

#### Clipboard

As a "clipboard" the script uses two files in the `%LOCALAPPDATA%\TimestampCopy` folder.  
- `clip` – stores the copied timestamps
- `clip-undo` – stores the data for the `Undo` operation

File contents are Base64 encoded to avoid manipulation to ensure that the data is stored in a consistent format.  
If the contents are not in the expected format, the script will output an error message and exit.  

### Screenshots

Copy  
![Copy](img/copy.png)

Paste  
![Copy](img/paste.png)

### Limitation

This script is designed to work with **only one selected file or folder at a time**. While it does appear in the context menu when multiple items are selected, it will be executed **independently for each item**. This can lead to unexpected behavior. For accurate and predictable results, always use it with a single selection.

### Disclaimer

This script is provided **as-is**, without any warranties or guarantees of fitness for a particular purpose. While it should work reliably in most cases, use it at your own risk.  

---

#### Old Versions

| Release | Source | Description |
| --- | --- | --- |
| [1.0.0](https://github.com/jurakovic/timestamp-copy/releases/tag/v1.0.0) | [1.0.0](https://github.com/jurakovic/timestamp-copy/tree/v1.0.0) | Initial [`tscp.sh`](https://github.com/jurakovic/timestamp-copy/blob/v1.0.0/tscp.sh) written in Bash. It was created solely for educational and experimental use. |
| [2.0.0-preview.1](https://github.com/jurakovic/timestamp-copy/releases/tag/v2.0.0-preview.1) | [2.0.0-preview.1](https://github.com/jurakovic/timestamp-copy/tree/v2.0.0-preview.1) | Direct port of the original Bash script into PowerShell, with only the minimal necessary changes made to ensure proper execution in a PowerShell environment. |
| [2.0.0](https://github.com/jurakovic/timestamp-copy/releases/tag/v2.0.0) | [2.0.0](https://github.com/jurakovic/timestamp-copy/tree/v2.0.0) | Complete rewrite of the original Bash script in native PowerShell syntax. |

---

### [References](./REFERENCES.md)
