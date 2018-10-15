# Get-OpenService
This is a poor person's port scanner.  This script attempts to discover hosts and any of their listening services on networks without tools like Nmap available.

The code combines two readily available PowerShell oneliners for this type of thing.  I'm sure they have been written by multiple entities but I've pulled them from a SANS posters.  The first part uses ```ping``` to discover live hosts.  It is written to scan one or more /24 subnets.  For any live hosts that respond it saves their IP and then creates a TCP socket connection to test if a list of user defined ports are listening.

Note that, as far as I can tell, C# does not include any type of TCP socket timeout option (like you have with the C ```setsockopt()``` function).  ```ping``` is also used for this reason as it has the ```-w``` option for reply timeouts (whereas the PowerShell ```Test-Connection``` cmdlet does not have an equivalent feature).  Because of the socket timeout issue the script can run very slow as I believe the default timeout is around 15-30 seconds.  Unless the remote host sends a RST each attempted connection waits for the timeout entirety.  Therefore, it's recommended that only live hosts be further probed and users be judicious in their selection of ports to scan.

TO DO: Implement ```Invoke-Command``` to run the port scan concurrently to multiple hosts for faster performance.
