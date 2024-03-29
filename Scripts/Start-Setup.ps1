# Created to easily setup new client computers onto the domain.
# Time zone: -t [EST, PST, CST]
# Perferred DNS: -d
# Alternative DNS: -a
# Set IPv4 to DHCP: -dhcp

function Start-Setup {
    param(
        [Parameter(Mandatory=$true)]
        [string]$t,

        [Parameter(Mandatory=$true)]
        [string]$d, 

        [Parameter(Mandatory=$true)]
        [string]$a, 

	[Parameter(Mandatory=$false)]
        [switch]$dhcp 

    )

    Write-Host "Updating time zone to $t."
    $timeZoneId = switch ($t) {
        "PST" { "Pacific Standard Time" }
        "EST" { "Eastern Standard Time" }
        "CST" { "Central Standard Time" }
        "UTC" { "UTC" }
        Default { throw "Invalid time zone entered." }
    }

    Set-TimeZone -Id $timeZoneId
    Write-Host "Time zone updated to $t."
    $interfaceIndex = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).InterfaceIndex
   
    if ($dhcp) {
        Write-Host "Configuring IPv4 settings to use DHCP."
        Set-NetIPInterface -InterfaceAlias "Ethernet0" -Dhcp Enabled
    } else {
        Write-Host "Did not touch IPv4"
    }
        
    Write-Host "Updating DNS settings: Preferred DNS is $d, Alternate DNS is $a."
    Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ($d, $a)
    Write-Host "DNS settings updated: Preferred DNS is $d, Alternate DNS is $a."
    

    sysdm.cpl
    sleep 1
    Start-Process "ms-settings:windowsupdate"
    sleep 1
    ncpa.cpl

    Write-Host "Running quick checks..."
    ipconfig /release > $null
    ipconfig /renew > $null
    ipconfig /flushdns > $null
    Write-Host "Script execution completed."
}

# Example usage
# Start-Setup -t "EST" -d "192.168.1.120" -a "8.8.8.8" [optional] -dhcp

