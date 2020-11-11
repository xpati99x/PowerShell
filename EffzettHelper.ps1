Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'EffzettHelper.designer.ps1')
$Form1.ShowDialog()