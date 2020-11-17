#Check the executing user is running in an elevated shell & and an admin
$RunningAsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if ($RunningAsAdmin)
    {
 
 
<######################################
## WORK HERE                         ##
######################################>
 
#Get the SQL instance we'll be working with
$SQLInstance = read-host "Enter the SQL instance to configure"
 
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
 
 
 
#########################################
### ENABLE TCP/IP & LISTENING ON 1433 ###
#########################################
$captionTCP = "Question!"
$messageTCP = "Enable TCP/IP and set SQL to listen on port 1433 on SQL instance: $SQLInstance ?"
$resultTCP = $Host.UI.PromptForChoice($captionTCP,$messageTCP,$choices,0)
#If yes prompt for confirmation then make the changes
if($resultTCP -eq 0)
    {
    Try
        {
 
$SQLInstance = $SQLInstance.ToUpper()
 
if ($SQLInstance -ilike "**") 
    {
    $string = $SQLInstance.Split("")
    $SQLName = $string[0]
    $Instance = $string[1]
    }
else
    {
    $SQLName = $SQLInstance
    $Instance = "MSSQLSERVER"
    }
 
 
$SQLName
$Instance
 
# Load SMO Wmi.ManagedComputer assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null
 
Trap {
  $err = $_.Exception
  while ( $err.InnerException )
    {
    $err = $err.InnerException
    write-output $err.Message
    };
    continue
  }
  
# Connect to the instance using SMO
$m = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') $SQLName
 
 
$urn = "ManagedComputer[@Name='$SQLName']/ServerInstance[@Name='$Instance']/ServerProtocol[@Name='Tcp']"
$Tcp = $m.GetSmoObject($urn)
$Enabled = $Tcp.IsEnabled
 
#Enable TCP/IP if not enabled
IF (!$Enabled)
    {$Tcp.IsEnabled = $true }
 
#Set to listen on 1433
$m.GetSmoObject($urn + "/IPAddress[@Name='IPAll']").IPAddressProperties[1].Value = "1433"
$TCP.alter()
 
        "Success: SQL set to listen on TCP/IP port 1433. Please restart the SQL service for changes to take effect."
        }
    Catch { Write-Warning "Unable to enable TCP/IP & set SQL to listen on port 1433" }
     } 
else { Write-Warning "TCP/IP changes cancelled" }
    
    
    }
    
    else { Write-Warning "This script must be executed by an administrator in an elevated shell" }
 
 
 