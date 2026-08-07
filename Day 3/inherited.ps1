$c = Get-CimInstance Win32_ComputerSystem
$d = Get-PSDrive C | Select-Object -ExpandProperty Free
$p = Get-Process | Sort-Object WS -Descending | Select-Object -First 5
\(e = Get-WinEvent -LogName System -MaxEvents 10 | Where-Object {\).Level -eq 2}
$u = Get-CimInstance Win32_UserProfile | Where-Object 
 -not $.Special -and $.LastUseTime -lt (Get-Date).AddDays(-90)}
 Write-Host $c.Name c.TotalPhysicalMemoryWrite−Host([math]::Round(
d/1GB,2)) ‘GB free’
 $p ForEach-Object { Write-Host $.Name $.WS
$e | ForEach-Object { Write-Host $.TimeCreated _.Message }
if (
u.Count -gt 0) { Write-Host ‘Stale profiles:’ $u.Count }