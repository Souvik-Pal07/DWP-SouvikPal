Category: Identity/Authentication
Common cause: User token expired, cached credentials mismatch, or account lock/disable.
Fastest validation check: Re-authenticate with corporate credentials and confirm account status in Entra AD/AD (locked/disabled/password expired).

Category: Device Network Connectivity
Common cause: Endpoint has no valid corporate network path (wrong VLAN, disconnected Wi-Fi, limited connectivity).
Fastest validation check: Verify IP/default gateway with ipconfig and ping the gateway.

Category: DNS/Name Resolution
Common cause: Resource hostname cannot resolve or resolves to incorrect/private-unreachable address.
Fastest validation check: Run nslookup on the resource hostname and confirm expected IP.

Category: VPN/Remote Access Path
Common cause: VPN connected but missing internal routes or split-tunnel policy excludes target subnet.
Fastest validation check: Confirm VPN is connected and test access by target IP (not hostname).

Category: Authorization (NTFS/Share Permissions)
Common cause: User lacks required share or folder permissions after role/group changes.
Fastest validation check: Test access with a known-authorized account or verify effective access via group membership.

Category: SMB/Drive Mapping Configuration
Common cause: Stale mapped drive, conflicting drive letter, or legacy SMB requirement mismatch.
Fastest validation check: Remove and remap the share path (\\server\share) and test direct UNC access.

Category: Endpoint Security/Policy Control
Common cause: Firewall, Defender, or security policy blocks SMB/required ports to internal resource.
Fastest validation check: Temporarily test TCP reachability to required port (for example 445) with Test-NetConnection.

Category: Server/Resource Availability
Common cause: File server/service offline, maintenance window, or storage/service incident.
Fastest validation check: Confirm service health from monitoring or test access from another known-good endpoint.