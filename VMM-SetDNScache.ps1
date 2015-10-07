# Configure TTL for VMM server to success in BareMetal deploy

New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "MaxCacheTtl" -Value 5 -PropertyType "DWORD" -Force

New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "MaxNegativeCacheTtl" -Value 5 -PropertyType "DWORD" -Force

Restart-Service -Name Dnscache -Force –Verbose