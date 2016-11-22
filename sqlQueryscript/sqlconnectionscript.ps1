[xml]$ConfigFile = Get-content "C:\Users\confirmtktuser\Desktop\SqlQuery_Script\DataBaseServerConfig.xml"
$sqlDBName = $ConfigFile.Settings.DataBaseName
$username = $ConfigFile.Settings.UserName
$password = $ConfigFile.Settings.Password 
$sqlQuery = Get-Content -Path $ConfigFile.Settings.QueryFile
$atfile = $ConfigFile.Settings.Attachment
$msg = new-object Net.Mail.MailMessage

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
# Create the connection string
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
Try
{
foreach($sqlServer in ($ConfigFile.Settings.ServerName.ip))
{
$count++
"query executing for $sqlServer Server "
$sqlConnectionString = "Server = $sqlServer; Database = $sqlDBName; User ID=$username; Password=$password;Integrated Security=true"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $sqlConnectionString

#Create the SQL Command object
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection  = $SqlConnection
$SqlCmd.CommandTimeout = 300 
#Open SQL connection
$SqlCmd.Connection.Open()

#Execute the Query
$ReturnValue = $SqlCmd.ExecuteNonQuery()

}
"For $count Server Script Executed successfully"
$msg.From = "$From"
$msg.To.Add("$To")
$msg.Subject = "SQL Script For All Server"
$msg.Body = "For $count server Station Script Executed Successfully. `n Script File Attached Here"
$att = new-object Net.Mail.Attachment($atfile)
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
#$attachment = New-Object System.Net.Mail.Attachment –ArgumentList C:\Users\kothadineshkumar\Desktop\SqlQuery_Script\script.sql
$msg.Attachments.Add($att)
#$msg.Attachments.Add($attachment)

$smtp.Send($msg);
#$smtp.Send($From, $To, $Subject, $Body, $attachment);

}
Catch [System.Exception]
  {
    $ex = $_.Exception
    $message = $ex.Message
    Write-Host $message
#--------------------------Exception Mail Alert-------------------
$Subject = "Regarding fail to Execute Query"
$Body = "Exception are as following: `n $message" 
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
$smtp.Send($From, $To, $Subject, $Body);
  }
  Finally
  { 
    $SqlConnection.Close() 
  }

