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
    Url = "http://resources.idatio.co/apps/teams.exe"
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

foreach ($app in $apps) {
  $fileName = [System.IO.Path]::GetFileName($app.Url)
  $filePath = "$currentDirectory\$fileName"
  Write-Host "Installing $filePath"
  Start-Process $filePath -Wait
}