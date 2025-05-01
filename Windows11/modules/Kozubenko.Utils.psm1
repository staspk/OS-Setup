function PrintRed($msg, $newLine = $true)      {  if($newLine) { Write-Host $msg -ForegroundColor Red }      else { Write-Host $msg -ForegroundColor Red -NoNewline }        }
function PrintDarkRed($msg, $newLine = $true)  {  if($newLine) { Write-Host $msg -ForegroundColor DarkRed }   else { Write-Host $msg -ForegroundColor DarkRed -NoNewline }    }
function PrintYellow($msg, $newLine = $true)   {  if($newLine) { Write-Host $msg -ForegroundColor Yellow }    else { Write-Host $msg -ForegroundColor Yellow -NoNewline }     }
function PrintCyan($msg, $newLine = $true)     {  if($newLine) { Write-Host $msg -ForegroundColor Cyan }      else { Write-Host $msg -ForegroundColor Cyan -NoNewline }       }
function PrintGreen($msg, $newLine = $true)    {  if($newLine) { Write-Host $msg -ForegroundColor Green }     else { Write-Host $msg -ForegroundColor Green -NoNewline }      }
function PrintDarkGreen($msg, $newLine = $true){  if($newLine) { Write-Host $msg -ForegroundColor DarkGreen } else { Write-Host $msg -ForegroundColor DarkGreen -NoNewline }  }
function PrintGray($msg, $newLine = $true)     {  if($newLine) { Write-Host $msg -ForegroundColor Gray }      else { Write-Host $msg -ForegroundColor Gray -NoNewline }       }
function PrintWhite($msg, $newLine = $true)    {  if($newLine) { Write-Host $msg -ForegroundColor White }    else { Write-Host $msg -ForegroundColor White -NoNewline }      }
function PrintErrorExit([string]$errorMsg) {
    Write-Host $errorMsg -ForegroundColor DarkRed
    Write-Host "Exiting Script..." -ForegroundColor DarkRed
    exit
}

function ParentDir($path) {
    return [System.IO.Path]::GetDirectoryName($path)
}

function RunningAsAdmin() {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function NumberOfItemsInDir($pathToDir, $isRecursive = $false) {
    if($isRecursive) {
        return (Get-ChildItem -Path $pathToDir -Recurse).Count  }
    else {
        return (Get-ChildItem -Path $pathToDir).Count
    }
}
function NumberOfFoldersInDir($pathToDir, $isRecursive = $false) {
    if($isRecursive) {
        return (Get-ChildItem -Path $pathToDir -Directory -Recurse).Count  }
    else {
        return (Get-ChildItem -Path $pathToDir -Directory).Count
    }
}
function NumberOfFilesInDir($pathToDir) {
    $itemsCount = NumberOfItemsInDir($pathToDir)
    $foldersCount = NumberOfFoldersInDir($pathToDir)
    return $($itemsCount - $foldersCount)
}

function TestPathSilently($dirPath, $returnPath = $false) { 
    $exists = Test-Path $dirPath -ErrorAction SilentlyContinue
    
    If (-not($returnPath)) {  return $exists }
    if (-not($exists))     {  return $null   }
    
    return $dirPath
}

function CheckIfGivenStringIsPotentialFilePath([string] $potentialPath) {   # Returns bool
    $invalidChars = [System.IO.Path]::InvalidPathChars
    
    if ($potentialPath.IndexOfAny($invalidChars) -eq -1) {
        return $true
    }
    return $false
}



Export-ModuleMember -Function WriteObj, PrintCyan, PrintGreen, PrintDarkGreen, PrintRed, PrintDarkRed, PrintYellow, PrintGray, PrintWhite, PrintErrorExit,
NumberOfItemsInDir, NumberOfFoldersInDir, NumberOfFilesInDir, TestPathSilently, RemoveFromEnvironmentPath
