#  "Microsoft.PowerShell_profile.ps1"   ==>   # For Console, but not ISE. Ideal for, like, code completions
#  "profile.ps1"                        ==>   # Console, ISE, Ideal for global use

# using module ".\Kozubenko.Utils.psm1"
# Import-Module ".\Kozubenko.Utils.psm1" -Force

class PowershellProfile {
    [string] $installFilesDir
    [string] $userDir
    [string] $allUsersDir

    PowershellProfile($installFilesDir, $userDir) {
        $this.installFilesDir = $installFilesDir
        $this.userDir = $userDir
    }

    ChangeUserDir($userDir) {  $this.userDir = $userDir  }                  #   <---- Sanitize before passing in param
    SetAllUsersDir($allUsersDir) {  $this.$allUsersDir = $allUsersDir }     #   <----

    SetupCurrentUser() {
        WriteYellow($this.installFilesDir)
        WriteYellow($this.userDir)
        mkdir -Force ("$($this.userDir)")
        # Get-ChildItem -Path $this.installFilesDir -Recurse | Move-Item -Destination $this.userDir
    }

    SetupAllUsers($allUsersDir)  {                                          #   <---- Sanitize before passing in param
        WriteRed("In SetupAllUsers")
    }
}

class Profile5 : PowershellProfile {    # Profile 5.1                                 
    static $userDir = "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowershell"          # default => C:\Users\{userName}\Documents\WindowsPowerShell
    static $allUsersDir = "$env:SystemRoot\System32\WindowsPowerShell\v1.0"                       # default => C:\Windows\System32\WindowsPowerShell\v1.0

    Profile5($installFilesDir) : base($installFilesDir, [Profile5]::userDir) {
        if (-not(TestPathSilently([Profile5]::userDir))) {
            $newUserDir = ""
            WriteRed("Profile5.1: Microsoft's Recommended Default Directory does not exist in default location: $([Profile5]::userDir)")

            do {
                $newUserDir = Read-Host "Please enter location of your Powershell 5.1 user directory. Note: This can be found running '`$profile' in Powershell5 (or 'exit')"
                if ($newUserDir -eq "exit") { exit }
            } while (-not (TestPathSilently($newUserDir)) )

            $this.ChangeUserDir($newUserDir)
        }
        WriteGreen "Profile5 Made. installFilesDir: $installFilesDir"
    }
}

class Profile7 : PowershellProfile {    # Profile 7.4+                               
    static $userDir     =  "$([Environment]::GetFolderPath("MyDocuments"))\Powershell"            #  default => C:\Users\{userName}\Documents\PowerShell 
    static $allUsersDir =  "$Env:ProgramFiles\PowerShell\7"                                       #  default => C:\Program Files\PowerShell\7

    Profile7($installFilesDir) : base($installFilesDir, [Profile7]$userDir) {
        if (-not(TestPathSilently([Profile7]::userDir))) {
            $newUserDir = ""
            WriteRed("Profile7.4+: Microsoft's Recommended Default Directory does not exist in default location: $([Profile7]::userDir)")

            do {
                $newUserDir = Read-Host "Please enter location of your Powershell 7.4+ user directory. Note: This can be found running '`$profile' in Powershell7 (or 'exit')"
                if ($newUserDir -eq "exit") { exit }
            } while (-not (TestPathSilently($newUserDir)) )

            $this.ChangeUserDir($newUserDir)
        }
        WriteGreen "Profile7 Made. installFilesDir: $installFilesDir"
    }
}

class PowershellConfigurer {
    $PROFILE = $Global:PROFILE             # auto variable set with constructor param
    
    [Profile5] $profile5 = $null
    [Profile7] $profile7 = $null

    PowershellConfigurer($pathToDirWithInstallFiles) {
        $itemsCountInDir = NumberOfItemsInDir $pathToDirWithInstallFiles
        $folderCountInDir = NumberOfFoldersInDir $pathToDirWithInstallFiles
        $fileCountInDir = NumberOfFilesInDir $pathToDirWithInstallFiles
        $modulesFolderOnTop = TestPathSilently "$pathToDirWithInstallFiles\modules"
        $curHostOnTop = TestPathSilently "$pathToDirWithInstallFiles\Microsoft.PowerShell_profile.ps1" $true
        $allHostsOnTop = TestPathSilently "$pathToDirWithInstallFiles\profile.ps1" $true
        $folder5Exists = TestPathSilently "$pathToDirWithInstallFiles\5"
        $folder7Exists = TestPathSilently "$pathToDirWithInstallFiles\7"

        if (-not (Test-Path $pathToDirWithInstallFiles)) {
            WriteErrorExit("PowershellConfigurer: Install Files Directory missing. Please Provide a '.powershell' folder in the directory running main.ps1 before retrying.")
        }
        if (-not (Test-Path $pathToDirWithInstallFiles\*)) {
            WriteErrorExit("PowershellConfigurer: Empty folder provided to PowershellConfigurer (pathToDirWithInstallFiles = '$pathToDirWithInstallFiles').")
        }
        if ($modulesFolderOnTop -and $folderCountInDir -gt 1 -and $itemsCountInDir -gt 3) {     # Implies high likelihood of collisions
            WriteErrorExit("PowershellConfigurer: .powershell folder structure is non-sensical. Fix before trying to use again.")
        }
        if (-not($modulesFolderOnTop) -and $folderCountInDir -gt 2) {   # Implies folder structure is correct, but can't be true if there are more than 2 folders
            WriteErrorExit("PowershellConfigurer: .powershell folder structure is non-sensical. Fix before trying to use again.")
        }
        if ($folder5Exists -and -not(Test-Path $pathToDirWithInstallFiles\5\*)) {     # folder 5 exists, but empty
            WriteErrorExit("PowershellConfigurer: .powershell\5 exists but is empty. Fix before trying to use again.")
        }
        if ($folder7Exists -and -not(Test-Path $pathToDirWithInstallFiles\7\*)) {     # folder 7 exists, but empty
            WriteErrorExit("PowershellConfigurer: .powershell\7 exists but is empty. Fix before trying to use again.")
        }

        if ($curHostOnTop -ne $null -or $allHostsOnTop -ne $null) {   # using files under .powershell, assuming user wants to only set up Powershell 5.1
            WriteRed "Reached 1"
            $this.profile5 = [Profile5]::new($pathToDirWithInstallFiles)
        }
        elseif ($fileCountInDir -eq 0 -and $folder5Exists -and -not($folder7Exists)) {  # .powershell has correct structure, .powershell\5 exists, but not .powershell\7
            WriteRed "Reached 2"
            $this.profile5 = [Profile5]::new($pathToDirWithInstallFiles)
        }
        elseif ($fileCountInDir -eq 0 -and $folder7Exists -and -not($folder5Exists)) {  #.powershell has correct structure, .powershell\7 exists, but not .powershell\5
            WriteRed "Reached 3"
            $this.profile7 = [Profile7]::new($pathToDirWithInstallFiles)
        }
        elseif ($fileCountInDir -eq 0 -and $folder5Exists -and -$folder7Exists) {  #.powershell has correct structure, both .powershell\5 and .powershell\7 exist
            WriteRed "Reached 4"
            $pathTo5Folder = "$pathToDirWithInstallFiles\5"
            $pathTo7Folder = "$pathToDirWithInstallFiles\7"
            $this.profile5 = [Profile5]::new($pathTo5Folder)
            $this.profile7 = [Profile7]::new($pathTo7Folder)
        }
        else {
            WriteErrorExit("PowershellConfigurer: Unreachable code path reached. Please place a .powershell folder in the directory with your .main.ps1 file before trying to use PowershellConfigurer again.")
        }
    }

    static [bool] CheckIfPowershell7Exe($pathToExe) {
        Write-Host "CheckIfPowershell7Exe entered with pathtoexe: $pathtoexe" -ForegroundColor Yellow
        $fileName = [System.IO.Path]::GetFileName($pathToExe)
    
        if((Test-Path $pathToExe) -and ($fileName -ieq "pwsh.exe")) {
            Write-Host "Entered CheckIfPowershell7Exists() if clause" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Entered CheckIfPowershell7Exists() else clause" -ForegroundColor Red
            return $false
        }
    }
    [bool] IsPowershell7InstalledInStandardLocation() {  return [PowershellConfigurer]::CheckIfPowershell7Exe("$([Profile7]::allUsersDir)\pwsh.exe")  }
    [bool] IsPowershell7ExePath($path) {  return [PowershellConfigurer]::CheckIfPowershell7Exe($path)  }

    [PowershellConfigurer] Install() {
        WriteGreen "In PowershellConfigurer.Install()"
        if ($this.profile5 -eq $null -and $this.profile7 -eq $null) {  WriteErrorExit("PowershellConfigurer: Fatal error In Install function. No install files found.")  }

        if ($this.profile5 -ne $null) {
            $this.profile5.SetupCurrentUser()  }
        if ($this.profile7 -ne $null) {
            $this.profile7.SetupCurrentUser()  }
        return $this
    }

    [PowershellConfigurer] Install_ForAllUsers() {      # Use $alternateInstallFolder if your CurrentUser and AllUsers Profile are different
        WriteGreen "In PowershellConfigurer.Install_ForAllUsers()"
        if ($this.profile5 -eq $null -and $this.profile7 -eq $null) {  WriteErrorExit("PowershellConfigurer: Fatal error In Install_ForAllUsers function. No install files found.")  }

        if ($this.profile5 -ne $null) {
            $this.profile5.SetupAllUsers([Profile5]::allUsersDir)
        }

        if ($this.profile7 -ne $null) {
            if(-not($this.IsPowershell7InstalledInStandardLocation())) {
                WriteRed("PowershellConfigurer: Powershell 7.4+ Not Installed to Default Directory. Default Path to pwsh.exe: $([Profile7]::allUsersDir)\pwsh.exe")
                [string] $pathToExe = ""
                do {
                    $pathToExe = Read-Host "Please enter location of your Powershell 7 exe (or 'exit'): "
                    if ($pathToExe -eq "exit") { exit }
                } while (-not ($this.IsPowershell7ExePath($pathToExe)) )
    
                $this.profile7.SetupAllUsers($([System.IO.Path]::GetDirectoryName($pathToExe)))
                return $this
            }
            $this.profile7.SetupAllUsers([Profile7]::allUsersDir)
        }
        
        return $this
    }
}

