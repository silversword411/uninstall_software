<#
.Synopsis
   Allows listing, finding and uninstalling most software on Windows. There will be a best effort to uninstall silently if the silent
  uninstall string is not provided.
.DESCRIPTION
  Allows listing, finding and uninstalling most software on Windows. There will be a best effort to uninstall silently if the silent
  uninstall string is not provided.
.INPUTS

The following script arguments are available:
         -help                   What you are reading now
         -list                   Show all installed software
         -name                   Filter installed software by specified name
         -id                     Filter installed software by ID
         -uninstall              Uninstall a specific software based on ID

Examples:
         -list
         -list Microsoft
         -list -name 'Tactical RMM Agent'
         -list -name 'Tactical RMM Agent' -id '{0D34D278-5FAF-4159-A4A0-4E2D2C08139D}_is1'
         -list -name 'Tactical RMM Agent' -id '{0D34D278-5FAF-4159-A4A0-4E2D2C08139D}_is1' -uninstall
  .NOTES
  See https://github.com/subzdev/uninstall_software/blob/main/uninstall_software.ps1 . If you have extra additions please feel free to contribute and create PR
  v2.0 - 8/27/2021
#>

[CmdletBinding()]
param(
    [switch]$help,
    [switch]$list,
    [string]$name,
    [string]$id,
    [switch]$uninstall 
)

$Paths = @("HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\\Wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\*")

$ApplicationsObj = New-Object System.Collections.ArrayList

$Applications = ForEach ($Application in Get-ItemProperty $Paths | Sort-Object DisplayName) {
    If ($Application.UninstallString -Or $Application.QuietUninstallString) {
        Write-Output $Application
        
    }
}

Function GetApplications {
    for ($i = 0; $i -le $Applications.Count - 1; $i++) {
        $UninstallString = If ($Applications.QuietUninstallString[$i]) { $Applications.QuietUninstallString[$i] } Else { $Applications.UninstallString[$i] }
        $Version = If ($Applications.DisplayVersion[$i]) { $Applications.DisplayVersion[$i] } Else { "Unknown" }
        $ResultObject = [PSCustomObject] @{
            'Name'            = $Applications.DisplayName[$i]
            'ID'              = $Applications.PSChildName[$i]
            'Version'         = $Version
            'UninstallString' = $UninstallString
        }
        $ApplicationsObj.Add($ResultObject) | Out-Null
    }
}

Function Uninstall($Name, $ID, $Version, $UninstallString) {
    Write-Output "Found $($Name) [$($ID)]"

    If ($UninstallString -Match "msi") {
        $Arguments = $UninstallString -Replace "MsiExec.exe /I", "/X" -Replace "MsiExec.exe ", ""
        Write-Output "Attempting software uninstall..."
        Write-Output "`r"
        $proc = Start-Process msiexec.exe -ArgumentList "$Arguments /quiet /norestart" -PassThru
        Wait-Process -InputObject $proc
        If ($proc.ExitCode -ne 0) {
            Write-Warning "$($Name) was not uninstalled, exited with error code $($proc.ExitCode)."
            Write-Output "`r"
            
        }
        Else {
            Write-Output "$($Name) was uninstalled successfully, exited with error code $($proc.ExitCode)."
            Write-Output "`r"        
        }

    }
    ElseIf ($UninstallString -NotMatch "msi" -And $UninstallString -Match '"') {
        $UninstallArguments = $UninstallString -Split ('"')
        $Path = $UninstallArguments[1].Trim()
        Write-Output "Attempting software uninstall..."
        Write-Output "`r"
        $proc = Start-Process -Filepath $Path -ArgumentList "/S /SILENT /VERYSILENT /NORESTART" -PassThru
        Wait-Process -InputObject $proc

        If ($proc.ExitCode -ne 0) {
            Write-Warning "$($Name) was not uninstalled, exited with error code $($proc.ExitCode)."
            Write-Output "`r"
    
        }
        Else {
            Write-Output "$($Name) was uninstalled successfully, exited with error code $($proc.ExitCode)."
            Write-Output "`r"        
        }

    }
    ElseIf ($UninstallString -NotMatch '"') {
        $UninstallArguments = $UninstallString -Split ("/")
        $Path = $UninstallArguments[0]
        $Arguments = "/" + $UninstallArguments[1] + "/S /SILENT /VERYSILENT /NORESTART"
        Write-Output "Attempting software uninstall..."
        Write-Output "`r"
        $proc = Start-Process -Filepath $Path -ArgumentList $Arguments -PassThru
        Wait-Process -InputObject $proc

        If ($proc.ExitCode -ne 0) {
            Write-Warning "$($Name) was not uninstalled, exited with error code $($proc.ExitCode)."
            Write-Output "`r"
    
        }
        Else {
            Write-Output "$($Name) was uninstalled successfully, exited with error code $($proc.ExitCode)."
            Write-Output "`r"        
        }
        
    }
    Else {
        Write-Output "You will have to manually uninstall."
    }

}

GetApplications

If ($list -And !$help -And !$name -And !$id -And !$uninstall) {
    
    ForEach ($App in $ApplicationsObj) {
        If ($App.Name -iMatch $name) {
            $AppDetails = [PSCustomObject] @{
                'Name'    = If ($App.Name.Length -gt 64) { $App.Name.SubString(0, [System.Math]::Min(64, $App.Name.Length)) + "..." }Else { $App.Name }
                'ID'      = $App.ID
                'Version' = $App.Version

            }

            Write-Output $AppDetails
        }
    }
}

If ($list -And $name -And !$help -And !$id -And !$uninstall) {
    ForEach ($App in $ApplicationsObj) {
        If ($App.Name -Match $name) {
            $AppDetails = [PSCustomObject] @{
                'Name'    = If ($App.Name.Length -gt 64) { $App.Name.SubString(0, [System.Math]::Min(64, $App.Name.Length)) + "..." }Else { $App.Name }
                'ID'      = $App.ID
                'Version' = $App.Version
            }

            Write-Output $AppDetails
        }
    }
    
    #Write-Output "in name"

}

If ($list -And $id -And !$help -And !$name -And !$uninstall -Or $list -And $name -And $id -And !$uninstall) {
    ForEach ($App in $ApplicationsObj) {
        If ($App.ID -eq $id) {
            $AppDetails = [PSCustomObject] @{
                'Name'            = If ($App.Name.Length -gt 64) { $App.Name.SubString(0, [System.Math]::Min(64, $App.Name.Length)) + "..." }Else { $App.Name }
                'ID'              = $App.ID
                'Version'         = $App.Version
                'UninstallString' = $App.UninstallString
            }

            Write-Output $AppDetails | Format-List
        }
        
    }
    
    #Write-Output "in id"

}

If ($list -And $name -And $uninstall -And !$help -Or $list -And $id -And $uninstall -And !$help) {
    ForEach ($App in $ApplicationsObj) {
        If ($App.ID -eq $id) {
            $AppDetails = [PSCustomObject] @{
                'Name'            = If ($App.Name.Length -gt 64) { $App.Name.SubString(0, [System.Math]::Min(64, $App.Name.Length)) + "..." }Else { $App.Name }
                'ID'              = $App.ID
                'Version'         = $App.Version
                'UninstallString' = $App.UninstallString
            }

            #Write-Output $AppDetails | Format-List
        }
        
    }

    Uninstall $AppDetails.Name $AppDetails.ID $AppDetails.Version $AppDetails.UninstallString
    #write-output "in uninstall"
}

If (!$list -And !$name -And $help) {
    Write-Output "`r"
    Write-Output "The following script arguments are available:"
    Write-Output "`t -list `t `t `t Show all installed software"
    Write-Output "`t -name `t `t `t Filter installed software by specified name"
    Write-Output "`t -id `t `t `t Filter installed software by ID"
    Write-Output "`t -uninstall `t `t Uninstall a specific software based on ID"
    Write-Output "`r"
    Write-Output "Examples:"
    Write-Output "`t -list"
    Write-Output "`t -list Microsoft"
    Write-Output "`t -list -name 'Tactical RMM Agent'"
    Write-Output "`t -list -name 'Tactical RMM Agent' -id '{0D34D278-5FAF-4159-A4A0-4E2D2C08139D}_is1'"
    Write-Output "`t -list -name 'Tactical RMM Agent' -id '{0D34D278-5FAF-4159-A4A0-4E2D2C08139D}_is1' -uninstall"
    Write-Output "`r"
    Write-Output "`r"
}
