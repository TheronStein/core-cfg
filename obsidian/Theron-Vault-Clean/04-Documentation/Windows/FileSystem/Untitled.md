VDA_PATH := A_ScriptDir . "\target\debug\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")


^q::
    Gui, Show, VDC, Virtual Desktop Control
return

MsgBox, 0, Execute CommandsMsgBox, 4, , 4-parameter mode: this MsgBox will time out in 5 seconds.  Continue?, 5
IfMsgBox Timeout

XButton1:: Send, #^{Left}
XButton2:: Send, #^{Right}
^!XButton1::Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat /all
^!XButton2::ExitApp

Ctrl & XButton1::
    Send #^{Left}  ; Sends Ctrl+Win+Left to navigate to the previous virtual desktop

    ; Run VD.exe to get the current desktop and save output to currentDesktop.txt
    Run, vd /list,, Hide > C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt",, Hide

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

Ctrl & XButton2::
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

#SingleInstance Force
SetBatchLines, -1
;*******************************************
Gui1 := {}
Gui1.Scale := 1
;*******************************************
Gui, New, +AlwaysOnTop +hwndhwnd -DPIScale +Resize
Gui1.Hwnd := hwnd
;*******************************************
Gui1.MarginX := 10
Gui1.MarginY := 10
Gui, % Gui1.Hwnd ":Margin", % Gui1.MarginX , % Gui1.MarginY
Gui1.FontType 		:= "Segoe UI"
Gui1.FontSize 		:= 9
Gui1.FontColor 		:= "000000"
Gui1.FontOptions 	:= ""
SetWindowFont(Gui1)
;;*******************************************
Gui1.Controls := {}
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Control Name									 	Parent Object	, Control Type		, Options						, Display Value														, Rows		
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "All VD")
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "Current VD")
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "Terminate Script")
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "Exit Menu")
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SetWindowFont(Gui1) {
	local size := Gui1.FontSize / (A_ScreenDPI / 96)
	Gui, % Gui1.Hwnd ":Font", % "norm s" size " c" Gui1.FontColor " " Gui1.FontOptions, % Gui1.FontType
}
;;*******************************************
Gui, Show, VDC, Virtual Desktop Control
;;*******************************************
WinGetPos,,, w , h , % "ahk_id " Gui1.Hwnd 
Gui1.W := w
Gui1.H := h
;;*******************************************
Gui1.Scale := A_ScreenDPI / 96
ScaleControls(Gui1, Gui1.Scale)
;;*******************************************

^q::
    Gui, Show, VDC, Virtual Desktop Control
return

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	Exit Routine
GuiClose:
GuiContextMenu:
*ESC::ExitApp
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 	+RESIZE
GuiSize:	;{
	if (!init && init := 1)
		return
	WinGetPos,,, w, h, % "ahk_id " Gui1.Hwnd
	Gui1.Scale := w / Gui1.W
	ScaleControls(Gui1, Gui1.Scale)
	sleep, 30
	return
;}
;;*******************************************
CreateControl(WinObj, Type := "Button", Options := "", DisplayValue := "", Rows := "") {
	local obj := {}
	Gui, % WinObj.Hwnd ":Add", % Type, % Options " +hwndhwnd", % DisplayValue
	GuiControlGet, pos, % WinObj.Hwnd ":pos", % hwnd
	obj.Hwnd 			:= hwnd
	obj.Rows			:= Rows
	obj.X 				:= posX
	obj.Y 				:= posY
	obj.W 				:= posW
	obj.H 				:= posH
	obj.Type 			:= Type
	obj.Parent 			:= WinObj.Hwnd
	obj.DisplayValue 	:= DisplayValue
	obj.Options 		:= Options
	obj.FontType		:= WinObj.FontType
	obj.FontSize		:= WinObj.FontSize
	obj.FontColor		:= WinObj.FontColor
	obj.FontOptions		:= WinObj.FontOptions
	return obj
}
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






﻿; AutoHotkey v1 script

; Get hwnd of AutoHotkey window, for listener

; Path to the DLL, relative to the script
VDA_PATH := A_ScriptDir . "\target\debug\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName", "Ptr")
SetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName", "Ptr")
CreateDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "CreateDesktop", "Ptr")
RemoveDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RemoveDesktop", "Ptr")

; On change listeners
RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")


GetDesktopCount() {
    global GetDesktopCountProc
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

GetDesktopName(num) {
    global GetDesktopNameProc
    utf8_buffer := ""
    utf8_buffer_len := VarSetCapacity(utf8_buffer, 1024, 0)
    ran := DllCall(GetDesktopNameProc, "Int", num, "Ptr", &utf8_buffer, "Ptr", utf8_buffer_len, "Int")
    name := StrGet(&utf8_buffer, 1024, "UTF-8")
    return name
}
SetDesktopName(num, name) {
    ; NOTICE! For UTF-8 to work AHK file must be saved with UTF-8 with BOM

    global SetDesktopNameProc
    VarSetCapacity(name_utf8, 1024, 0)
    StrPut(name, &name_utf8, "UTF-8")
    ran := DllCall(SetDesktopNameProc, "Int", num, "Ptr", &name_utf8, "Int")
    return ran
}


CreateDesktop() {
    global CreateDesktopProc
    ran := DllCall(CreateDesktopProc)
    return ran
}
RemoveDesktop(remove_desktop_number, fallback_desktop_number) {
    global RemoveDesktopProc
    ran := DllCall(RemoveDesktopProc, "Int", remove_desktop_number, "Int", fallback_desktop_number, "Int")
    return ran
}


GetDesktopCountProc

; Listen to desktop changes
DllCall(RegisterPostMessageHookProc, "Ptr", A_ScriptHwnd, "Int", 0x1400 + 30, "Int")
OnMessage(0x1400 + 30, "OnChangeDesktop")
OnChangeDesktop(wParam, lParam, msg, hwnd) {
    Critical, 100
    OldDesktop := wParam + 1
    NewDesktop := lParam + 1
    Name := GetDesktopName(NewDesktop - 1)

    ; Use Dbgview.exe to checkout the output debug logs
    OutputDebug % "Desktop changed to " Name " from " OldDesktop " to " NewDesktop
}
