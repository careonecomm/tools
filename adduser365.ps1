# Connect to Microsoft 365 online
Connect-MsolService

# Check for availability of ENTERPRISEPACK licenses
$license = Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq "ENTERPRISEPACK"}
$licensesavailable = $license.ActiveUnits - $license.ConsumedUnits
$domain = "domain.com"

Write-Output "There are $licensesavailable ENTERPRISEPACK licenses available"

if ($licensesavailable -gt 0) {
    # Request user's first and last name
    $firstName = Read-Host "Enter user's first name"
    $lastName = Read-Host "Enter user's last name"

    $firstname = $firstName -replace '\s', '' -replace '[^a-zA-Z0-9]', ''
    $lastname = $lastName -replace '\s', '' -replace '[^a-zA-Z0-9]', ''

    # Create username
    $userName = ($firstName.Substring(0,1) + $lastName).ToLower()

    # Create new user with ENTERPRISEPACK license and default password
    New-MsolUser -FirstName $firstName -LastName $lastName -DisplayName "$firstname $lastname" -UserPrincipalName "$userName@$domain" -UsageLocation "US" -LicenseAssignment $license.AccountSkuId

    Write-Host "User $userName created with ENTERPRISEPACK license and default password"
} else {
    Write-Host "No ENTERPRISEPACK licenses available"
}
