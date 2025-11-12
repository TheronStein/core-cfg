## Launch - Powershell

```powershell
wsl -d <distribution-name>
```

## Running
```
C:\Users\thero>wsl --list --running
Windows Subsystem for Linux Distributions:
Fedora (Default)
docker-desktop`

```
## List
```cmd
`wsl --list --verbose

NAME              STATE           VERSION
* Fedora            Running         2
  docker-desktop    Running         2
```

## Check Distro

`wsl uname -r`

## Config

`wsl ifconfig`
