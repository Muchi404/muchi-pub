Function Upgrade-Win {
    try {
        $null = sc.exe config LicenseManager start= auto > $null 2>&1
        $null = net start LicenseManager > $null 2>&1

        $null = sc.exe config wuauserv start= auto > $null 2>&1
        $null = net start wuauserv > $null 2>&1

        & "changepk.exe" /productkey "VK7JG-NPHTM-C97JM-9MPGT-3V66T"
    } catch {
        throw $_
    }
}
Upgrade-Win