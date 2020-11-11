# Set the line counter to 0
$linecount = 0
# Set the file counter to 1. This is used for the naming of the log files
$filenumber = 1
# InputPath
$sourcefilename = "C:\cont\in\main.csv"
# OutputPath
$destinationfolderpath = "C:\cont\split_out\"

# Size of split files
[int]$maxsize = "995"

# The process reads each line of the source file, writes it to the target log file and increments the line counter. When it reaches 100000 (approximately 50 MB of text data)
$content = get-content $sourcefilename | ForEach-Object {
Add-Content $destinationfolderpath\splitcsv$filenumber.csv "$_"
  $linecount ++
  If ($linecount -eq $maxsize) {
    $filenumber++
    $linecount = 0
  }
}

# Clean up after your pet
[gc]::collect() 
[gc]::WaitForPendingFinalizers()