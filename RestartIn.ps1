[uint16]$timeinHours = Read-Host -Prompt 'Zeit in Stunden'
[uint16]$timeinMinutes = Read-Host -Prompt 'Zeit in Minuten'
$timeuntilRestart = ($timeinHours*3600)+($timeinMinutes*60)
$restartTimestamp = (Get-Date).AddSeconds($timeuntilRestart)#Timestamp
shutdown -r -t $timeuntilRestart
echo "Der Computer wird am" $restartTimestamp "neugestartet."
[String]$AbbruchVar = Read-Host -Prompt 'Abbrechen? [X] || Irgendeine Taste zum schließen'
if ($AbbruchVar -eq "X")
{
    shutdown -a
    exit
}
else
{
    exit
}    