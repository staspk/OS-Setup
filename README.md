## Ubuntu Instructions
### .bashrc
- `git clone https://github.com/staspk/OS-Setup.git $HOME/OS-Setup`
- `cp -r $HOME/os-setup/ubuntu/home/. ~`
- `(cat "$HOME/os-setup/ubuntu/.bashrc"; printf "\n\n\n"; cat ~/.bashrc) > "$HOME/.bashrc.new" && mv "$HOME/.bashrc.new" ~/.bashrc`
- Restart terminal. Finally: `setup_ubuntu`


## Windows 11 Instructions
### Uncomment desired functionality in: .\main.ps1.
- Beware: pwsh function calls including parentheses only work with exactly 1 param. 
- Uncomment desired functionality in main.psm1.
- Change List of bloat/software to uninstall/install at top of file: `.\modules\Winget.psm1`

### Powershell & OneDrive Warning!
- PowershellConfigurer (Powershell.psm1) module deprecated as of 2025:Q2.
- Beware: the OneDrive default installation will likely do exactly what the [Microsoft Documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5) explicitly advises against, messing with where the "automatic variable" $profile ends up pointing to in the process. My module accomodated both states in the past.\
Do not bother.\
- If battling OneDrive again, uncomment "UninstallAndAttemptAnnihilationOfOneDrive", run './main.ps1'. Works 90% of the time, every time.
- Clone your [PowerShell Git](https://github.com/staspk/PowerShell.git) directly into: 'C:\Users\stasp\Documents'.  

### Final Notes
- Run Powershell as Admin. CD into Windows11 folder and run: './main.ps1'. Note: Powershell 5.1+ required, the standard default pre-installed version on modern Windows machines.
- Highly Recommended to Close All Extraneous Programs, especially FileExplorer and Terminals open at any paths.
- Small chance a Computer Restart is needed to finalize changes.
