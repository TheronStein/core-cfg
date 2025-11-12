param (
    [string]$cmd  # No default; the user must provide a valid command
)

function Kill-VD {
    param (
        [string]$command
    )
    
    # Check if the command is either '/all', '/[number]' or '[number]'
    if ($command -notmatch '^/all$' -and $command -notmatch '^/\d+$' -and $command -notmatch '^\d+$' -and $command -notmatch '^-\d+$') {
        Write-Host "Invalid command. Please specify '/all' or an index (e.g., '/1' or '1')."
        return  # Exit the function if the command is invalid
    }

    switch -Regex ($command) {
        '^/all$' {
            Write-Host "Killing all virtual desktops..."
            & "VD" /cwod:1
            Start-Sleep -Seconds 10
            $desktops = & "VD.exe" Get-DesktopList
            foreach ($desktop in $desktops) {    
                if (!$desktop.IsActive) {
                    Write-Host "Closing desktop with ID:" $desktop.Id
                    & "VD" /r:$desktop.Id
                }
            }
        }
        '^/\d+$' {
            # Handles inputs like /2, /30 etc.
            $id = $command.TrimStart('/')
            Write-Host "Killing virtual desktop with ID: $id..."
            & "VD" /r:$id
        }
        '^\d+$' {
            # Handles inputs like 2, 30 etc.
            $id = $command
            Write-Host "Killing virtual desktop with ID: $id..."
            & "VD" /r:$id
        }
        '^-\d+$' {
            # Handles inputs like -2, -30 etc. If '-' is meant to denote something specific, handle accordingly.
            $id = $command.TrimStart('-')
            Write-Host "Killing virtual desktop with ID: $id..."
            & "VD" /r:$id
        }
    }
}

# Ensure a command is provided
if (-not $cmd) {
    Write-Host "Error: No command provided. Please specify '/all' or an index (e.g., '/1' or '1')."
    exit 1
}

# Execute the function with the command-line argument
Kill-VD -command $cmd