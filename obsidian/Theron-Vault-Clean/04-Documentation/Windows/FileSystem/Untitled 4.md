#SingleInstance Force
SetBatchLines, -1
;*******************************************
Gui1 := {}
Gui1.Scale := 1
;*******************************************

Gui1.Hwnd := hwnd
;*******************************************
Gui1.MarginX := 10
Gui1.MarginY := 10
Gui, % Gui1.Hwnd ":Margin", % Gui1.MarginX , % Gui1.MarginY
;*******************************************
Gui1.FontType 		:= "Segoe UI"
Gui1.FontSize 		:= 9
Gui1.FontColor 		:= "000000"
Gui1.FontOptions 	:= ""
SetWindowFont( Gui1 )
;;*******************************************
Gui1.Controls := {}
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Control Name									 	Parent Object	, Control Type		, Options						, Display Value														, Rows		
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Gui1.Controls.ColorListBox		:= CreateControl( 	Gui1 			, "ListBox" 		, "xm ym w250 h200 Multi" 		, "hwnd|posX||posY|posW|posH|Type|WinObj|DisplayValue|Options|" )
Gui1.Controls.CheckMeCheckBox	:= CreateControl( 	Gui1 			, "Checkbox" 		, "x+m yp Checked section " 	, "Check Me!" )
Gui1.Controls.HideButton		:= CreateControl( 	Gui1 			, "Button" 			, "xs y+m wp" 					, "Hide" )
Gui1.Controls.ShowButton		:= CreateControl( 	Gui1 			, "Button" 			, "xs y+m wp" 					, "Show" )
Gui1.Controls.Option1Radio		:= CreateControl( 	Gui1 			, "Radio" 			, "xs y+m wp Checked" 			, "Option 1" )
Gui1.Controls.Option2Radio		:= CreateControl( 	Gui1 			, "Radio" 			, "xs y+m wp" 					, "Option 2" )
Gui1.Controls.TTestDDL			:= CreateControl( 	Gui1 			, "DDL" 			, "xs y+m w200 r10" 			, "Item||Item|Item|Item|Item|Item|Item|Item|Item|Item|Item|"		, 10 )

Gui, Show, AutoSize , Scale via +Resize
;;*******************************************
WinGetPos,,, w , h , % "ahk_id " Gui1.Hwnd 
Gui1.W := w
Gui1.H := h
;;*******************************************
Gui1.Scale := A_ScreenDPI / 96
ScaleControls( Gui1 , Gui1.Scale )
;;*******************************************
return	;<<<<---- End of the auto-exectute section of the script.
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	Exit Routine
GuiClose:
GuiContextMenu:
*ESC::ExitApp
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 	+RESIZE
GuiSize:	;{
	if( !init && init := 1 )
		return
	WinGetPos,,, w, h , % "ahk_id " Gui1.Hwnd
	Gui1.Scale := w / Gui1.W
	ScaleControls( Gui1 , Gui1.Scale )
	sleep, 30
	return
;}
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	HOTKEYS	
F1:: ScaleControls( Gui1 , Gui1.Scale := 1 )
;;*******************************************
F2:: ScaleControls( Gui1 , Gui1.Scale := 1.5 )
;;*******************************************
F3:: ScaleControls( Gui1 , Gui1.Scale := 2 )
;;*******************************************
F4:: ScaleControls( Gui1 , Gui1.Scale := .7 )
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Functions
ScaleControls( Gui1 , Scale := 1 ){
	static lastSize 
	for k , v in Gui1.Controls	{
		cc := Gui1.Controls[ k ]
		x := cc.X * Scale
		y := cc.Y * Scale
		w := cc.W * Scale
		if( cc.Rows )
			h := cc.Rows * GetRowHeight( cc.FontType , size , cc.FontOptions )
		else
			h := cc.H * Scale
		size := ( cc.FontSize / ( A_ScreenDPI / 96 ) ) * scale
		if( size != lastSize && lastSize := Size )
			Gui, % Gui1.Hwnd ":Font" , % "norm s" size " c" cc.FontColor " " cc.FontOptions , % cc.FontType
		GuiControl, % Gui1.Hwnd ":Font" , % cc.Hwnd
		GuiControl, % Gui1.Hwnd ":MoveDraw" , % cc.Hwnd , % "x" X " y" Y " w" W " h" H 
	}
	Gui, % Gui1.hwnd ":Margin", % Gui1.MarginX * scale , % Gui1.MarginY * scale
	Gui, % Gui1.Hwnd ":Show" , AutoSize 
}
;;*******************************************
GetRowHeight( FontType , FontSize , FontOptions ){
	Gui, Dummy:Font, % "s" FontSize " " FontOptions , % FontType
	Gui, Dummy:Add, Text,, % "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyyYzZ1!2@3#4$5%6^7&8*9(0)-_=+[{]}\|,<.>/?"
	GuiControlGet, pos , Dummy:pos , static1
	Gui, Dummy:Destroy
	return posH
}

