<#
.Synopsis
   Allows listing, finding and uninstalling most software on Windows
.DESCRIPTION
  Allows listing, finding and uninstalling most software on Windows.
INPUTS
  -list Will list all installed 32-bit and 64-bit software installed on the target machine.
  -find "<software name>" will find a particular application installed giving you the uninstall string
  -find "<software name>" -u "<uninstall string>" will allow you to uninstall the software from the Windows machine silently
.NOTES
  Follow the steps below via script arguments to find and then uninstall the software.
  Step 1: -find "vlc"
  Step 2: -find "vlc" -u "C:\Program Files\VideoLAN\VLC\uninstall.exe"
  Step 3: Will get result back stating if it has been uninstalled or not.
#>

[CmdletBinding()]
param(
    [switch]$list,
    [string]$find,
    [string]$u,
    [string]$arguments,
    [switch]$noextraargs

)

$Paths = @("HKLM:\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\*", "HKLM:\SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\*", "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*")

$null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS

If ($list -And !($find) -And !($u) -And !($exeargs)) {
    
    
    $ResultCount = (Get-ItemProperty $Paths | Where-Object {$_.UninstallString -notlike ""} | Measure-Object).Count
    Write-Output "$($ResultCount) results `r"
    Write-Output "*********** `n"

    foreach ($app in Get-ItemProperty $Paths | Where-Object {$_.UninstallString -notlike ""} | Sort-Object DisplayName){
        
        if ($app.UninstallString){

            Write-Output "Name: $($app.DisplayName)"
            Write-Output "Version: $($app.DisplayVersion)"
            Write-Output "Uninstall String: $($app.UninstallString)"
            Write-Output "`r"

        }else{
            
        }
        
    }
    
    
}

If($find -And !($u)){

    $FindResults = (Get-ItemProperty $Paths | Where-object { $_.Displayname -match [regex]::Escape($find)} | Measure-Object).Count
    Write-Output "$($FindResults) results"
    Get-ItemProperty $Paths |  Where-object { $_.Displayname -match [regex]::Escape($find)} | Sort-Object DisplayName | Select-Object DisplayName, DisplayVersion, UninstallString | Format-List

}

##################################
#uninstall code 32-bit and 64-bit
#################################
If ($find -And $u -Or $u -And !($list)) {

$AppName = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName

    If ($u -Match [regex]::Escape("MsiExec")) {

        $MsiArguments = $u -Replace "MsiExec.exe /I", "/X" -Replace "MsiExec.exe ", ""
        Start-Process -FilePath msiexec.exe -ArgumentList "$MsiArguments /quiet /norestart" -Wait
                $UninstallTest = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName
                If($UninstallTest){
                    
                    Write-Output "$($AppName) has not been uninstalled"

                }else{

                Write-Output "$($AppName) has been uninstalled"
                }

    }
    else {
        If (Test-Path -Path "$u" -PathType Leaf) {
            If ($arguments) {

                $exearguments = $arguments + ' ' + "/S /SILENT /VERYSILENT /NORESTART"
                Start-Process -Filepath "$u" -ArgumentList $exearguments -Wait
                $UninstallTest = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName
                If($UninstallTest){
                    
                    Write-Output "$($AppName) has not been uninstalled"

                }else{

                Write-Output "$($AppName) has been uninstalled"
                }
            }
            else {

                $exearguments = "/S /SILENT /VERYSILENT /NORESTART"
                Start-Process -Filepath "$u" -ArgumentList $exearguments -Wait
                $UninstallTest = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName
                If($UninstallTest){
                    
                    Write-Output "$($AppName) has not been uninstalled"

                }else{

                Write-Output "$($AppName) has been uninstalled"
                }

            }

        }
        else {

            Write-Output "The path '$($u)' does not exist."

        }
    }

}

If ($list -And $u){

$AppName = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName

    If ($u -Match [regex]::Escape("MsiExec")) {

        $MsiArguments = $u -Replace "MsiExec.exe /I", "/X" -Replace "MsiExec.exe ", ""
        Start-Process -FilePath msiexec.exe -ArgumentList "$MsiArguments /quiet /norestart" -Wait
                $UninstallTest = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName
                If($UninstallTest){
                    
                    Write-Output "$($AppName) has not been uninstalled"

                }else{

                Write-Output "$($AppName) has been uninstalled"
                }

    }
    else {
        If (Test-Path -Path "$u" -PathType Leaf) {
            If ($arguments) {

                $exearguments = $arguments + ' ' + "/S /SILENT /VERYSILENT /NORESTART"
                Start-Process -Filepath "$u" -ArgumentList $exearguments -Wait
                $UninstallTest = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName
                If($UninstallTest){
                    
                    Write-Output "$($AppName) has not been uninstalled"

                }else{

                Write-Output "$($AppName) has been uninstalled"
                }
            }
            else {

                $exearguments = "/S /SILENT /VERYSILENT /NORESTART"
                Start-Process -Filepath "$u" -ArgumentList $exearguments -Wait
                $UninstallTest = (Get-ItemProperty $Paths | Where-object { $_.UninstallString -match [regex]::Escape($u)}).DisplayName
                If($UninstallTest){
                    
                    Write-Output "$($AppName) has not been uninstalled"

                }else{

                Write-Output "$($AppName) has been uninstalled"
                }

            }

        }
        else {

            Write-Output "The path '$($u)' does not exist."

        }
    }

}
