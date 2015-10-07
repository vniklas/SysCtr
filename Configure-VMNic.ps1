<#
.Synopsis
   Workflow for Azure Automation to set VMM VM´s nic to static mac
.DESCRIPTION
   Long description
.EXAMPLE
   Configure-VMNIc -VMName test01
.EXAMPLE
   Configure-VMNic -VMname All
.INPUTS
   Inputs to this workflow (if any)
.OUTPUTS
   Output from this workflow (if any)
.NOTES
   Author : Niklas Akerlund 20150910
#>
workflow Configure-VMNic 
{
    Param
    (
        # Configure Specific VM Nic to be static mac
        [string]
        $VMName
    )

    $cred = Get-AutomationPSCredential -Name 'VMM Automation Account'
	$VMMServer = Get-AutomationVariable -Name 'VMMServer'
	inlinescript{
	   if($Using:VMName -ne "All"){
			$VM = Get-SCVirtualMachine -Name $Using:VMName -VMMServer $Using:VMMServer  # | Select -ExpandProperty VirtualNetworkAdapters | Where { $_.MACAddressType -eq "Dynamic" } | where Name -NotLike $env:COMPUTERNAME 
			$VirtualNetworkAdapters = Get-SCVirtualNetworkAdapter -VMMServer $Using:VMMServer -VM "$VM" |  Where { $_.MACAddressType -eq "Dynamic" }
			if($VM.Status -eq "Running"){
				Stop-SCVirtualMachine -VM $VM -Force
				foreach ($VirtualNetworkAdapter in $VirtualNetworkAdapters){	
					Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter -MACAddress "00:00:00:00:00:00" -MACAddressType Static 
				}
				Start-SCVirtualMachine -VM $VM.Name
			}else{
				foreach ($VirtualNetworkAdapter in $VirtualNetworkAdapters){	
					Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter -MACAddress "00:00:00:00:00:00" -MACAddressType Static 
				}
			}
			
		}else{
			$VMs = Get-SCVirtualMachine -VMMServer $Using:VMMServer | where {$_.Name -NotLike $env:COMPUTERNAME }
			foreach ($VM in $VMs){
				$VirtualNetworkAdapters = Get-SCVirtualNetworkAdapter -VMMServer $Using:VMMServer -VM "$VM" |  Where { $_.MACAddressType -eq "Dynamic" }
				if($VM.Status -eq "Running"){
					Stop-SCVirtualMachine -VM $VM -Force
					foreach ($VirtualNetworkAdapter in $VirtualNetworkAdapters){	
						Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter -MACAddress "00:00:00:00:00:00" -MACAddressType Static 
					}
					Start-SCVirtualMachine -VM $VM.Name
				}else{
					foreach ($VirtualNetworkAdapter in $VirtualNetworkAdapters){	
						Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter -MACAddress "00:00:00:00:00:00" -MACAddressType Static 
					}
				}
				
			}
			
		}
		
	} -PSComputerName vmm12.vniklas.com -PSCredential $cred 
 
}