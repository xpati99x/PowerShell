$firewallshouldbe = Read-Host -Prompt "Firewall 'Enabled' or 'Disabled' ?" #Eingabe
if ($firewallshouldbe = "Enabled") { #Firewall aktivieren
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
}
elseif ($firewallshouldbe ="Disabled") { #Firewall aktivieren
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
}