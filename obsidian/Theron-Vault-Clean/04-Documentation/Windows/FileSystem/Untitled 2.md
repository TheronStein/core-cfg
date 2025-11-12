XButton1
Ctrl & XButton2::Send #^{Left}
Ctrl & XButton2::Send #^{Left}
~LControl & WheelUp::  ; Scroll left.
{

}

~LControl & WheelDown::  ; Scroll right.
{
    Loop 2  ; <-- Increase this value to scroll faster.
        SendMessage 0x0114, 1, 0, ControlGetFocus("A")  ; 0x0114 is WM_HSCROLL and the 1 after it is SB_LINERIGHT.
}