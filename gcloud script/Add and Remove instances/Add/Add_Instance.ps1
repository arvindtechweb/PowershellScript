[xml]$ConfigFile = Get-Content "C:\Users\arvindgeek\Desktop\gcloud script\Add and Remove instances\Add\scriptconfig.xml"
$ApiInstance=$ConfigFile.Settings.Instances
$startinstances=$ConfigFile.Settings.Instances.StartInstances
foreach($tag in $ConfigFile.Settings.Emailsettings.add)
		{
			if($tag.key -eq "Sender")
				{$From = $tag.value}
			if ($tag.key -eq "Receiver")
				{$To = $tag.value}
			if($tag.key -eq "SMTPUsername")
				{$UName = $tag.value}
			if($tag.key -eq "SenPass" )
				{$Pword = $tag.value}
			if($tag.key -eq "SMTPClientHost")
				{$SMTPHost = $tag.value}
			if($tag.key -eq "SMTPClientPort")
				{$SMTPPort = $tag.value}
		}


cd "C:\Users\kothadineshkumar\AppData\Local\Google\Cloud SDK"

"*** You are Entered in Gcloud Zone ***"
gcloud config set compute/zone asia-east1-a
#$strtwatch = [System.Diagnostics.Stopwatch]::StartNew()
"$startinstances"
gcloud compute instances start,api1,api2,api3
<#gcloud compute instance-groups unmanaged add-instances confirmtktapinew --instances $ConfigFile.Settings.Instances.AddInstances#>
"Instances Added"
$Subject = "Regarding Added instances in group"
$Body = "$ApiInstance" 
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
$smtp.Send($From, $To, $Subject, $Body);