
# Timestamp Changer

Timestamps Changer is a lightweight Bash and PowerShell-based utility that integrates directly into the Windows File Explorer context menu, enabling you to **copy** and **paste** file and folder timestamps with ease.

This tool is especially useful when you need to preserve or replicate Date Created and Date Modified values across files or folders – ideal for organizing backups, restoring files, or syncing metadata.

### Features

#### Explorer Context Menu Integration

Adds convenient right-click options for both files and folders:

`🕗 Timestamp Changer`  
&nbsp; &nbsp; `Copy`  
&nbsp; &nbsp; `Paste`  
&nbsp; &nbsp; `Paste 'Date Created'`  
&nbsp; &nbsp; `Paste 'Date Modified'`  

#### Copy Mode

Stores the selected file or folder's Date Created and Date Modified timestamps for reuse.

#### Paste Mode

Applies the previously copied timestamps to the currently selected file or folder.

#### Selective Timestamp Paste

Use the specific `Paste 'Date Created'` or `Paste 'Date Modified'` options to update only the desired timestamp.

### Usage

Right-click on a file or folder and choose `Copy` under the context menu.  
This saves the timestamps to a temporary location ("clipboard").

Right-click on another file or folder and choose:

`Paste` – to apply both timestamps

`Paste 'Date Created'` – to apply only the creation date

`Paste 'Date Modified'` – to apply only the modified date

### Requirements

Windows 10/11

PowerShell 5.1 or later

Admin privileges for initial context menu setup

### Installation

### References

