<#
.Synopsis
   Diff windows feature
.DESCRIPTION
   Get windows feature of specified computer
   Diff them
.EXAMPLE
   Get-WindowsFeatureDifference -ComputerName "Host1","Host2","Host3"
.EXAMPLE
   1..3 | %{ "Host$_" } | Get-WindowsFeatureDifference
#>
function Get-WindowsFeatureDifference
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName
    )

    Begin
    {
        $AllComputers = @()
        $FeatureList = @()
        $Result = @()
    }
    Process
    {
        foreach($cname in $ComputerName){
            $AllComputers += $cname
            $features = Get-WindowsFeature -ComputerName $cname | where Installed
            $FeatureList += @{
                "ComputerName" = $cname;
                "Features" = $features
            }
        }
    }
    End
    {
        Write-Verbose "Items in Feature list: $($FeatureList.Length)"
        foreach($item in $FeatureList){
            $cname = $item.ComputerName
            foreach($f in $item.Features){
                $feature_name = $f.Name
                $feature_in_list = $Result | where Name -eq $feature_name | select -First 1
                if($feature_in_list){
                    $feature_in_list.ComputerName += $cname
                }else{
                    $feature_push_to_list =  @{
                        "Name" = $f.Name;
                        "DisplayName" = $f.DisplayName;
                        "ComputerName" = @($cname)
                    }
                    $Result += $feature_push_to_list
                }
            }
        }
        $Result | where {$_.ComputerName.length -ne $AllComputers.Length}
    }
}