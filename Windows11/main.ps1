#Requires -RunAsAdministrator
#Requires -Version 5.1

using module ".\modules\Kozubenko.Utils.psm1"
using module ".\modules\Powershell.psm1"
using module ".\modules\Registry.psm1"
using module ".\modules\VsCode.psm1"
Import-Module $PSScriptRoot\modules\WinGet.psm1 -Force
Import-Module $PSScriptRoot\modules\OneDrive.psm1 -Force

$host.ui.RawUI.WindowTitle = "Win11 Instant Setup - 23H2+"
Clear-Host


# FileExplorerDefaultOpenTo ([FileExplorerLaunchTo]::Downloads)
# ShowRecentInQuickAccess $false
# VisibleFileExtensions $true
# VisibleHiddenFiles $true
# RestoreClassicContextMenu

# TaskBarAlignment ([Alignment]::Left)
# TaskBarRemoveTaskView
# DisableAdsInSearchBar
# DisableWidgets
# RestartExplorer


# SetVerticalScrollSpeed 9

# UninstallBloat
# InstallSoftware
# UninstallAndAttemptAnnihilationOfOneDrive


# $configurer = [PowershellConfigurer]::PrintCorrectFolderStruture()
# $configurer = [PowershellConfigurer]::new().SaveProfileFilesToScriptPackage()
# $configurer = [PowershellConfigurer]::new().Install_forCurrentUser()


$VsCode = [VsCode]::new().BackupVsCode()


function GitConfig ($email, $names) {
    git config --global user.email $email
    git config --global user.name $name
}
# GitConfig("someone@gmail.com", "George CarMichael")




# Remove-Item $env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe      # Remove MicrosoftStore PythonLauncher that shows up as version 0.0.0.0


