<#
.SYNOPSIS
Download Cloud Management Tools (Windows Platform) For Azure and AWS.
.DESCRIPTION 
This script downloads multiple tools available for Windows Platform to manage cloud deployments on Azure and AWS cloud.
TESTED ON: Windows 10 (PSVersion 5.1), Windows Server 2012 R2 (4.0)
Should work on Windows Server 2016
.OUTPUTS
Following Files will be Downloaded in the Downloads directory of current logged in User Account.
- Azure-PowerShell.msi
- StorageExplorer.exe
- MicrosoftAzureStorageTools.msi
- Azure-cli.msi
- MicrosoftAzureStorageEmulator.msi
- AWSToolsAndSDKForNet.msi
.EXAMPLE
.\Get-CloudManagementToolsWithBITS.ps1
.LINK
http://mukeshnotes.wordpress.com/
.NOTES
* Written by  : Mukesh Shende
    * Email     :   shendemukesh@hotmail.com
    * Website   :	http://mukeshnotes.wordpress.com/
    * Twitter   :	https://twitter.com/mukeshshende
    * LinkedIn  :	http://in.linkedin.com/in/mukeshshende/
* Change Log :
v1.00, 15/01/2017 - Initial version - Get-CloudManagementTools.ps1 with Invoke-WebRequest cmdlet.
v1.01, 16/01/2017 - Updated to use with BitsTransfer Module and handle redirected URLs
#>

# The folder location where the downloads will be saved
$DestinationFolder = "$ENV:homedrive$env:homepath\Downloads\CloudTools"
If (!(Test-Path $DestinationFolder)){
    New-Item $DestinationFolder -ItemType Directory -Force
}

# Specify download url's for various cloud management tools. Do not change unless Microsoft changes the downloads themselves in future
$Downloads = @{
            # Latest Azure PowerShell
            # Github: https://github.com/Azure/azure-powershell/releases/latest
            # WebPI: https://www.microsoft.com/web/handlers/webpi.ashx/getinstaller/WindowsAzurePowershellGet.3f.3f.3fnew.appids
            "https://aka.ms/azure-powershellget2" = "$DestinationFolder\Azure-PowerShell.msi"; 
            # Latest Azure Storage Explorer
            "https://go.microsoft.com/fwlink/?LinkId=708343" = "$DestinationFolder\StorageExplorer.exe";
            # Latest AZCopy
            "http://aka.ms/downloadazcopy" = "$DestinationFolder\MicrosoftAzureStorageTools.msi";
            # Latest Azure CLI
            "http://aka.ms/webpi-azure-cli" = "$DestinationFolder\Azure-cli.msi";
            # Azure Storage Emulator
            "https://go.microsoft.com/fwlink/?LinkId=717179&clcid=0x409" = "$DestinationFolder\MicrosoftAzureStorageEmulator.msi";
            # Latest AWS Tools For Windows PowerShell
            "http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi" = "$DestinationFolder\AWSToolsAndSDKForNet.msi";
            } 

# This function gets the end URL to avoid redirection in URL breaking the Start-BitsTransfer
# Courtesy: http://www.powershellmagazine.com/2013/01/29/pstip-retrieve-a-redirected-url/
Function Get-RedirectedUrl {
    Param (
    [Parameter(Mandatory=$true)]
    [String]$url
    )
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$true
    try{
        $response=$request.GetResponse()
        $response.ResponseUri.AbsoluteUri
        $response.Close()
    }
    catch{
        “ERROR: $_”
    }
}

# Import Required Modules: BITS is used for file transfer
Import-Module BitsTransfer 

function DownloadFiles(){ 
    Write-Host ""
    Write-Host "====================================================================="
    Write-Host "             Downloading Cloud Management Tools for Azure & AWS" 
    Write-Host "====================================================================="
    
    $ReturnCode = 0 

    $Downloads.GetEnumerator() | ForEach-Object { 
        $DownloadURL = Get-RedirectedUrl -URL $_.get_key()
        $Filespec = $_.get_value()
        # Get the file name based on the portion of the file path after the last slash 
        $FilePath = Split-Path $Filespec
        $FileName = Split-Path $Filespec -Leaf
        Write-Host "DOWNLOADING: $FileName"
        Write-Host "       FROM: $DownloadURL"
        Write-Host "         TO: $FilePath"
        
        Try 
        { 
            # Check if file already exists 
            If (!(Test-Path "$Filespec")) 
            { 
                # Begin download 
                Start-BitsTransfer -Source $DownloadURL -Destination "$Filespec" -DisplayName "Downloading `'$FileName`' to $FilePath" -Priority High -Description "From $DownloadURL..." -ErrorVariable err 
                If ($err) {Throw ""} 
                Write-Host "     STATUS: Downloaded"
                Write-Host
            } 
            Else 
            { 
                Write-Host "     STATUS: Already exists. Skipping." 
                Write-Host
            } 
        } 
        Catch 
        { 
            $ReturnCode = -1
            Write-Warning " AN ERROR OCCURRED DOWNLOADING `'$FileName`'" 
            Write-Error   $_
            Break 
        } 

    } 
    return $ReturnCode 
}

$rc = DownloadFiles 

if($rc -ne -1)
{
    Write-Host ""
    Write-Host "DOWNLOADS ARE COMPLETE."
}
