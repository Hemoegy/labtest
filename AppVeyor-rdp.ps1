Start-Service -Name audiosrv
Set-LocalUser -Name "Administrator" -Password (ConvertTo-SecureString -AsPlainText "P@ssw0rd!" -Force)
function ChangePassword($password) {
  $objUser = [ADSI]("WinNT://$($env:computername)/appveyor")
  $objUser.SetPassword($password)
  $objUser.CommitChanges()
}

function SleepIfBeforeClone() {
  if (!(Get-ItemProperty 'HKLM:\SOFTWARE\Appveyor\Build Agent\State' -Name GetSources -ErrorAction Ignore).GetSources -eq "true") {
  sleep 30
  }   
}

if((Test-Path variable:islinux) -and $isLinux) {
  Write-Warning "RDP access is not supported on Linux. Please use SSH (https://www.appveyor.com/docs/how-to/ssh-to-build-worker/)."
  return
}

# get current IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like 'ethernet*'}).IPAddress
$port = 3389

if (-not $nonat) {
    if($ip.StartsWith('172.24.')) {
        $port = 33800 + ($ip.split('.')[2] - 16) * 256 + $ip.split('.')[3]
    } elseif ($ip.StartsWith('192.168.') -or $ip.StartsWith('10.240.')) {
        # new environment - behind NAT
        $port = 33800 + ($ip.split('.')[2] - 0) * 256 + $ip.split('.')[3]
    } elseif ($ip.StartsWith('10.0.')) {
        $port = 33800 + ($ip.split('.')[2] - 0) * 256 + $ip.split('.')[3]
    }
}

# get external IP
$ip = (New-Object Net.WebClient).DownloadString('https://www.appveyor.com/tools/my-ip.aspx').Trim()

# allow RDP on firewall
Enable-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-in)'

Write-Host "Remote Desktop connection details:" -ForegroundColor Yellow
Write-Host "  Server: $ip`:$port" -ForegroundColor Gray
Write-Host "  Username: Administrator" -ForegroundColor Gray
if(-not $env:appveyor_rdp_password) {
    Write-Host "  Password: P@ssw0rd!" -ForegroundColor Gray
}

if($blockRdp) {
    $path = "$($env:USERPROFILE)\Desktop\Delete me to continue build.txt"
    # create "lock" file.
    Set-Content -Path $path -Value ''    
    Write-Warning "Subscribe: https://www.youtube.com/channel/UCi80Ipndm3QovIn5XisUz3g"
    # wait until "lock" file is deleted by user.
    while(Test-Path $path) {
      Start-Sleep -Seconds 1
    }
    Write-Host "Build lock file has been deleted. Resuming build."
}
