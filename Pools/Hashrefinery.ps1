﻿. .\Include.ps1 
 
 
 $Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $Hashrefinery_Request = [PSCustomObject]@{} 
 
 
 try { 
     $Hashrefinery_Request = Invoke-RestMethod "http://pool.hashrefinery.com/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "Sniffdog howled at ($Name) for a failed API. "
     return 
 } 
 
 
 if (($Hashrefinery_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "SniffDog sniffed near ($Name) but ($Name) Pool API had no scent. " 
     return 
 } 
 
 
 $Location = "us" 
 
 
 $Hashrefinery_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$Hashrefinery_Request.$_.hashrate -gt 0} | foreach {
    $Hashrefinery_Host = "$_.us.hashrefinery.com"
    $Hashrefinery_Port = $Hashrefinery_Request.$_.port
    $Hashrefinery_Algorithm = Get-Algorithm $Hashrefinery_Request.$_.name
    $Hashrefinery_Coins = $Hashrefinery_Request.$_.coins
    $Hashrefinery_Fees = $Hashrefinery_Request.$_.fees
    $Hashrefinery_Workers = $Hashrefinery_Request.$_.workers

    $Divisor = 1000000
	
    switch($Hashrefinery_Algorithm)
    {
        "equihash"{$Divisor /= 1000}
        "blake2s"{$Divisor *= 1000}
	    "blakecoin"{$Divisor *= 1000}
        "decred"{$Divisor *= 1000}
	    "x11"{$Divisor *= 100}
    }

    if((Get-Stat -Name "$($Name)_$($Hashrefinery_Algorithm)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($Hashrefinery_Algorithm)_Profit" -Value ([Double]$Hashrefinery_Request.$_.estimate_last24h/$Divisor*(1-($Hashrefinery_Request.$_.fees/100)))}
    else{$Stat = Set-Stat -Name "$($Name)_$($Hashrefinery_Algorithm)_Profit" -Value ([Double]$Hashrefinery_Request.$_.estimate_current/$Divisor *(1-($Hashrefinery_Request.$_.fees/100)))}
	
    if($Wallet)
    {
        [PSCustomObject]@{
            Algorithm = $Hashrefinery_Algorithm
            Info = "$Hashrefinery_Coins - Coin(s)" 
            Price = $Stat.Live
            Fees = $Hashrefinery_Fees
            Workers = $Hashrefinery_Workers
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $Hashrefinery_Host
            Port = $Hashrefinery_Port
            User = $Wallet
            User1 = $Wallet1
	        User2 = $Wallet2
	        User3 = $Wallet3
	        User4 = $Wallet4
	        User5 = $Wallet5
	        User6 = $Wallet6
		User7 = $Wallet7
            Pass = "ID=$RigName,c=$Passwordcurrency"
            Pass1 = "ID=$RigName,c=$Passwordcurrency1"
	        Pass2 = "ID=$RigName,c=$Passwordcurrency2"
	        Pass3 = "ID=$RigName,c=$Passwordcurrency3"
	        Pass4 = "ID=$RigName,c=$Passwordcurrency4"
	        Pass5 = "ID=$RigName,c=$Passwordcurrency5"
	        Pass6 = "ID=$RigName,c=$Passwordcurrency6"
            Location = $Location
            SSL = $false
        }
    }
}
