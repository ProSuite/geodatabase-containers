function Invoke-SafeCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    try {
        # Display the command being executed
        Write-Host "Attempting to run: $Command"

        # Split the command into parts (executable and arguments)
        $parts = $Command -split ' '
        $executable = $parts[0]
        $arguments = $parts[1..($parts.Length - 1)]

        # Check if the command is a cmdlet or an executable
        if (Get-Command $executable -ErrorAction SilentlyContinue) {
            # It's a valid cmdlet or function, invoke it directly
            Invoke-Expression $Command
        } else {
            # It's likely an external executable
            if ($arguments.Count -eq 0) {
                & $executable
            } else {
                & $executable @arguments
            }
        }

        Write-Host "Command executed successfully."
    } catch {
        # Handle errors
        Write-Error "Failed to execute command: $Command" -ForegroundColor Red
        Write-Error $_.Exception.Message
        exit
    }
}

