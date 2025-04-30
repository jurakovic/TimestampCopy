
# Timestamp Copy

[`TimestampsCopy.ps1`](./TimestampCopy.ps1) is PowerShell script that integrates directly into the Windows File Explorer context menu, enabling you to **copy** and **paste** file and folder timestamps with ease.

This solution is especially useful when you need to preserve or replicate Date Created and Date Modified values across files or folders – ideal for organizing backups, restoring files, or syncing metadata.

![ContextMenu](img/contextmenu.png)  
<sup>(Context Menu)</sup>

### Download

[![GitHub Release](https://img.shields.io/github/v/release/jurakovic/timestamp-copy?include_prereleases)](https://github.com/jurakovic/timestamp-copy/releases/latest)

### Usage (Context Menu)

Right-click on a file or folder under the context menu and choose:

- `Copy` – to copy the selected file or folder's Date Created and Date Modified timestamps to a clipboard.

Right-click on another file or folder and choose:

- `Paste` – to apply previously copied timestamps  
- `Paste "Date Created"` – to apply only the Date Created  
- `Paste "Date Modified"` – to apply only the Date Modified  

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
Timestamp Copy (2.1.0-preview.1)

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
4. Install the context menu entries.  
	Run the script with the `-i` option
	```powershell
	.\TimestampCopy.ps1 -i
	```
	or with the `-b` option to install it in Background Mode (without a terminal window)
	```powershell
	.\TimestampCopy.ps1 -b
	```

### Implementation Details

todo: all operations, variants, modes, validations, examples, etc.

<!-- backup
The `Undo` operation is avaliable on all files and folders, but it will only restore the timestamps for the file or folder that was last used in the `Paste` (or `Undo`) operation.
Each `Paste` operation, before overwriting timestamps with the previously copied ("new") ones, stores the selected file or folder's path and the current ("old") timestamps to a temporary location.
The `Undo` itself then does the same as the `Paste` operation – it stores the undo-*ed* file or folder's path and the current timestamps to a temporary location. If you again choose `Undo`, it will restore the timestamps back to the "new" values.
That means if you choose `Undo` repeatedly, it will for the same file or folder rotate the timestamps between the "old" and "new" values.
-->

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
| [1.0.0](https://github.com/jurakovic/timestamp-copy/releases/tag/v.1.0.0) | [1.0.0](https://github.com/jurakovic/timestamp-copy/tree/v.1.0.0) | Initial [`tscp.sh`](https://github.com/jurakovic/timestamp-copy/blob/v.1.0.0/tscp.sh) written in Bash. It was created solely for educational and experimental use. |
| [2.0.0-preview.1](https://github.com/jurakovic/timestamp-copy/releases/tag/v2.0.0-preview.1) | [2.0.0-preview.1](https://github.com/jurakovic/timestamp-copy/tree/v.2.0.0-preview.1) | Direct port of the original Bash script into PowerShell, with only the minimal necessary changes made to ensure proper execution in a PowerShell environment. |
| [2.0.0](https://github.com/jurakovic/timestamp-copy/releases/tag/v2.0.0) | [2.0.0](https://github.com/jurakovic/timestamp-copy/tree/v.2.0.0) | Complete rewrite of the original Bash script in native PowerShell syntax. |

---

#### References

<https://stackoverflow.com/questions/20449316/how-add-context-menu-item-to-windows-explorer-for-folders>  
<https://www.tomshardware.com/software/windows/how-to-add-custom-shortcuts-to-the-windows-11-or-10-context-menu>  
<https://blog.sverrirs.com/2014/05/creating-cascading-menu-items-in.html>  
<https://learn.microsoft.com/en-us/windows/win32/shell/context-menu-handlers>  
<https://mrlixm.github.io/blog/windows-explorer-context-menu/>  
