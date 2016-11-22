[xml]$ConfigFile = Get-Content "C:\Users\arvindgeek\Desktop\gcloud script\Add and Remove instances\Remove\scriptconfig.xml"
$ApiInstance=$ConfigFile.Settings.Instances.RemoveInstances
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

cd "C:\Users\arvindgeek\AppData\Local\Google\Cloud SDK"
"*** You are Entered in Gcloud Zone ***"
gcloud config set compute/zone asia-east1-a
#$strtwatch = [System.Diagnostics.Stopwatch]::StartNew()
<#gcloud compute instance-groups unmanaged remove-instances confirmtktapinew --instances $ConfigFile.Settings.Instances.RemoveInstances
"Instances Removed from Group"#>
gcloud compute instances stop confirmtktnewapi1,confirmtktnewapi2,confirmtktnewapi3,confirmtktnewapi4,confirmtktnewapi5,confirmtktnewapi6,confirmtktnewapi7,confirmtktnewapi8,confirmtktnewapi9,confirmtktnewapi10,confirmtktnewapi11,confirmtktnewapi12,confirmtktnewapi13,confirmtktnewapi14,confirmtktnewapi15,confirmtktnewapi16,confirmtktnewapi17,confirmtktnewapi18,confirmtktnewapi19,confirmtktnewapi20
"Instances are stopped"
#**********Start Mail part************************
$Subject = "Instances Removed and stop from Group"
$Body = "$ApiInstance instances Removed" 
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
$smtp.Send($From, $To, $Subject, $Body); 