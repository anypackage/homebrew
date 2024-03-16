function Find-HomebrewPackage {
	param (
		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	$DefaultPackageSource = 'homebrew/cask'

	[array]$RegisteredPackageSources = Get-HomebrewTap

	$selectedSource = $(
		if ($Request.Source) {
			# Finding the matched package sources from the registered ones
			if ($RegisteredPackageSources.Name -eq $Request.Source) {
				# Found the matched registered source
				$Request.Source
			} else {
				throw 'The specified source is not registered with the package provider.'
			}
		} else {
			# User did not specify a source. Now what?
			if ($RegisteredPackageSources.Count -eq 1) {
				# If no source name is specified and only one source is available, use that source
				$RegisteredPackageSources[0].Name
			} elseif ($RegisteredPackageSources.Name -eq $DefaultPackageSource) {
				# If multiple sources are avaiable but none specified, use the default package source if present
				$DefaultPackageSource
			} else {
				# If the default assumed source is not present and no source specified, we can't guess what the user wants - throw an exception
				throw 'Multiple non-default sources are defined, but no source was specified. Source could not be determined.'
			}
		}
	)

	# Filter results by any name and version requirements
	((Croze\Find-HomebrewPackage -Name "$selectedSource/$($Request.Name)" -Cask -ErrorAction SilentlyContinue) ?? (Croze\Find-HomebrewPackage -Name "$selectedSource/$($Request.Name)" -Formula -ErrorAction SilentlyContinue)) |
		Where-Object {$_.Name -And $Request.IsMatch($_.Name)} | Croze\Get-HomebrewPackageInfo |
			Where-Object {-Not $Request.Version -Or $Request.Version.Satisfies($_.Version ?? $_.Versions.Stable)} | Select-Object -Property (
				@{
					Name = 'Name'
					Expression = {$_.Token ?? $_.Name}
				},@{
					Name = 'Version'
					Expression = {$_.Version ?? $_.Versions.Stable}
				},@{
					Name = 'Tap'
					Expression = {$_.Tap}
				},@{
					Name = 'Cask'
					Expression = {$_.Cask}
				},@{
					Name = 'Formula'
					Expression = {$_.Formula}
				}
			)
}
