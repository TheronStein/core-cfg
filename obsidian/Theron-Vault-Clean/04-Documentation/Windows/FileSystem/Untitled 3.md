```ahk
;Alt-Tab Replacement by jeeswg

#SingleInstance force
ListLines, Off
Menu, Tray, Click, 1
#NoEnv
AutoTrim, Off
#UseHook

SplitPath, A_ScriptName,,,, vScriptNameNoExt
Menu, Tray, Tip, % vScriptNameNoExt

;==================================================

;options:
;the order in which items will appear
;specify zero to exclude an item
vListVisibleWindows := 1
vListIntExpTabs := 2
vListDesktop := 3
vListNewIntExp := 4

;==================================================

vListCount := 4
;hIcon := DllCall("user32\LoadIcon", Ptr,0, Ptr,32512, Ptr) ;IDI_APPLICATION := 32512
;get Desktop icon (tested on Windows 7)
hIconDT := LoadPicture("shell32.dll", "w16 h16 icon35", vType)
hIconDTBig := LoadPicture("shell32.dll", "w32 h32 icon35", vType)
;get Internet Explorer icon
hIconIE := LoadPicture("C:\Program Files\Internet Explorer\iexplore.exe", "w16 h16", vType)
hIconIEBig := LoadPicture("C:\Program Files\Internet Explorer\iexplore.exe", "w32 h32", vType)

;==================================================

Gui, New, +HwndhGui -Caption Border, Alt-Tab Replacement
Gui, Font, s16
Gui, Color, ABCDEF
Gui, Add, Picture, +HwndhStcImg x4 y4 w32 h32 +0x3 ;SS_ICON := 0x3
;Gui, Add, Picture, +HwndhStcImg x10 y10 w16 h16 +0x3 ;SS_ICON := 0x3
Gui, Add, Text, +HwndhStc x40 y6 w500
Gui, Add, ListView, -Hdr x-2 y40 w530 h280, Window Title
return

;==================================================

GuiClose:
ExitApp
return

;==================================================

C:\Users\thero\OneDrive\Dev\Software\Microsoft VS Code\bin

C:\Users\thero\AppData\Local\Programs\Microsoft VS Code\bin

Gui +Resize -MaximizeBox  ; Change the settings of the default GUI window.
Gui MyGui:+Resize -MaximizeBox  ; Change the settings of the GUI named MyGui.


Gui, Add, GroupBox, w200 h100, Virtual Desktops
Gui, Add, ListView, xm r20 w700, Index|Active Windows|Name (KB)|Type


Gui, Add, VDTab,, Current|Modify|Templates


Gui, Add, Text, cBlue gLaunchGoogle, Click here to launch Google.


Gui, Add, Edit



GuiControl, Hide, ControlID




iconsize := 32  ; Ideal size for alt-tab varies between systems and OS versions.
hIcon := LoadPicture("My Icon.ico", "Icon1 w" iconsize " h" iconsize, imgtype)
Gui +LastFound
SendMessage 0x0080, 1, hIcon  ; 0x0080 is WM_SETICON; and 1 means ICON_BIG (vs. 0 for ICON_SMALL).
Gui Show





Loop,   ; Change this folder and wildcard pattern to suit your preferences.
{
    GuiControl,, MyListBox, %A_LoopFileFullPath%
}
```