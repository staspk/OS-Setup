function NewRegistryKey($path, $name) {
	if (-not (Test-Path $path)) {
		New-Item -Path $path -Name $name
	}
	else {  WriteRed("New Registry Function used, but registry key already exists. Path: $path. Name: $name")  }
}

function RegistryPropertyEditOrAdd($path, $propertyName, [int]$value, $propertyType = "DWORD") {
	$exists =  If ((Get-Item $path).property -match $propertyName) {"true"}

	if($exists) {
		Set-ItemProperty -Path $path -Name $propertyName -Value $value  }
	else {
		New-ItemProperty -Path $path -Name $propertyName -PropertyType $propertyType -Value $value | Out-Null  }
}

enum FileExplorerLaunchTo {  ThisPC = 1; QuickAccess = 2; Downloads = 3  }
function FileExplorerDefaultOpenTo( [FileExplorerLaunchTo] $launchTo = "Downloads") { 
	$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	[int]$enumAsInt = [Enum]::Parse([FileExplorerLaunchTo], $launchTo)

	RegistryPropertyEditOrAdd $path "LaunchTo" $enumAsInt

	WriteCyan("FILE EXPLORER: will now default-open to: $launchTo")
}

function ShowRecentInQuickAccess([bool]$bool = $false ) { 
	$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
	$propName = "ShowRecent"

	RegistryPropertyEditOrAdd $path $propName $bool

	if ($bool) { WriteCyan("FILE EXPLORER: Quick Access will now be automatically populated with Recently Used Files [preset win11 behavior]") }
	else {
		WriteCyan("FILE EXPLORER: Will stop automatically populating Quick Access with Recently Used Directories/Files")
	}
}

function VisibleFileExtensions([bool] $bool = $true) {
	$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	$propName = "HideFileExt"

	$propVal = If ($bool) { 0 } Else { 1 }

	RegistryPropertyEditOrAdd $path $propName $propVal

	WriteCyan("FILE EXPLORER: File's format/extension visibility boolean status updated to $bool")
}

function VisibleHiddenFiles([bool]$bool = $true) {
	$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	$propName = "Hidden"
	
	$propVal = If ($bool) { 0 } Else { 1 }

	RegistryPropertyEditOrAdd $path $propName $propVal

	WriteCyan("FILE EXPLORER: Hidden files & folders boolean status set to: $bool")
}


function TaskBarAlignment([ValidateRange(0, 1)] $alignment = 0) {
	$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	$propName = "TaskbarAl"

	RegistryPropertyEditOrAdd $path $propName $alignment

	if ($alignment -eq 0) {  WriteCyan("TASKBAR: Alignment set to left.")  }
	elseif ($alignment -eq 1) {  WriteCyan("TASKBAR: Alignment set to center.") }
}

function TaskBarRemoveTaskView {
	$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	$propName = "ShowTaskViewButton"

	ChangeRegistryValue $path $propName 0

	WriteCyan("TASKBAR: Task View Removed")
}

function DisableWidgets {
	$path = "HKLM:\SOFTWARE\Policies\Microsoft"
	$key = "DSH";  $propName = "AllowNewsAndInterests"

	NewRegistryKey $path $key
	RegistryPropertyEditOrAdd "$path\$key" $propName 0
	
	WriteRed("Disabled Widgets. Please RESTART Computer to finalize.")
}


Export-ModuleMember -Function FileExplorerDefaultOpenTo, ShowRecentInQuickAccess, VisibleFileExtensions, VisibleHiddenFiles, TaskBarAlignment, TaskBarRemoveTaskView, DisableWidgets

