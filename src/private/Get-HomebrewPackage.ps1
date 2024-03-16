function Get-HomebrewPackage {
	param (
		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	# Filter results by any name and version requirements
	# We apply additional package name filtering when using wildcards to make Homebrew's wildcard behavior more PowerShell-esque
	(Croze\Get-HomebrewPackage -Cask) + (Croze\Get-HomebrewPackage -Formula) |
		Where-Object {$Request.IsMatch($_.Name)} |
			Where-Object {-Not $Request.Version -Or ($_.Version -And $Request.Version.Satisfies($_.Version))} |
				Croze\Get-HomebrewPackageInfo
}
