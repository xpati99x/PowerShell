#Line added to the top
$topline = "FirstName,LastName,Company,Mobile,Mobile2,Home,Home2,Business,Business2,Email,Other,BusinessFax,HomeFax,Pager"
$filePath = "C:\cont\split_out\"
$firstfile = "C:\cont\split_out\splitcsv1.csv"
(Get-Content $firstfile | Select-Object -Skip 1) | Set-Content $firstfile


$files = Get-ChildItem $filePath
foreach ($f in $files) {
    [string]$outfile = $f.Name
    $outfile
    #An existing file with content, contains "Existing Text"
    $content = Get-Content $f.FullName
    #Create a new array
    $Output = @()
    #Add new text
    $Output += $topline
    #Append old text from content
    $Output += $content
    Set-Location C:\cont\topline_out
    $Output | Out-File -FilePath .\$outfile
}
