Add-Type -AssemblyName System.Web

# Target folder name `
$gameFolder = "Wuthering Waves"

# Default install location
$defaultPath = "C:\Program Files\$gameFolder"

# Check default path first
if (Test-Path $defaultPath) {
    $gamePath = $defaultPath
} else {
    Write-Output "Default path not found. Searching other drives..."

    # Get all drives
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 }

    # Search for the folder
    foreach ($drive in $drives) {
        try {
            $foundPath = Get-ChildItem -Path "$($drive.Root)" -Recurse -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -eq $gameFolder } |
                Select-Object -First 1

            if ($foundPath) {
                $gamePath = $($foundPath.FullName)
                break
            }
        } catch {
            Write-Warning "Skipping $($drive.Root): $_"
        }
    }

    if (-not $foundPath) {
        Write-Output "Wuthering Waves not found on any drive."
    }
}

$logFileLocation = "$gamePath\Wuthering Waves Game\Client\Saved\Logs\Client.log"
$tmpfile = "$env:TEMP/ch_data_2"
Copy-Item $logFileLocation -Destination $tmpfile

# Regular expression pattern to match URLs starting with the specified prefix
$urlPattern = "https://aki-gm-resources-oversea.aki-game.net/aki/gacha/index.html#/record?svr_id=\S+"

# Search for the URL pattern in the log file
$urlMatch = Select-String -Path $tmpfile -Pattern $urlPattern -List

# Check if a match was found
if ($urlMatch) {
    # Extract the URL from the match
    $matchedLine = $urlMatch.Matches.Value
    $url = ($matchedLine -split '","')[0]
    # Output the URL
} else {
    Write-Output "No URL matching the specified pattern found in the log file."
    Write-Host "Please open the Convene history in Wuthering Waves and try again!" -ForegroundColor Red
    exit
}

Remove-Item $tmpfile

$wishHistoryUrl = $url

Set-Clipboard -Value $wishHistoryUrl
Write-Host "Link copied to clipboard, paste it in NousIndex" -ForegroundColor Green
