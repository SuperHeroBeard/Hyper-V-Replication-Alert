$status = Get-VMReplication | Select-Object Name, State, Health, Mode, FrequencySec, PrimaryServer, ReplicaServer, ReplicaPort | ConvertTo-Html
$Company = ""
$ReplicationHealth = (Get-VMReplication)
function ReplicationHealthFailedTelegram {
    $token = (Get-Content -Path C:\temp\telegrambot\token.txt)
    $chatid = (Get-Content -Path C:\temp\telegrambot\chatid.txt)
    $Message = "Replication Failed"
    $Company = ""
    $status = Get-VMReplication | Select-Object Name, State, Health, Mode, FrequencySec, PrimaryServer, ReplicaServer, ReplicaPort | ConvertTo-Html
    & 'C:\Program Files\PowerShell\7\pwsh.exe' -Command { $token = (Get-Content -Path C:\temp\telegrambot\token.txt);$chatid = (Get-Content -Path C:\temp\telegrambot\chatid.txt); $status = Get-VMReplication | Select-Object Name, State, Health, Mode, FrequencySec, PrimaryServer, ReplicaServer, ReplicaPort | ConvertTo-Html;$Message = "Replication Failed";$Company = "Howard Matthews Partnership - Harrogate";Send-TelegramTextMessage -BotToken $token -ChatID $chatid -Message $Company $Message}
    }
function EmailAlert {
    $User = "diskspace@domain.co.uk"
    $File = (Get-Content C:\Temp\pw.txt | ConvertTo-SecureString)
    $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $User, $File
    
            $To = "domain.co.uk"
            $from = "domain.co.uk"
            $EmailSubject = "Hyper-V Replication Error $Company"
            $smtp = "auth.smtp.1and1.co.uk"
            $DefaultMessage="
                <p>Dear Help,</p>
                <p>Replication has failed for $Company </p>
                <p>$status</p>
                <p>The Robot Checker .<br><br>
                </p>"
    
            $MailMessage = @{
                    To = $To
                    From = $from
                    # BCC = $Bcc
                    Subject = $EmailSubject
                    Body = $DefaultMessage
                    priority = "High"
                    Smtpserver = $smtp
                    Credential = $MyCredential
                    ErrorAction = "SilentlyContinue" 
                }
                
            Send-MailMessage @MailMessage -bodyashtml
}

if ($ReplicationHealth.health -eq "Critical" -or $ReplicationHealth.Health -eq "warning") {
    EmailAlert
    ReplicationHealthFailedTelegram
} else {
    $null
}