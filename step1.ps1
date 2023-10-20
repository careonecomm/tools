$ProgressPreference = 'SilentlyContinue'
$apps = @(
  [pscustomobject]@{
    Url = "http://resources.idatio.co/apps/OfficeSetup.exe"
    Install = ""
  },
    [pscustomobject]@{
    Url = "http://resources.idatio.co/apps/netdocs.exe"
    Install = ""
  },
    [pscustomobject]@{
    Url = "http://resources.idatio.co/apps/foxit.msi"
    Install = ""
  },
    [pscustomobject]@{
    Url = "http://resources.idatio.co/apps/openvpn.msi"
    Install = ""
  },
    [pscustomobject]@{
    Url = "http://resources.idatio.co/apps/communicator.exe"
    Install = ""
  },
  [pscustomobject]@{
    Url = "http://resources.idatio.co/apps/teams.msix"
    Install = ""
  }
  
)

$currentDirectory = (Get-Item -Path '.').FullName

foreach ($app in $apps) {
  $fileName = [System.IO.Path]::GetFileName($app.Url)
  $filePath = "$currentDirectory\$fileName"
  if (!(Test-Path $filePath)) {
    Write-Host "Downloading $($app.Url)"
    Invoke-WebRequest -Uri $app.Url -OutFile $filePath
  } else {
    Write-Host "Skipping download, file already exists: $filePath"
  }
}

#Prompt the user if the software should be installed
$install = Read-Host "Do you want to install the software? (y/n)"

#If Install is equal to y continue with the installation
if ($install -eq "y") {
  Write-Host "Installing software"
  foreach ($app in $apps) {
    $fileName = [System.IO.Path]::GetFileName($app.Url)
    $filePath = "$currentDirectory\$fileName"
    Write-Host "Installing $filePath"
    Start-Process $filePath -Wait
  }
} else {
  Write-Host "Exiting"
  exit
}
