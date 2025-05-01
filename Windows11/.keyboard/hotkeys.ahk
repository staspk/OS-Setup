#Requires AutoHotkey v2.0

#1::Run("C:\Program Files\PowerShell\7\pwsh.exe")    		; WinKey+1     => Opens PowerShell
#Esc::WinClose("A")                                    		; WinKey+Esc   => Close Currently Open Program

;LWin::Return                                           	; WinKey       => [DISABLE] Commented Out. It disables all chords too.
!Esc::Return												; Alt+Esc 	   => [DISABLE]