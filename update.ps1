function Save-GitHubRepository
{
    param(
        [Parameter(Mandatory)]
        [string]$Owner,

        [Parameter(Mandatory)]
        [string]$Repository,

        [Parameter(Mandatory)]
        [string]$Branch,

        [Parameter()]
        [string]$DestinationPath
    )

    $url = "https://github.com/$Owner/$Project/archive/$Branch.zip"
    $start_time = Get-Date

    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, ($DestinationPath + "\download.zip"))

    Write-Host "Time taken: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)" 
}

$Downloadpfad = (Get-Location)

Save-GitHubRepository xpati99x PowerShell master $Downloadpfad

pause