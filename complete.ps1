#GENERAL PART
#Eingangsdatei
$sourcefilename = "C:\cont\in\main.csv"
#Ausgangsverzeichnis
$filePath = "C:\cont"
Set-Location $filePath

#SPLIT PART
# Set counters and length for the splitting of the files
$linecount = 0
$filenumber = 1
[int]$maxsize = "998"

#ADD-TOPLINE PART
#String for the line to be added at the top of each file
$topline = "FirstName,LastName,Company,Mobile,Mobile2,Home,Home2,Business,Business2,Email,Other,BusinessFax,HomeFax,Pager"

function getExcel {
    # start Excel 
    $excel = New-Object -comobject Excel.Application  

    #open file 
    $FilePath = 'C:\cont\required\Makro.xlsm' 
    $workbook = $excel.Workbooks.Open($FilePath)

    #access the Application object and run a app
    $app = $excel.Application
    $app.Run("TelefonDatShit") 
    $excel.Quit() 
}

function xlsxToCSV {
    # start Excel 
    $excel = New-Object -comobject Excel.Application  

    #open file 
    $FilePath = 'C:\cont\required\toCSV.xlsm' 
    $workbook = $excel.Workbooks.Open($FilePath)

    #access the Application object and run a app
    $app = $excel.Application
    $app.Run("toCSV.xlsm!Modul1.toCSV") 
    $excel.Quit()
}

function split {
    #Reads each line and writes it into a new file everytime $maxsize is reached
    $content = get-content $sourcefilename | ForEach-Object {
    Add-Content $filePath\split_out\splitcsv$filenumber.csv "$_"
    $linecount ++
    If ($linecount -eq $maxsize) {
        $filenumber++
        $linecount = 0
    }
    }
    #Clean up
    [gc]::collect() 
    [gc]::WaitForPendingFinalizers()
}


function addtopline {
    #Delete the topline in the first file to avoid a duplicate
    $firstfile = "$filePath\split_out\splitcsv1.csv"
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
        Set-Location $filePath\topline_out\
        $Output | Out-File -FilePath .\$outfile
    }
}

#Exceldatei abholen und auf Beendigung warten
getExcel
Get-Job | Wait-Job
#Exceldatei in benötigte CSV umwandeln und auf Beendigung warten
#xlsxToCSV
#Get-Job | Wait-Job
#Dateien aufteilen und auf Beendigung warten
split
Get-Job | Wait-Job
#Kopfzeile hinzufügen
addtopline