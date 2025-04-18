function WriteRed($msg, $newLine = $true)      {  if($newLine) { Write-Host $msg -ForegroundColor Red }      else { Write-Host $msg -ForegroundColor Red -NoNewline }        }
function WriteDarkRed($msg, $newLine = $true)  {  if($newLine) { Write-Host $msg -ForegroundColor DarkRed }   else { Write-Host $msg -ForegroundColor DarkRed -NoNewline }    }
function WriteYellow($msg, $newLine = $true)   {  if($newLine) { Write-Host $msg -ForegroundColor Yellow }    else { Write-Host $msg -ForegroundColor Yellow -NoNewline }     }
function WriteCyan($msg, $newLine = $true)     {  if($newLine) { Write-Host $msg -ForegroundColor Cyan }      else { Write-Host $msg -ForegroundColor Cyan -NoNewline }       }
function WriteGreen($msg, $newLine = $true)    {  if($newLine) { Write-Host $msg -ForegroundColor Green }     else { Write-Host $msg -ForegroundColor Green -NoNewline }      }
function WriteDarkGreen($msg, $newLine = $true){  if($newLine) { Write-Host $msg -ForegroundColor DarkGreen } else { Write-Host $msg -ForegroundColor DarkGreen -NoNewline }  }
function WriteGray($msg, $newLine = $true)     {  if($newLine) { Write-Host $msg -ForegroundColor Gray }      else { Write-Host $msg -ForegroundColor Gray -NoNewline }       }
function WriteWhite($msg, $newLine = $true)    {  if($newLine) { Write-Host $msg -ForegroundColor White }    else { Write-Host $msg -ForegroundColor White -NoNewline }      }
function WriteErrorExit([string]$errorMsg) {
    Write-Host $errorMsg -ForegroundColor DarkRed
    Write-Host "Exiting Script..." -ForegroundColor DarkRed
    exit
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



Export-ModuleMember -Function WriteObj, WriteCyan, WriteGreen, WriteDarkGreen, WriteRed, WriteDarkRed, WriteYellow, WriteGray, WriteWhite, WriteErrorExit,
NumberOfItemsInDir, NumberOfFoldersInDir, NumberOfFilesInDir, TestPathSilently, RemoveFromEnvironmentPath
