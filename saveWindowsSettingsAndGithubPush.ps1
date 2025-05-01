using module .\Windows11\modules\Kozubenko.Utils.psm1
using module .\Windows11\modules\AutoHotkey.psm1
using module .\Windows11\modules\VsCode.psm1


param(
    $commitMessage
)

BackupAutoHotkey
$VsCode = [VsCode]::new().BackupVsCode()

if($commitMessage -eq $null) {
    $commitMessage = "Automatic Settings Backup"
}

Push $commitMessage