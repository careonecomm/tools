# Check if the script is running with elevated privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If not elevated, restart script with elevated privileges
if (!$isAdmin) {
    Start-Process -FilePath PowerShell.exe -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# Connect to Microsoft 365 online
Connect-MsolService
# Default password for AD users
$password = "P@ssw0rd1"

#Function to create username, ask first name and last name and create username
function createUsername {
    $firstName = Read-Host "Enter the first name of the user"
    $lastName = Read-Host "Enter the last name of the user"

    $lastName = $lastName -replace '\s', '' -replace '[^a-zA-Z0-9]', ''
    $firstName = $firstName -replace '\s', '' -replace '[^a-zA-Z0-9]', ''

    # Create the username using the first letter of the first name and the last name
    $username = ($firstName.Substring(0,1) + $lastName).ToLower()
    return $username, $firstName, $lastName
}


#Function to create the user in Active Directory and Office 365
function createUser {
    #Call the createUsername function
    $username, $firstName, $lastName = createUsername
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

    # Create the user

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
    
    # Prompt user to create the office 365 account
    $continue = Read-Host "Press 'Y' to create the office 365 account or any other key continue"
    if ($continue -eq "Y") {
    # Check for availability of ENTERPRISEPACK licenses
    $license = Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq "EXCHANGEENTERPRISE"}
    $licensesavailable = $license.ActiveUnits - $license.ConsumedUnits
    $domain = "kirkendalldwyer.com"

    if ($licensesavailable -gt 0) {
        # Create new user with ENTERPRISEPACK license and default password
        New-MsolUser -FirstName $firstName -LastName $lastName -DisplayName "$firstname $lastname" -UserPrincipalName "$userName@$domain" -UsageLocation "US" -LicenseAssignment $license.AccountSkuId
    
        Write-Host "User $userName created with ENTERPRISEPACK license and default password"
    } else {
        Write-Host "No ENTERPRISEPACK licenses available"
    }
}
}
# Prompt user to create another user or exit
$continue = Read-Host "Press 'Y' to create another user or any other key to exit"
if ($continue -eq "Y") {
    createUser
}
else {
    exit 0
}