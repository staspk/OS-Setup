using module .\Kozubenko.Utils.psm1
using module .\Kozubenko.Git.psm1

$GLOBALS = "$([System.IO.Path]::GetDirectoryName($PROFILE))\globals"
$METHODS = @("NewVar(`$name, `$value = `$PWD.Path)", "SetVar(`$name, `$value)", "DeleteVar(`$varName)", "SetLocation(`$path = `$PWD.Path)");  function List { foreach ($method in $METHODS) {  WriteCyan $method }  }

function Restart {  Invoke-Item $pshome\pwsh.exe; exit  }
function Open($path = $PWD.Path) {
    if (-not(TestPathSilently($path))) { WriteRed "`$path is not a valid path. `$path == $path"; return; }
    if (IsFile($path)) {  explorer.exe "$([System.IO.Path]::GetDirectoryName($path))"  }
    else {  explorer.exe $path  }
}
function VsCode($path = $PWD.Path) {
    if (-not(TestPathSilently($path))) { WriteRed "`$path is not a valid path. `$path == $path"; return; }
    if (IsFile($path)) {  $containingDir = [System.IO.Path]::GetDirectoryName($path); code $containingDir; return; }
    else { code $path }
}
function LoadInGlobals($deleteVarName = "") {   # deletes duplicates as well
    $variables = @{}   # Dict{key==varName, value==varValue}
    $_globals = (Get-Content -Path $GLOBALS)
    
    if(-not($_globals)) {  WriteRed "Globals Empty"; return  }
    Clear-Host

    $lines = [System.Collections.Generic.List[Object]]::new(); $lines.AddRange($_globals)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $left = $lines[$i].Split("=")[0]
        $right = $lines[$i].Split("=")[1]
        if ($left -eq "" -or $right -eq "" -or $left -eq $deleteVarName -or $variables.ContainsKey($left)) {    # is duplicate if $variables.containsKey
            $lines.RemoveAt($i)
            if ($i -ne 0) {
                $i--
            }
        }
        else {
            $variables.Add($left, $right)
            Set-Variable -Name $left -Value $right -Scope Global

            if ($left -ne "startLocation") {    # startLocation visible on most startups anyways, no need to be redundant
                Write-Host "$left" -ForegroundColor White -NoNewline; Write-Host "=$right" -ForegroundColor Gray
            }
        }
    }
    Set-Content -Path $GLOBALS -Value $lines
    Write-Host
}
function SaveToGlobals([string]$varName, $varValue) {
    $lines = (Get-Content -Path $GLOBALS).Split([Environment]::NewLine)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $left = $lines[$i].Split("=")[0]
        if ($left -eq $varName) {
            $lines[$i] = "$varName=$varValue"
            Set-Content -Path $GLOBALS -Value $lines;   return;
        }
    }
    Add-Content -Path $GLOBALS -Value "$([Environment]::NewLine)$varName=$varValue"; Set-Variable -Name $varName -Value $varValue -Scope Global
}
function NewVar($name, $value = $PWD.Path) {
    if ([string]::IsNullOrEmpty($name)) { return }
    if ($name[0] -eq "$") { $name = $name.Substring(1, $name.Length - 1 ) }
    SaveToGlobals $name $value
    LoadInGlobals
}
function SetVar($name, $value) {
    if ([string]::IsNullOrEmpty($name) -or [string]::IsNullOrEmpty($value)) { return }
    if ($name[0] -eq "$") { $name = $name.Substring(1, $name.Length - 1 ) }
    SaveToGlobals $name $value
    LoadInGlobals
}
function DeleteVar($varName) {  Clear-Host; Write-Host; LoadInGlobals($varName)  }
function SetLocation($path = $PWD.Path) {
    if (-not(TestPathSilently($path))) {
        WriteRed "Given `$path is not a real directory. `$path == $path"; WriteRed "Exiting SetLocation..."; return
	}
	SaveToGlobals "startLocation" $path
	Restart
}

function Activate {     # Use from a Python project root dir, to activate a venv virtual environment. Assumes your file activate.ps1 is under .venv, not venv
    if (TestPathSilently "$PWD\.venv")    {  Invoke-Expression "$PWD\.venv\Scripts\Activate.ps1"    }
    if (TestPathSilently "$PWD\venv")     {  Invoke-Expression "$PWD\venv\Scripts\Activate.ps1"     }
}
function CheckGlobalsFile() {
    if (-not(TestPathSilently($GLOBALS))) {
        WriteRed "Globals file not found. `$GLOBALS == $GLOBALS"; WriteRed "Disabling Functions: { LoadInGlobals, SaveToGlobals, NewVar, SetVar, DeleteVar } "
        Remove-Item Function:LoadInGlobals; Remove-Item Function:SaveToGlobals; Remove-Item Function:NewVar; Remove-Item Function:SetVar; Remove-Item Function:DeleteVar
        return $false
    }
    return $true
}
function OnOpen() {
    if (CheckGlobalsFile) {
        LoadInGlobals        

        $openedTo = $PWD.Path
        if ($openedTo -ieq "$env:userprofile" -or $openedTo -ieq "C:\WINDOWS\system32") {  # Almost certainly, started powershell from taskbar/exe/shortcut and not from right_click->open_in_terminal. No specific directory in mind; defaulting to the global $startLocation.
            if ($startLocation -eq $null) {
                # Do Nothing
            }
            elseif (TestPathSilently $startLocation) {
                Set-Location $startLocation  }
            else {
                WriteRed "`$startLocation path does not exist anymore. Defaulting to userdirectory..."
                Start-Sleep -Seconds 3
                SetLocation $Env:USERPROFILE
            }
        }
    }
    Set-PSReadLineKeyHandler -Key Ctrl+z -Function ClearScreen
    Set-PSReadLineKeyHandler -Key Alt+Backspace -Description "Delete Line" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
        [Microsoft.PowerShell.PSConsoleReadLine]::KillLine()
    }
    
    SetAliases Restart @("r", "re", "res")
    SetAliases VsCode  @("vs", "vsc")
    SetAliases Clear-Host  @("z")
    SetAliases "C:\Program Files\Notepad++\notepad++.exe" @("note", "npp")
}
OnOpen
