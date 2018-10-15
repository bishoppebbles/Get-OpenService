<#
.SYNOPSIS
    This is a poorman's port scanner.  It will attempt to discover live hosts and then check for active services based on a defined list of TCP ports.
.DESCRIPTION
    This script will attempt to discover live hosts (via ping) for any subnets of interest.  For any live hosts a TCP connection will then be attempted to each system using a predefined list of port numbers.
.PARAMETER ScanRange
    Defines the range of values to scan for the last octet of an IPv4 address.
    /24 = 1..255
    /25 = 1..127, 128..255
    /26 = 1..63, 64..127, 128..191, 192..255
    /27 = 1..31, 32..63, 64..95, 96..127, 128..159, 160..191, 192..223, 224..255
    /28 = 1..15, 16..31, 32..47, 48..63, 64..79, 80..95, 96..111, 112..127, 128..143, 144..159, 160..175, 176..191, 192..207, 208..223, 224..239, 240..255
.PARAMETER Networks
    Defines the first three octets of an IPv4 address.  One or more of these can be listed and each element should be defined as a string.  The trailing dot (.) of the third octet must be included or the generation of the complete IP address will fail.  The scan range will be generated for each defined network.
.PARAMETER Ports
    This is an array of TCPs that will be scanned.  Note that if there is no connection or if the remote host does not reset the connection, the timeout for the TCP socket is quite long (15-30 seconds).  The number of ports scanned is likely the single biggest factor in the run time of this script.  Choose your ports to scan wisely.
.NOTES
    Version 1.0
    Sam Pursglove
    Last Modified: 19 SEP 2018
.EXAMPLE
    Get-OpenServices.ps1

    Runs the script with the default settings: -ScanRange 1..255 -Networks @('192.168.0.','192.168.1.') -Ports @(20, 21, 22, 23, 25, 53, 67, 68, 69, 80, 135, 137, 138, 139, 161, 162, 515, 443, 445, 631, 1720, 1900, 5000, 9100)
.EXAMPLE
    Get-OpenServices.ps1 -ScanRange 1..64 -Networks @('10.0.1.','10.0.2.','10.0.3.') -Ports @(21, 22, 23, 25, 80)

    Runs the script to scan the 10.0.1.0/26, 10.0.2.0/26, and 10.0.3.0/26 networks on TCP ports usually associated with FTP, SSH, Telnet, SMTP, and HTTP.
#>

Param 
(
    [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, HelpMessage = 'The range of hosts to scan between 1 to 255 (last octect).')]
    $ScanRange = 1..30,

    [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $false, HelpMessage ='Specify the network(s) of interest to scan (first three IPv4 octets).')]
    $Networks = @('192.168.0.','192.168.1.'),

    [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $false, HelpMessage ='Specify the TCP port values to scan.')]
    $Ports = @(20, 21, 22, 23, 25, 53, 67, 68, 69, 80, 135, 137, 138, 139, 161, 162, 515, 443, 445, 631, 1720, 1900, 5000, 9100)
)

$TargetIPs = foreach($network in $Networks) {
                foreach($octet in $ScanRange) {
                    "$network$octet"
                }
             }

$ActiveHosts = $TargetIPs | ForEach-Object { 
                                ping -n 1 -w 100 $_ | 
                                Select-String ttl
                            }

$ActiveHostIPs = $ActiveHosts | ForEach-Object { $_.Line.Split()[2].Split(':')[0] }

$ActiveHostIPs | ForEach-Object { 
                    $hostIP = $_; $Ports = $_ |
                    
                    ForEach-Object { 
                        Write-Output ((New-Object Net.Sockets.TcpClient).Connect($hostIP, $_)) "$hostIP,$_"
                    } 2>$null
                 }