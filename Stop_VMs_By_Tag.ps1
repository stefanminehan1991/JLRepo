#Modules Check Az.Accounts,Az.Resources,Az.Storage


#AZAccounts Module

If (!(get-module -name Az.Accounts)){

import-module -name Az.Accounts}


#AZResources Module

If (!(get-module -name Az.Resources)){

import-module -name Az.Resources}


#AZCompute Module

If (!(get-module -name Az.Compute)){

import-module -name Az.Compute}

 

#Connection To Azure Using RunAsConnection

$connectionName = "AzureRunAsConnection"

try

{

    # Get the connection "AzureRunAsConnection "

 

    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

 

    "Logging in to Azure..."

    $connectionResult =  Connect-AzAccount -Tenant $servicePrincipalConnection.TenantID `

                             -ApplicationId $servicePrincipalConnection.ApplicationID   `

                             -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `

                             -ServicePrincipal

    "Logged in."

    #Add blank lines so that the console output is easier to read

    Write-Output ""

    Write-Output ""

 

}

catch {

    if (!$servicePrincipalConnection)

    {

        $ErrorMessage = "Connection $connectionName not found."

        throw $ErrorMessage

    } else{

        Write-Error -Message $_.Exception

        throw $_.Exception

    }

}

 

#Get VMs with The Required Tag/Value

$VMs = Get-AzResource -Tag @{ Test="Test" } | where {$_.ResourceType -eq "Microsoft.Compute/VirtualMachines"}

 

$VMNames = $VMs | select -ExpandProperty  Name

 

"-----------The following VMs Will be stopped-----------"

write-output $VMNames

""

 

#Loop through VMs and Stop them (graceful shutdown)

#-stayprovisioned will shutdown instead of deallocating but compute will still be charged.

Foreach ($VM in $VMs) {

Write-output "Stopping VM" $VM.Name

Stop-AZVM -Name $VM.Name -ResourceGroup $VM.ResourceGroupName -Force}

 

"Script Completed"