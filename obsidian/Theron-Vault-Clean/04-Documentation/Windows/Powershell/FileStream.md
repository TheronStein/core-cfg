```powershell
try {

	$stream = [System.IO.File]::Open($logFile, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)

	$writer = New-Object System.IO.StreamWriter($stream)

	$writer.WriteLine($message)

	$writer.Flush()

	$writer.Close()

	$stream.Close()

}

catch {

	Write-Host "Failed to write to log:" -ForegroundColor DarkCyan

	Write-Host "$($_.Exception.Message)" -ForegroundColor

}
```
