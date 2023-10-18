Add-Type -AssemblyName System.Web

$logLocation = "%userprofile%\AppData\LocalLow\Cognosphere\Star Rail\output_log.txt";
$logLocationChina = "%userprofile%\AppData\LocalLow\miHoYo\$([char]0x5d29)$([char]0x574f)$([char]0xff1a)$([char]0x661f)$([char]0x7a79)$([char]0x94c1)$([char]0x9053)\output_log.txt";

$reg = $args[0]
$apiHost = "api-os-takumi.mihoyo.com" 
if ($reg -eq "china") {
  Write-Host "Using China cache location"
  $logLocation = $logLocationChina
  $apiHost = "hk4e-api.mihoyo.com"
}

$tmps = $env:TEMP + '\pm.ps1';
if ([System.IO.File]::Exists($tmps)) {
  ri $tmps
}

$path = [System.Environment]::ExpandEnvironmentVariables($logLocation);
if (-Not [System.IO.File]::Exists($path)) {
  Write-Host "Cannot find the log file! Make sure to open the wish history first!" -ForegroundColor Red

  if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
    Write-Host "Do you want to try to run the script as Administrator? Press [ENTER] to continue, or any key to cancel."
    $keyInput = [Console]::ReadKey($true).Key
    if ($keyInput -ne "13") {
      return
    }

    $myinvocation.mycommand.definition > $tmps

    Start-Process powershell -Verb runAs -ArgumentList "-noexit", $tmps, $reg
    break
  }

  return
}

$logs = Get-Content -Path $path
$m = $logs -match "(?m).:/.+(StarRail_Data)"
$m[0] -match "(.:/.+(StarRail_Data))" >$null

if ($matches.Length -eq 0) {
  Write-Host "Cannot find the wish history url! Make sure to open the wish history first!" -ForegroundColor Red
  return
}

$gamedir = $matches[1]
$desiredPath = $gamedir -replace "\\[^\\]+$"
$desiredPath2 = [System.IO.Path]::GetDirectoryName($desiredPath)
$webCachefolder = "$desiredPath2\"
$tmpfile = "$env:TEMP/ch_data_2"

# Get a list of folders in the specified directory
$folders = Get-ChildItem -Path $webCachefolder -Directory

# Sort the folders by LastWriteTime in descending order and select the first one
$mostRecentFolder = $folders | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Check if there is at least one folder in the directory
if ($mostRecentFolder) {
  $cachefile = "$webCachefolder$mostRecentFolder/Cache/Cache_Data/data_2"
}
else {
  Write-Host "No folders found in the specified directory." -ForegroundColor Red
  return
}
Copy-Item $cachefile -Destination $tmpfile

$content = Get-Content -Encoding UTF8 -Raw $tmpfile
$found = $content -split "1/0/"
$link = $false
$linkFound = $false
for ($i = $found.Length - 1; $i -ge 0; $i -= 1) {
  $t = $found[$i] -match "(https.+?&game_biz=)"
  $link = $matches[0]
  $linkFound = $true
  break
  Sleep 0.5
}

Remove-Item $tmpfile

Write-Host ""

if (-Not $linkFound) {
  Write-Host "Cannot find the warp history url! Make sure to open the warp history first!" -ForegroundColor Red
  return
}

$wishHistoryUrl = $link

#Write-Host $wishHistoryUrl
Set-Clipboard -Value $wishHistoryUrl
Write-Host "Link copied to clipboard, paste it in NousIndex" -ForegroundColor Green
