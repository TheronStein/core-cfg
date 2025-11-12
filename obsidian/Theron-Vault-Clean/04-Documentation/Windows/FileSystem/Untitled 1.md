Menu, FileMenu, Add, E&xit, MenuHandler

large-236
Gui, Menu, MyMenuBar
Gui, Add, Button, gExit, Exit This Example	

Gui, Add, Text,, Virtual Desktop Controls
Gui, Add, Button, gKillThis xp+20 yp+250, Current VD
Gui, Add, Button, gKillAll xp+20 yp+250, All VDs

Gui, Add, Text,, Script Controls
Gui, Add, Button, gMinScript xp+20 yp+250, Minimize
Gui, Add, Button, gTermScript xp+20 yp+250, Terminate
Gui, Show
return

KillThis:
FetchAndKillVD()
return
KillAll:
Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat /all
return
MinScript:
Hide
return
TermScript:
ExitApp
return

#SingleInstance Force
SetBatchLines, -1

Loop,

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
;*******************************************
Gui1.Controls := {}
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "")
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "Current VD")
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "")
Gui1.Controls.ShowButton := CreateControl(Gui1, "Button", "xs y+m wp", "")
;*******************************************

SetWindowFont(Gui1) {
    local size := Gui1.FontSize / (A_ScreenDPI / 96)
    Gui, % Gui1.Hwnd ":Font", % "norm s" size " c" Gui1.FontColor " " Gui1.FontOptions, % Gui1.FontType
}

;*******************************************
Gui, Show, VDC, Virtual Desktop Control
;*******************************************
WinGetPos,,, w, h, % "ahk_id " Gui1.Hwnd
Gui1.W := w
Gui1.H := h
Gui1.Scale := A_ScreenDPI / 96
;*******************************************


; Handle resizing the GUI
GuiSize:
    if (!init && init := 1)
        return
    WinGetPos,,, w, h, % "ahk_id " Gui1.Hwnd
    Gui1.Scale := w / Gui1.W
    sleep, 30
return

; Function to create a control dynamically
CreateControl(WinObj, Type := "Button", Options := "", DisplayValue := "", Rows := "") {
    local obj := {}
    Gui, % WinObj.Hwnd ":Add", % Type, % Options " +hwndhwnd", % DisplayValue
    GuiControlGet, pos, % WinObj.Hwnd ":pos", % hwnd
    obj.Hwnd := hwnd
    obj.Rows := Rows
    obj.Type := Type
    obj.DisplayValue := DisplayValue
    return obj
}

^q::
    Gui, Show, VDC, Virtual Desktop Control
return

; Virtual Desktop Hotkeys
XButton1:: Send, #^{Left}
XButton2:: Send, #^{Right}

^!XButton1::Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat /all
^!XButton2::ExitApp
Ctrl & XButton1:: FetchAndKillVD()
Ctrl & XButton2:: FetchAndKillVD()

FetchAndKillVD() {
    RunWait, %ComSpec% /c "C:\Users\thero\OneDrive\Documents\VirtualDesktop\vd.exe -GetCurrentDesktop > C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt",, Hide
    if !FileExist("C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt") {
        MsgBox, Error: currentDesktop.txt not found.
        return
    }
    FileRead, desktopInfo, C:\Users\thero\OneDrive\Documents\VirtualDesktop\currentDesktop.txt
    RegExMatch(desktopInfo, "'Desktop (\d+)'", desktopNum)
    
    if (desktopNum1 = "") {
        MsgBox, Error: Could not retrieve the current desktop number.
        return
    }
    
    MsgBox, Extracted desktop number: %desktopNum1%

    ; Run the KillVD script with the desktop number
    Run, C:\Users\thero\OneDrive\Documents\VirtualDesktop\KillVD.bat %desktopNum%
    return
}