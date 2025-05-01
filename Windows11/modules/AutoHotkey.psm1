using module .\Kozubenko.Utils.psm1

$HOTKEYS = "$($MyInvocation.MyCommand.Path)\..\..\.keyboard\hotkeys.ahk"                # Where the hotkeys are stored in the os-setup project
$STARTUP = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"        # Where hotkeys.ahk are moved to affect computer

function InstallCustomWindowsHotkeys() {
    if(-not(Test-Path $HOTKEYS)) {
        PrintDarkRed "Hotkeys.ahk not found under: .\Windows11\.keyboard. Quitting InstallCustomWindowsHotkeys..."
        RETURN;
    }

    if(-not(Test-Path "C:\Program Files\AutoHotkey")) {
        PrintRed "AutoHotkey not found. Installing..."
        curl -o "$HOME\Downloads\AutoHotkey-v2.exe" https://www.autohotkey.com/download/ahk-v2.exe

        if(-not(RunningAsAdmin)) {
            PrintRed "Script running w/o admin rights, expect an install elevation prompt..."
            Start-Sleep 1
        } 

        Start-Process -Wait -FilePath "$HOME\Downloads\AutoHotkey-v2.exe" -ArgumentList "/silent", "/Elevate" -PassThru
        
        if(-not(Test-Path "C:\Program Files\AutoHotkey")) {
            PrintRed "Unable to install AutoHotkeyV2. Aborting...InstallCustomWindowsHotkeys"
            RETURN;
        }
    }

    Copy-Item -Path $HOTKEYS -Destination "C:\Users\stasp\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

    PrintGreen "InstallCustomWindowsHotkeys Complete"
}

function BackupAutoHotkey() {
    $toBackup = "$STARTUP\hotkeys.ahk"

    if(-not(Test-Path $toBackup)) {  PrintRed "BackupAutoHotkey(): `$toBackup not found. `$toBackup: $toBackup"; RETURN;  }

    try {
        Copy-Item $toBackup $(ParentDir $HOTKEYS)
    }
    catch {  PrintRed "BackupAutoHotkey(): Failure! Reason: $($_.Exception.Message)"; RETURN; }

    PrintGreen "BackupAutoHotkey(): Success"
}