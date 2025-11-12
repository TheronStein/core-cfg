```bash
@echo off
echo Killing all active applications
"C:\Program Files\VirtualDesktop11\VirtualDesktop11.exe" /cwod:1
timeout
echo Killing Virtual desktop
"C:\Program Files\VirtualDesktop11\VirtualDesktop11.exe" /r:1
echo finish
```