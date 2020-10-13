$Url = 'https://github.com/xpati99x/Effzett-Installation/archive/master.zip' 
$ZipFile = 'C:\tmp\' + $(Split-Path -Path $Url -Leaf) 
$Destination= 'C:\EffzettInstall\' 
 
Invoke-WebRequest -Uri $Url -OutFile $ZipFile 
 
$ExtractShell = New-Object -ComObject Shell.Application 
$Files = $ExtractShell.Namespace($ZipFile).Items() 
$ExtractShell.NameSpace($Destination).CopyHere($Files) 
Start-Process $Destination