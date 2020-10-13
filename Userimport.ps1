$manualMode = Read-Host -Prompt 'Interaktiven Modus verwenden? [J]a || [N]ein'

$Password = ConvertTo-SecureString -String "Start.123" -AsPlainText -Force

if ($manualMode -eq 'N' -or $manualMode -eq 'n')
{
    $csvpath = "C:\temp\csv.csv" #Pfad zur CSV
    $delimiter = ';' #Trennzeichen in der CSV
    $companyname = "multi-media systeme AG" #String hinter | im Anzeigenamen
    $domain = "mmsag.local" #Lokale Domäne

    $newUsers = Import-Csv -Path $dateipfad -Delimiter $delimiter

    foreach ($newUser in $newUsers)
    {
        $tempVorname = $newUser.Vorname 
        $tempNachname = $newUser.Nachname

        $tempAnzeigename = $tempVorname + $tempNachname + " | " + $companyname #Anzeigename aus Vorname, Nachname und Unternehmensname
    
        $cutVorname = $tempVorname.substring(0,1)
        $lowNachname = $tempNachname.tolower()
        $tempAccountname = $cutVorname + $lowNachname #Anmeldename zusammensetzen
        $tempAccountname = $tempAccountname.tolower() #Anmeldename kleinschreiben

        New-ADUser `
        -sAMAccountName $tempAccountname `
        -givenName $newUser.Vorname `
        -sn $newUser.Nachname `
        -OfficePhone $newUser.Telefonnummer `
        -Department $newUser.Abteilung `
        -DisplayName $tempAnzeigename `  #Anzeigename aus Vor-, Nach- und Unternehmensname
        -UserPrincipleName $tempAccountname + $domain ` #UPN aus Anmeldename und Domäne

        if ($newUser.Gruppenkopie -notlike "")
        {
          Get-ADUser -Identity $newUser.Gruppenkopie -Properties $tempAccountname | Select-Object -ExpandProperty memberof | Add-ADGroupMember $tempAccountname #Gruppenmitgliedschaften des angegebenen Benutzers übernehmen
        }
        else
        {
          echo "Keine Gruppenmitgliedschaften kopiert"
        }
    }
}
else
{
     
     #Abfragen der Nutzerdaten

     $domain = Read-Host -Prompt 'Lokale Domäne'
     $Unternehmensname = Read-Host -Prompt 'Unternehmensname'
     $Accountname = Read-Host -Prompt 'Anmeldename'
     $Vorname = Read-Host -Prompt 'Vorname'
     $Nachname = Read-Host -Prompt 'Nachname'
     $Telefonnummer = Read-Host -Prompt 'Telefonnummer'
     $Abteilung = Read-Host -Prompt 'Abteilung'
     $Anzeigename = $Vorname + $Nachname + " | " + $Unternehmensname
     $Gruppenkopie = Read-Host -Prompt 'Name des zu kopierenden Nutzers oder leer für keine Kopie'

     
     #Erstellen des Nutzers
     
     New-ADUser `
        -sAMAccountName $Accountname `
        -givenName $Vorname `
        -surname $Nachname `
        -OfficePhone $Telefonnummer `
        -Department $Abteilung `
        -DisplayName $Anzeigename `
        -UserPrincipalName ($Accountname + $domain) `
        -AccountPassword $Password `
        -Enabled $True 

        
    if ($newUser.Gruppenkopie -notlike "")
    {
        Get-ADUser -Identity $newUser.Gruppenkopie -Properties $tempAccountname | Select-Object -ExpandProperty memberof | Add-ADGroupMember $tempAccountname #Gruppenmitgliedschaften des angegebenen Benutzers übernehmen
    }
    else
    {
        echo "Keine Gruppenmitgliedschaften kopiert."
    }
}




