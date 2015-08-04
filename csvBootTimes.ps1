# Copyright 2015 Justin Adams. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided
# that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and
# the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
# and the following disclaimer in the documentation and/or other materials provided with the
# distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# Parameters:
# Max: max number of events to retrieve from log.
# HostnameFile: file containing hostnames separated by newlines, to be input object for Get-Content.
# Call like: ./csvBootTimes.ps1  -Max 5  -HostnameFile hn.txt

param([Int32]$Max= 1, [String]$HostnameFile= '');

# Get at least 1 event.
if($Max -lt 1)
{
	$Max= 1;
}

# If no hostname file specified then do local computer.
if($HostnameFile -eq '')
{
	$hostnames= @($env:computername);
}

else
{
	$hostnames= Get-Content -Path $HostnameFile;
}

$cred= Get-Credential;

Write-Output """Hostname"",""BootTime"",""ErrorMessage""";

Foreach($hostname in $hostnames)
{
	try
	{
		$events= Get-WinEvent  -ComputerName $hostname  -MaxEvents $Max  -FilterHashTable @{logname='System'; id=12}  -Credential $cred  -ErrorAction Stop;

		# Outputs "Hostname","BootTime","NULL"
		Foreach($event in $events)
		{
			$tc= $event.TimeCreated
			Write-Output("""{0}"",""{1:0000}-{2:00}-{3:00} {4:00}:{5:00}:{6:00}"",""NULL""" -f ($hostname, $tc.Year, $tc.Month, $tc.Day, $tc.Hour, $tc.Minute, $tc.Second));
		}
	}

	# Outputs "Hostname","NULL","ErrorMessage"
	catch [Exception]
	{
		Write-Output("""{0}"",""NULL"",""{1}""" -f ($hostname, $_.Exception.Message -replace """",""""""));
	}
}