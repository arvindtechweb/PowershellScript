[xml]$ConfigFile = Get-content "C:\Users\arvindgeek\Desktop\Power_Shell_Scripts\SqlDataBaseScript\ScraperConfig.xml"
$SourceServer      = $ConfigFile.Settings.Source.Server 
$Sourcedatabase    = $ConfigFile.Settings.Source.DBName
$SourceTable       = $ConfigFile.Settings.Source.TableName
$SUserName         = $ConfigFile.Settings.Source.UserName
$SPassword         = $ConfigFile.Settings.Source.Password

$DestinationServer = $ConfigFile.Settings.Destination.Server
$Destdatabase      = $ConfigFile.Settings.Destination.DBName
$DestTable         = $ConfigFile.Settings.Destination.TableName

$BackupFile        = $ConfigFile.Settings.BackupFile
#$DUserName        = $ConfigFile.Settings.Destination.UserName
#$DPassword 	   = $ConfigFile.Settings.Destination.Password
$s=0 
$strtwatch = [System.Diagnostics.Stopwatch]::StartNew()

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

$sqlConnectionString = "Server = $SourceServer; Database = $Sourcedatabase; User ID=$SUserName; Password=$SPassword; Integrated Security=False"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $sqlConnectionString

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = "SELECT * FROM" +" "+$SourceTable 
$SqlCmd.Connection = $SqlConnection

$SqlCmd.Connection.Open()


"Script Started"
$SReturnValue = $SqlCmd.ExecuteNonQuery()

"Reading... Table Data from $SourceServer Server"

#[system.Data.Sqlclient.SqlDataReader] $sqlReader = $SqlCmd.ExecuteReader()

Try
{
foreach( $server in ($ConfigFile.Settings.Destination.ip))
{ 
$s=$s+1
[system.Data.Sqlclient.SqlDataReader] $sqlReader = $SqlCmd.ExecuteReader()
$DestConnectionString = "Server = $server; Database = $Destdatabase; User ID=$SUserName; Password=$SPassword;Integrated Security=False"
$DestConnection = New-Object System.Data.SqlClient.SqlConnection
$DestConnection.ConnectionString = $DestConnectionString
#-----------------Start Backup-------------------------------
<#
$BackupCmd = New-Object System.Data.SqlClient.SqlCommand
$BackupCmd.CommandText = "SELECT * FROM"+" "+$DestTable
$BackupCmd.Connection = $DestConnection
$BackupCmd.Connection.Open()
$SqlAdapter = New-object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $BackupCmd

$DataSet = New-object System.Data.DataSet
"Backup Running..."
$Numberofrows = $SqlAdapter.Fill($DataSet)
($DataSet.Tables[0] | ConvertTo-Csv -Delimiter "," -NoTypeInformation) -replace "`"", "" | `
Out-File -Force $BackupFile
"Total $Numberofrows Rows Backuped Successfully"
$BackupCmd.Connection.Close()
#>
#------------------End Backup--------------------------------
#Create the SQL Command object

$DestSqlCmd = New-Object System.Data.SqlClient.SqlCommand
$DestSqlCmd.CommandText = "TRUNCATE TABLE" +" "+$DestTable
$DestSqlCmd.Connection = $DestConnection

$DestSqlCmd.Connection.Open()

#Execute the Query
$DReturnValue = $DestSqlCmd.ExecuteNonQuery()

"for $server *****************"
"deleted data from $DestTable of $Destdatabase"
   

$bulkcopy = New-Object Data.SqlClient.SqlBulkCopy($DestConnectionString, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity) 
$bulkcopy.DestinationTableName = $DestTable
$bulkCopy.BatchSize = 50000
$bulkcopy.bulkcopyTimeout = 0 

"Table Writing..."
$bulkcopy.WriteToServer($sqlReader)

$sqlReader.Close()

$ScraperCountCmd = New-Object System.Data.SqlClient.SqlCommand
$ScraperCountCmd.CommandText = "SELECT COUNT(*) from" +" "+$SourceTable
$ScraperCountCmd.Connection = $SqlConnection
$CountRowsOnServer = $ScraperCountCmd.ExecuteScalar()

#$SqlConnection.Close()
"number of row on server is $CountRowsOnServer"



#------------------- Count No of rows Inserted On Destination Server-------

$CountCmd = New-Object System.Data.SqlClient.SqlCommand
$CountCmd.CommandText = "SELECT COUNT(*) from" +" "+$DestTable
$CountCmd.Connection = $DestConnection
$CountRowsOnDestination = $CountCmd.ExecuteScalar()
$Remaining= $CountRowsOnserver - $countRowsOnDestination
"$CountRowsOnDestination rows inserted on $server Server"
"Rows fail to write are $Remaining"

}
"Total Time taken to run script is : $($strtwatch.Elapsed.ToString())"
#---------------Success Mail alert--------------------------
if($CountRowsOnDestination -eq $CountRowsOnServer)
{
$Subject = "Regarding New Data Inserted on $DestTable Table "
$Body = "For $s Server $CountRowsOnDestination rows successfully inserted on $DestTable Table   
`n Total Time taken to run script is : $($strtwatch.Elapsed.TotalMinutes) Minutes" 
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
$smtp.Send($From, $To, $Subject, $Body);
}
#----------------------Incomplete Inserted mail alert----------
else
{
$Subject = "Regarding Incomplete Data Inserted on $DestTable Table "
$Body = "$Remaining rows fail to insertion on $DestTable Table From Scraper Server   
`n Total Time taken to run script is : $($strtwatch.Elapsed.TotalMinutes) Minutes" 
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
$smtp.Send($From, $To, $Subject, $Body);
}
}

  
Catch [System.Exception]
  {
    $ex = $_.Exception
    $message = $ex.Message
    Write-Host $message
#--------------------------Exception Mail Alert-------------------
$Subject = "Regarding fail to copy from Source to Destination server"
$Body = "Exception are as following: `n $message" 
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPHost, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($UName, $Pword);
$smtp.Send($From, $To, $Subject, $Body);
  }
  Finally
  { 
    #$SqlConnection.Close();
    #$sqlReader.Close()
    #$SqlConnection.Close()
    #$SqlConnection.Dispose()
    #$DstReader.Close()
    #$DestConnection.Close()
   
    
    #$bulkCopy.Close()
  }

  