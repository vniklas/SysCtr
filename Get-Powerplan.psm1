<#
.Synopsis
   As the WMI has some issues on core I use PowerCFG.exe and get data in this function 
.DESCRIPTION
   Long description
.EXAMPLE
   Get-PowerPlan -ComputerName HypervCore1
.EXAMPLE
   Get-PowerPlan -ComputerName Hcore1,Hcore2,Hcore3
.NOTES
Author: Niklas Akerlund 20141202
#>
function Get-PowerPlan
{
    [CmdletBinding()]
    Param
    (
        
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName="localhost"
    )
    $result = @()

    foreach ($Computer in $ComputerName){
    $res = Invoke-Command -ComputerName $Computer -ScriptBlock {
        powercfg.exe -l   
    }
        foreach ($l in $res){
        if($l.EndsWith("*")){
            $regex = [regex]"\((.*)\)"
            $ActivePlan = [regex]::match($l, $regex).Groups[1].Value
            $regex2 = [regex]"\w{1,12}\-\w{1,12}\-\w{1,12}\-\w{1,12}\-\w{1,12}"
            $guid = [regex]::match($l, $regex2).Groups[0].Value
            $hash = [ordered]@{
                ComputerName = $Computer
                ActivePlan = $ActivePlan
                Guid = $guid
            }
        }
        }
        $PowerPlan = New-Object -TypeName PSObject -Property $hash
        $result += $PowerPlan
    }
    $result
}


<#
.Synopsis
   As the WMI has some issues on core I use PowerCFG.exe and set the powerplan in this function 
.DESCRIPTION
   Set the Powerplan with either a switch or Guid
.EXAMPLE
   Set-PowerPlan -ComputerName HypervCore1 -HighPerfomance
.EXAMPLE
   Set-PowerPlan -ComputerName Hcore1,Hcore2,Hcore3 -Balanced
.NOTES
 Author: Niklas Akerlund 20141202
#>
function Set-PowerPlan
{
    [CmdletBinding()]
    Param
    (
        
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName="localhost",
        [Switch]$HighPerformance,
        [Switch]$Balanced,
        [Switch]$PowerSaver,
        [string]$Guid
    )
    if($HighPerformance){
        $Guid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" 
        
    } 
    if($Balanced){
        $Guid = "381b4222-f694-41f0-9685-ff5bb260df2e"  
    } 
    if($PowerSaver){
        $Guid = "a1841308-3541-4fab-bc81-f71556f20b4a"
    }

    foreach ($Computer in $ComputerName){
    $res = Invoke-Command -ComputerName $Computer -ScriptBlock {
        powercfg.exe -s $Using:Guid    
        }
       
    }
}