# Check if the script is running with elevated privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If not elevated, restart script with elevated privileges
if (!$isAdmin) {
    Start-Process -FilePath PowerShell.exe -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# Get all the OUs in the domain
$ous = Get-ADOrganizationalUnit -Filter * | Sort-Object Name

# Display a numbered list of OUs to choose from
Write-Host "Select an OU to create the user in:`n"
for ($i = 0; $i -lt $ous.Count; $i++) {
    $ou = $ous[$i]
    $path = $ou.DistinguishedName
    $name = $ou.Name
    Write-Host "$($i+1). $name"
}
$defaultOU = $ous | Where-Object { $_.Name -eq "USA" }
$defaultOUIndex = $ous.IndexOf($defaultOU)
Write-Host "`nDefault: $($defaultOU.Name)"

# Prompt the user to select an OU
$selectedOU = Read-Host "Enter the number of the OU to create the user in or press Enter to use the default"
if ([string]::IsNullOrEmpty($selectedOU)) {
    $selectedOU = $defaultOUIndex + 1
}
else {
    $selectedOU = [int]$selectedOU
}

# Get the full path of the selected OU
$ouPath = $ous[$selectedOU-1].DistinguishedName

# Prompt for the first and last name of the user
$firstName = Read-Host "Enter the first name of the user"
$lastName = Read-Host "Enter the last name of the user"

$lastName = $lastName -replace "[^a-zA-Z]", ""
$firstName = $firstName -replace "[^a-zA-Z]", ""

# Create the username using the first letter of the first name and the last name
$username = ($firstName.Substring(0,1) + $lastName).ToLower()

# Create the user
$password = "P@ssw0rd1"
try {
    New-ADUser -Name "$firstName $lastName" -SamAccountName $username -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Enabled $true -PasswordNeverExpires $true -CannotChangePassword $true -Path $ouPath
    Write-Host "User '$username' created successfully in '$ouPath'"
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
    Write-Host "Error: The user '$username' already exists."
}
catch {
    Write-Host "An error occurred while creating the user."
    Write-Host $_.Exception.Message
}

# Prompt user to create another user or exit
$continue = Read-Host "Press 'Y' to create another user or any other key to exit"
if ($continue -eq "Y") {
    & "$PSScriptRoot\adduser.ps1"
}
else {
    exit 0
}