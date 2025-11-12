^q::ListHotkeys
^!x::ExitApp
^+XButton2::Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat /all
XButton1:: Send, #^{Left}

^1::
^2::
^3::
^4::
^5::
^6::
^7::
^8::
^9::
^0::
    StringRight, desktonNum, A_ThisHotkey, 1


; Run the KillVD.bat script and pass the number as a parameter
Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat %desktopNum%
return


	Send #^{Left}  ; Sends Ctrl+Win+Left to navigate to the previous virtual desktop

; Run VD.exe to get the current desktop and save output to currentDesktop.txt
RunWait, %ComSpec% /c "C:\Users\thero\OneDrive\Documents\VirtualDesktop\vd.exe -GetCurrentDesktop > C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt",, Hide

; Check if the file exists
if !FileExist("C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt") {
	MsgBox, Error: currentDesktop.txt not found.
	return
}

; Read the desktop info from the text file
FileRead, desktopInfo, C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt

; Extract the desktop number using a regular expression
RegExMatch(desktopInfo, "'Desktop (\d+)'", desktopNum)

; Display the desktop number to verify
MsgBox, Extracted desktop number: %desktopNum1%

; Check if the desktop number was successfully extracted
if (desktopNum1 = "") {
	MsgBox, Error: Could not retrieve the current desktop number.
	return
}

; Run the batch file with the extracted desktop number as a parameter
Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat %desktopNum1%
return


Send #^{Left}  ; Sends Ctrl+Win+Left to navigate to the previous virtual desktop

; Run VD.exe to get the current desktop and save output to currentDesktop.txt
RunWait, %ComSpec% /c "C:\Users\thero\OneDrive\Documents\VirtualDesktop\vd.exe -GetCurrentDesktop > C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt",, Hide

; Check if the file exists
if !FileExist("C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt") {
	MsgBox, Error: currentDesktop.txt not found.
	return
}

; Read the desktop info from the text file
FileRead, desktopInfo, C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt

; Extract the desktop number using a regular expression
RegExMatch(desktopInfo, "'Desktop (\d+)'", desktopNum)

; Display the desktop number to verify
MsgBox, Extracted desktop number: %desktopNum1%

; Check if the desktop number was successfully extracted
if (desktopNum1 = "") {
	MsgBox, Error: Could not retrieve the current desktop number.
	return
}

; Run the batch file with the extracted desktop number as a parameter
Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat %desktopNum1%
return

XButton2::
Ctrl & XButton1::
Send #^{Left}  ; Sends Ctrl+Win+Left to navigate to the previous virtual desktop

; Run VD.exe to get the current desktop and save output to currentDesktop.txt
RunWait, %ComSpec% /c "C:\Users\thero\OneDrive\Documents\VirtualDesktop\vd.exe -GetCurrentDesktop > C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt",, Hide

; Check if the file exists
if !FileExist("C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt") {
	MsgBox, Error: currentDesktop.txt not found.
	return
}

; Read the desktop info from the text file
FileRead, desktopInfo, C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt

; Extract the desktop number using a regular expression
RegExMatch(desktopInfo, "'Desktop (\d+)'", desktopNum)

; Display the desktop number to verify
MsgBox, Extracted desktop number: %desktopNum1%

; Check if the desktop number was successfully extracted
if (desktopNum1 = "") {
	MsgBox, Error: Could not retrieve the current desktop number.
	return
}

; Run the batch file with the extracted desktop number as a parameter
Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat %desktopNum1%
return
