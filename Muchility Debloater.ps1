#╔══╗══╗╔═╗═╗╔═══╗╔═╗╔═╗╔═╗"
#║*   *║║*║*║║*║*║║*╚╝*║╠-╣"
#║ ║ ║ ║║*║*║║*╚═╣║*╔╗*║║*║"
#╚═╩═╩═╝╚═══╝╚═══╝╚═╝╚═╝╚═╝"

$GoodApps = "calculator|store|windowsnotepad|chatgpt|minecraft|nvidia|Microsoft.Xbox.TCUI|XboxGameCallableUI|XboxGamingOverlay|XboxIdentityProvider|"

Function RemoveApps {
    # SafeApps contains apps that shouldn't be removed, or just can't and cause errors
    $SafeApps = "AAD.brokerplugin|accountscontrol|apprep.chxapp|assignedaccess|asynctext|bioenrollment|capturepicker|cloudexperience|contentdelivery|desktopappinstaller|ecapp|edge|extension|getstarted|immersivecontrolpanel|lockapp|net.native|oobenet|parentalcontrols|PPIProjection|search|sechealth|secureas|shellexperience|startmenuexperience|terminal|vclibs|xaml|XGpuEject"
    
    If ($Xbox) {
        $SafeApps = "$SafeApps|Xbox"
    }
    
    If ($Allapps) {
        $RemoveApps = Get-AppxPackage -allusers | where-object {$_.name -notmatch $SafeApps}
        $RemovePrApps = Get-AppxProvisionedPackage -online | where-object {$_.displayname -notmatch $SafeApps}
        
        ForEach ($RemovedApp in $RemoveApps) {
            Remove-AppxPackage -package $RemovedApp -erroraction silentlycontinue
        }
        
        ForEach ($RemovedPrApp in $RemovePrApps) {
            Remove-AppxProvisionedPackage -online -packagename $RemovedPrApp.packagename -erroraction silentlycontinue
        }
    } Else {
        $SafeApps = "$SafeApps|$GoodApps"
        $RemoveApps = Get-AppxPackage -allusers | where-object {$_.name -notmatch $SafeApps}
        $RemovePrApps = Get-AppxProvisionedPackage -online | where-object {$_.displayname -notmatch $SafeApps}
        
        ForEach ($RemovedApp in $RemoveApps) {
            Remove-AppxPackage -package $RemovedApp -erroraction silentlycontinue
        }
        
        ForEach ($RemovedPrApp in $RemovePrApps) {
            Remove-AppxProvisionedPackage -online -packagename $RemovedPrApp.packagename -erroraction silentlycontinue
        }
    }
}
# End Function RemoveApps

RemoveApps




