```
Actions:
-m                   Show information about the window manager and
about the environment.
-l                   List windows managed by the window manager.
-d                   List desktops. The current desktop is marked
with an asterisk.
-s <DESK>            Switch to the specified desktop.
-a <WIN>             Activate the window by switching to its desktop and
raising it.
-c <WIN>             Close the window gracefully.
-R <WIN>             Move the window to the current desktop and
activate it.
-r <WIN> -t <DESK>   Move the window to the specified desktop.
-r <WIN> -e <MVARG>  Resize and move the window around the desktop.
The format of the <MVARG> argument is described below.
-r <WIN> -b <STARG>  Change the state of the window. Using this option it's
possible for example to make the window maximized,
minimized or fullscreen. The format of the <STARG>
argument and list of possible states is given below.
-r <WIN> -N <STR>    Set the name (long title) of the window.
-r <WIN> -I <STR>    Set the icon name (short title) of the window.
-r <WIN> -T <STR>    Set both the name and the icon name of the window.
-k (on|off)          Activate or deactivate window manager's
"showing the desktop" mode. Many window managers
do not implement this mode.
-o <X>,<Y>           Change the viewport for the current desktop.
The X and Y values are separated with a comma.
They define the top left corner of the viewport.
The window manager may ignore the request.
-n <NUM>             Change number of desktops.
The window manager may ignore the request.
-g <W>,<H>           Change geometry (common size) of all desktops.
The window manager may ignore the request.
-h                   Print help.

Options:
-i                   Interpret <WIN> as a numerical window ID.
-p                   Include PIDs in the window list. Very few
X applications support this feature.
-G                   Include geometry in the window list.
-x                   Include WM_CLASS in the window list or
interpret <WIN> as the WM_CLASS name.
-u                   Override auto-detection and force UTF-8 mode.
-F                   Modifies the behavior of the window title matching
algorithm. It will match only the full window title
instead of a substring, when this option is used.
Furthermore it makes the matching case sensitive.
-v                   Be verbose. Useful for debugging.
-w <WA>              Use a workaround. The option may appear multiple
times. List of available workarounds is given below.
```