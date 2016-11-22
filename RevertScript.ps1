[xml]$ConfigFile = Get-Content "C:\Users\arvind\Desktop\Power_Shell_Scripts\scriptconfig.xml"
$Rsource = $ConfigFile.Settings.RevertSource 

#-------file backup start------

$date = Get-Date -f "dd-MM-yyyy_HH.mm";
$backupsource = "C:\inetpub\wwwroot\bin" 
$backupdest = "C:\inetpub\wwwroot\Backupfiles\DateWise\$date"  
$path = test-Path $backupdest  
"$path"
if ($path -eq $False) {
    cd c:\inetpub\wwwroot\Backupfiles\DateWise\ 
            mkdir $date 
            copy-Item  -Recurse $backupsource -Destination $backupdest
            cd C:\windows\system32\ 
  } 
elseif ($path -eq $true) 
{
 write-Host "Directory Already exists"             
}

#-----file backup end------------------------------

#-------start Revert Deployement-Just Repalce------------------
$scount = 0
$user = "arvindgeeks" 
$pass = "******"
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass) 
foreach($server in ($ConfigFile.Settings.Destination.ip))
{
$serve = "ftp://" + $server + "/"
 Write-Host "For IP $server"
$fcount = 0
$scount = $scount + 1
foreach($item in (dir $Rsource "*"))
{
 
    
$fcount = $fcount + 1 
$uri = New-Object System.Uri($serve+$item.Name) 
$webclient.UploadFile($uri,$item.FullName) 
 }
}
"for $scount Server $fcount files Reverted Successfully"
 
#send-MailMessage -SmtpServer $smtp -From $from -To $to -Subject $subject -Attachments $attachment -Body $body -BodyAsHtml 
#--------End Revert Deployment------------------------------------

#----------------------Success mail----------------------------
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
$Subject = "Revert Process"
$Body = "for $scount server, $fcount Files Reverted successfully"
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UserName, $Password);
$smtp.Send($From, $To, $Subject, $Body);