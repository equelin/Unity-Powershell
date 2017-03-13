<#	.Description
	Set PowerShell title bar to reflect currently connected Unity servers' names
#>
function Update-TitleBarForUnityConnection {
	$strOrigWindowTitle = $host.ui.RawUI.WindowTitle
	## the window titlebar text without the "connected to.." Unity info
	$strWinTitleWithoutOldUnityConnInfo = $strOrigWindowTitle -replace "(; )?Connected to( \d+)? Unity.+", ""
	## the number of Unity servers to which still connected
	$intNumConnectedUnityServers = ($Global:DefaultUnitySession | Measure-Object).Count
	$strNewWindowTitle = "{0}{1}{2}" -f $strWinTitleWithoutOldUnityConnInfo, $(if ((-not [System.String]::IsNullOrEmpty($strWinTitleWithoutOldUnityConnInfo)) -and ($intNumConnectedUnityServers -gt 0)) {"; "}), $(
		if ($intNumConnectedUnityServers -gt 0) {
			if ($intNumConnectedUnityServers -eq 1) {"Connected to Unity {0} as {1}" -f $Global:DefaultUnitySession[0].Server, $Global:DefaultUnitySession[0].User}
			else {"Connected to {0} Unity servers:  {1}." -f $intNumConnectedUnityServers, (($Global:DefaultUnitySession | Foreach-Object {$_.Server}) -Join ", ")}
		} ## end if
		#else {"Not Connected to Unity"}
	) ## end -f call
	$host.ui.RawUI.WindowTitle = $strNewWindowTitle
} ## end fn
