## String

`[string[]]$pathsChanged = @()`

- Loop/Contains
```powershell
if (-not ($pathsChanged -contains $whichBaseDir)) {
	#Dynamically add new string
	$pathsChanged += $whichBaseDir
}
```