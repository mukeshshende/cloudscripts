# --------------------------------------------------------------------------------------------------------------
# Script    :   Test-AzureADUserRoleAndGroup
# Note      :   Get User's Memberships to Azure Active Directory Roles and Groups
# Author    :   Mukesh Shende
# Email     :   shendemukesh@hotmail.com
# Comment   :   You have a royalty-free right to use, modify, reproduce, and 
#               distribute this script file in any way you find useful, provided that 
#               you agree that the creator, owner above has no warranty, obligations, or liability for such use.
# Date      :   26 Dec 2016
# Version   :   1.0 - Initial Release
# --------------------------------------------------------------------------------------------------------------

<#
.Synopsis
   Get User's Memberships to Azure Active Directory Roles and Groups
.DESCRIPTION
   Using Azure Active Directory PowerShell Version 2 modules you can find out the user's role and group membership details.
.EXAMPLE
    PS C:\> 'mukesh' | Get-AzureADUserRoleAndGroup
    UserName User ID                              Role Name             Group Name
    -------- -------                              ---------             ----------
    mukesh   7xxxxxxx-axxx-4xxx-9xxx-1xxxxxxxxxxx Company Administrator {XxDemoAdmins, XxDemoUsers}

    This will look for user with display name like mukesh and returns the output with his role and groups he is member of.
.EXAMPLE
    PS C:\> 'mukesh','demo' | Get-AzureADUserRoleAndGroup
    UserName User ID                              Role Name             Group Name
    -------- -------                              ---------             ----------
    mukesh   7xxxxxxx-axxx-4xxx-9xxx-1xxxxxxxxxxx Company Administrator {XxDemoAdmins, XxDemoUsers}
    demo     2yyyyyyy-cyyy-4yyy-ayyy-0yyyyyyyyyyy User Account Administrator {XxDemoAdmins, XxDemoUsers}
   
    This will look for 2 users with display name like mukesh & demo and returns the output with their role and groups he is member of.
.NOTES
    Please ensure you are logged in with apprproate access on Azure AD. 
    Provide user name to search for. The Get-AzureADUser commands looks for given user name in Display Name field.
    Get-AzureADUserMembership and Get-AzureADDirectoryRole currently works with only with object ids and return the object ids for user accounts. 
    This script will help get the actual names for roles, groups and user accounts with their IDs.
#>
Function Test-AzureADUserRoleAndGroup {
    param (
    [Parameter(Mandatory=$true)]
    $UserName
    )
    $aad_User = Get-AzureADUser -SearchString $UserName
    if(!$aad_User){
        Write-Host "I am sorry, i can't find a user name $UserName. Are you sure its the correct user name?" -ForegroundColor Red
    } else {
        $aad_UserRolesAndGroups = Get-AzureADUserMembership -ObjectId $aad_User.ObjectId | Group-Object -Property ObjectType -AsHashTable
        $Roles = $aad_UserRolesAndGroups.Role | % { Get-AzureADDirectoryRole -ObjectId $_.ObjectId }
        $Groups = $aad_UserRolesAndGroups.Group | % { Get-AzureADGroup -ObjectId $_.ObjectId }
                 
        $obj = New-Object -TypeName psobject
        $obj | Add-Member -MemberType NoteProperty -Name UserName -Value $UserName
        $obj | Add-Member -MemberType NoteProperty -Name 'User ID' -Value $aad_User.ObjectId
        $obj | Add-Member -MemberType NoteProperty -Name 'Role Name' -Value $Roles.DisplayName
        $obj | Add-Member -MemberType NoteProperty -Name 'Group Name' -Value $($Groups | % {$_.DisplayName})
        
        Write-Output $obj
    }
}

Function Get-AzureADUserRoleAndGroup(){
    BEGIN{}
    PROCESS{ Test-AzureADUserRoleAndGroup -UserName $_ }
    END{}
}

# 'mukesh' | Get-AzureADUserRoleAndGroup
# 'smdemoadmin' | Get-AzureADUserRoleAndGroup

# Tip - show all user accounts that have been previously deleted.
# Get-MsolUser -ReturnDeletedUsers | foreach {$PSItem | fl * -Force}
