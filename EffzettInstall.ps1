# Startvariablen setzen
function SetPCName {
    Add-Type -AssemblyName Microsoft.VisualBasic
    #Rechnername setzen
    $ComputerName = [Microsoft.VisualBasic.Interaction]::InputBox('Computername eingeben:','Name')
    Write-Output "Der Computername ist $ComputerName"
    Rename-Computer -NewName "WN10$CompanyName$AssetID"
    #Hersteller herausfinden
    $computerSystem = (Get-WmiObject -Class:Win32_ComputerSystem)
    #Officeversion abfragen
    $OfficeVersion = [Microsoft.VisualBasic.Interaction]::InputBox('Office Version: HB,365 oder none','Office Version')
}
#Chocolatey installieren
function InstallChoco {
    # Ask for elevated permissions if required
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
        }
    # Install Chocolatey to allow automated installation of packages  
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
#Programminstallation
function InstallApps {
    #AdobeReader, 7Zip, NewEdge, Chrome, Firefox + 
    choco install adobereader 7zip microsoft-edge firefox googlechrome -y
    choco install eset-antivirus --version 7.3.1 -y --ignorechecksum
    if ($computerSystem -like "*Dell*") {
            choco install dellcommandupdate -y
    }
    #Gewählte Office-Version installieren
     if ($OfficeVersion -eq "HB"){Set-Variable -Name "OfficeVersion" -Value "HomeBusiness2019Retail"}
     elseif ($OfficeVersion -eq "365"){Set-Variable -Name "OfficeVersion" -Value "O365BusinessRetail"}
     elseif ($OfficeVersion -eq "none") {return}
     choco install microsoft-office-deployment --params="'/Channel:Monthly /Language:MatchOS /Product:$OfficeVersion'" -y
     Invoke-Item "c:\build\PC-Build-Script-master\ESET effzett.cmd"
}
#Dell-Updates installieren
function runCommandUpdate{
    & 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe' /applyUpdates

}
#Windows-Updates installieren
function runWindowsUpdate {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module PSWindowsUpdate
    Get-WindowsUpdate
    Install-WindowsUpdate

}
#OEM-Key auslesen
function ReclaimWindows10 {
    Start-Process -FilePath "c:\build\PC-Build-Script-master\oemkeyextract.exe"
    }
function DivSettings {
    # Disable Telemetry
    Write-Host "Disabling Telemetry..."
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

    # Disable Wi-Fi Sense
    Write-Host "Disabling Wi-Fi Sense..."
    If (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
        New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

    # Disable Bing Search in Start Menu
    Write-Host "Disabling Bing Search in Start Menu..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0

    # Disable Location Tracking
    Write-Host "Disabling Location Tracking..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0

    # Disable Feedback
    Write-Host "Disabling Feedback..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
        New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0

    # Disable Advertising ID
    Write-Host "Disabling Advertising ID..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

    # Disable Cortana
    Write-Host "Disabling Cortana..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
        New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
        New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
    If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
        New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0

    # Remove AutoLogger file and restrict directory
    Write-Host "Removing AutoLogger file and restricting directory..."
    $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
    If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
        Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
    }
    icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null

    # Stop and disable Diagnostics Tracking Service
    Write-Host "Stopping and disabling Diagnostics Tracking Service..."
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled

    # Stop and disable WAP Push Service
    Write-Host "Stopping and disabling WAP Push Service..."
    Stop-Service "dmwappushservice"
    Set-Service "dmwappushservice" -StartupType Disabled

    # Service Tweaks

    Enable sharing mapped drives between users
    Write-Host "Enabling sharing mapped drives between users..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -Type DWord -Value 1

    # Disable Windows Update automatic restart
    Write-Host "Disabling Windows Update automatic restart..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1

    # Stop and disable Home Groups services
    Write-Host "Stopping and disabling Home Groups services..."
    Stop-Service "HomeGroupListener"
    Set-Service "HomeGroupListener" -StartupType Disabled
    Stop-Service "HomeGroupProvider"
    Set-Service "HomeGroupProvider" -StartupType Disabled

    # UI Tweaks

    # Disable Lock screen
    #Write-Host "Disabling Lock screen..."
    #If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization")) {
    #  New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" | Out-Null
    #}
    #Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1

    # Enable Lock screen
    # Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen"

    # Disable Autoplay
    Write-Host "Disabling Autoplay..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

    # Disable Autorun for all drives
     Write-Host "Disabling Autorun for all drives..."
     If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
       New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
    }
     Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

    #Disable Sticky keys prompt
    Write-Host "Disabling Sticky keys prompt..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"

    
    # Hide Search button / box
    Write-Host "Hiding Search Box / Button..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

    # Hide Task View button
    Write-Host "Hiding Task View button..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

    # Show all tray icons
    Write-Host "Showing all tray icons..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 0

    # Show known file extensions
    Write-Host "Showing known file extensions..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

    # Change default Explorer view to "Computer"
    Write-Host "Changing default Explorer view to `"Computer`"..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
    #Show Computer shortcut on desktop
     Write-Host "Showing Computer shortcut on desktop..."
     If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
       New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" | Out-Null
     }
     Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
     Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
    }
    # Uninstall default Microsoft applications
function CleanWin10 {
    Write-Host "Uninstalling default Microsoft applications..."
    Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
    #Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.WindowsCamera" | Remove-AppxPackage
    # Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
    Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
    # Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
    Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
    Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
    Get-AppxPackage "king.com.CandyCrushSaga" | Remove-AppxPackage
    Get-AppxPackage "king.com.CandyCrushFriends" | Remove-AppxPackage

   
    # Set Photo Viewer as default for bmp, gif, jpg and png
    Write-Host "Setting Photo Viewer as default for bmp, gif, jpg, png and tif..."
    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }
    ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
        New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
        New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
        Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
        Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
    }
    # Show Photo Viewer in "Open with..."
    Write-Host "Showing Photo Viewer in `"Open with...`""
    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }
    New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
    New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
    Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
    Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
    Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
}
# Uploads a default layout to all NEW users that log into the system. Effects task bar and start menu
function LayoutDesign {
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
    Import-StartLayout -LayoutPath "c:\build\PC-Build-Script-master\LayoutModification.xml" -MountPath $env:SystemDrive\
    }

function ApplyDefaultApps {
    dism /online /Import-DefaultAppAssociations:c:\build\PC-Build-Script-master\AppAssociations.xml
}

function Energie {
    POWERCFG -DUPLICATESCHEME 381b4222-f694-41f0-9685-ff5bb260df2e 381b4222-f694-41f0-9685-ff5bb260aaaa
    POWERCFG -CHANGENAME 381b4222-f694-41f0-9685-ff5bb260aaaa "effzett Energiesparplan"
    POWERCFG -SETACTIVE 381b4222-f694-41f0-9685-ff5bb260aaaa
    POWERCFG -Change -monitor-timeout-ac 15
    POWERCFG -CHANGE -monitor-timeout-dc 5
    POWERCFG -CHANGE -disk-timeout-ac 30
    POWERCFG -CHANGE -disk-timeout-dc 5
    POWERCFG -CHANGE -standby-timeout-ac 0
    POWERCFG -CHANGE -standby-timeout-dc 30
    POWERCFG -CHANGE -hibernate-timeout-ac 0
    POWERCFG -CHANGE -hibernate-timeout-dc 0
}

function WindowsUpdate{
    Install-PackageProvider -name nuget -minimumversion 2.8.5.201 -force
    Install-Module PSWindowsUpdate -force
    Get-WindowsUpdate
    Install-WindowsUpdate -acceptall -autoreboot
}

function RestartPC{
    Write-Host
    Write-Host "Press any key to restart your system..." -ForegroundColor Black -BackgroundColor White
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host "Restarting..."
    Restart-Computer
}




#Internetverbindung überprüfen
$servername = "google.de"
if ((Test-NetConnection www.google.com -Port 443 -InformationLevel "Detailed").TcpTestSucceeded)
{
    InstallChoco
    InstallApps
    ReclaimWindows10
    CleanWin10
    LayoutDesign
    ApplyDefaultApps
    Energie
    SetPCName
    runCommandUpdate
    DivSettings
    WindowsUpdate
    RestartPC
}
else {
    Write-Host "Keine Internetverbindung"
    pause
    exit
}