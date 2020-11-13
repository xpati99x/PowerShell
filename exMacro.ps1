# start Excel 
$excel = New-Object -comobject Excel.Application  

#open file 
$FilePath = 'C:\cont\required\Makro.xlsm' #<------- Change this!!! 
$workbook = $excel.Workbooks.Open($FilePath)  

#access the Application object and run a macro $app = $excel.Application 
$excel.Application.Run("TelefonDatShit") #<------- Change this!!! 
$excel.Quit()     

#Popup box to show completion - you would remove this if using task scheduler 
$wshell = New-Object -ComObject Wscript.Shell $wshell.Popup("Operation Completed",0,"Done",0x1)  

exit