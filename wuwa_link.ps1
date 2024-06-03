Add-Type -AssemblyName System.Web

$logLocation = "%userprofile%\AppData\Roaming\KRLauncher\G153\C50004\kr_starter_game.json";
$path = [System.Environment]::ExpandEnvironmentVariables($logLocation);
# Read the content of the JSON file
$jsonContent = Get-Content $path | ConvertFrom-Json

# Get the path from the JSON content
$gamePath = $jsonContent.path

$logFileLocation = "$gamePath\Client\Saved\Logs\Client.log"
$tmpfile = "$env:TEMP/ch_data_2"
Copy-Item $logFileLocation -Destination $tmpfile

# Regular expression pattern to match URLs starting with the specified prefix
$urlPattern = "https://aki-gm-resources-oversea\.aki-game\.net/aki/gacha/index\.html#/record\?svr_id=\S+"

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
}

Remove-Item $tmpfile

$wishHistoryUrl = $url

Set-Clipboard -Value $wishHistoryUrl
Write-Host "Link copied to clipboard, paste it in NousIndex" -ForegroundColor Green
