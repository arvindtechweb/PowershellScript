[xml]$ConfigFile = Get-Content "C:\Users\Coder\Desktop\Power_Shell_Scripts\scriptconfig.xml"
$Dir = $ConfigFile.Settings.Source 
#-------------------------------------------------
#                       Strat Mail Script
#-------------------------------------------------
foreach($tag in $ConfigFile.Settings.Emailsettings.add)
		{
			if($tag.key -eq "Sender")
				{$From = $tag.value}
			if ($tag.key -eq "Receiver")
				{$To = $tag.value}
			if($tag.key -eq "SMTPUsername")
				{$UserName = $tag.value}
			if($tag.key -eq "SenPass" )
				{$Password = $tag.value}
			if($tag.key -eq "SMTPClientHost")
				{$SMTPHost = $tag.value}
			if($tag.key -eq "SMTPClientPort")
				{$SMTPPort = $tag.value}
		}
<#$Subject = "Files Ready to Upload on Server"
$Body = "Files are Uploading on Server"
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UserName, $Password);
$smtp.Send($From, $To, $Subject, $Body);#>
#-------------------------------------------------------
#                     End mail Script 
#-------------------------------------------------------
#-------------------------------------------------------
#-----------------Start Backup script------------------
<#$Date = Get-Date -f "dd-MM-yyyy";
$Datepath =  "C:\inetpub\wwwroot\Backupfiles\Datewise\$Date"
$checkpath = test-Path $Datepath
"$checkpath"
if($checkpath -eq $false)
{
cd c:\inetpub\wwwroot\Backupfiles\DateWise\
mkdir $Date
 cd c:\windows\system32\
}
$datetime = Get-Date -f "dd-MM-yyyy_HH.mm";
$source = "C:\inetpub\wwwroot\bin\" 
$destination = "C:\inetpub\wwwroot\Backupfiles\Datewise\$Date\$datetime"  
$path = test-Path $destination  
"$path"
if ($path -eq $false) {
           cd c:\inetpub\wwwroot\Backupfiles\DateWise\$Date 
            mkdir $datetime
            cd C:\windows\system32\ 
            copy-Item  -Recurse $source -Destination $destination
             
     
    } 
elseif ($path -eq $true) 
{
 Remove-Item  -Recurse $destination
 copy-Item  -Recurse $source -Destination $destination
 write-Host "Datewise backupExisting bin overwritten"             
}
$lastbackupsource = "C:\inetpub\wwwroot\Backupfiles\LastUpdate\bin"
$l2ldest = "C:\inetpub\wwwroot\Backupfiles\LastToLast\"
$checkl2lpath = "C:\inetpub\wwwroot\Backupfiles\LastToLast\bin"
$l2lpath = test-Path $checkl2lpath
if($l2lpath -eq $true)
{
Remove-Item  -Recurse $checkl2lpath
copy-Item  -Recurse $lastbackupsource -Destination $l2ldest
}
else 
{
copy-Item  -Recurse $lastbackupsource -Destination $l2ldest
}
$lastdestination = "C:\inetpub\wwwroot\Backupfiles\LastUpdate\"
$lpath = test-Path $lastbackupsource
if($lpath -eq $true)
{
Remove-Item  -Recurse $lastbackupsource
copy-Item  -Recurse $source -Destination $lastdestination
}
else
{
copy-Item  -Recurse $source -Destination $lastdestination
}#>

#--------End Backup------------------------------------
#-------------------------------------------------------
#                     Start UpLoad Script
#------------------------------------------------------- 
$scount = 0
$fcount = 0
$user = "confirmtktuser" 
$pass = "2Mw/A^ut^6^5:KZ"


$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)
Write-Host "Script Running..." 
Try
{  
foreach($server in ($ConfigFile.Settings.Destination.ip))
{
$serve = "ftp://" + $server + "/"
$scount = $scount + 1
$tfcount = 0 
foreach($item in (dir $Dir "*"))
{    
$fcount = $fcount + 1 
$tfcount = $tfcount + 1
$uri = New-Object System.Uri($serve+$item.Name) 
$webclient.UploadFile($uri,$item.FullName)
 }
Write-Host "For IP $server files uploaded"
}
"$tfcount files for each $scount Server, total $fcount files Updated Successfully"

#-------------------------------------------------------------
#                         End Upload Script
#----------------------Success mail----------------------------
$Subject = "Files Uploaded Successfully"
$Body = "For $scount server, $tfcount File Uploaded successfully `n `n Uploaded File Name are as Following `n "
$Body += foreach($item in (dir $Dir "*")){"`n $item"}
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UserName, $Password);
$smtp.Send($From, $To, $Subject, $Body);
}
#--------------------------Exception Mail Alert-------------------
Catch [System.Exception]
  {
    $ex = $_.Exception
    $message = $ex.Message
    Write-Host "$message"
$Subject = "Regarding fail to Upload Files on Server"
$Body = "Exception are as following: `n $message" 
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
$smtp.Send($From, $To, $Subject, $Body);
  }