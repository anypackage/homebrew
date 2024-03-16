function Write-Package {
	param (
		[Parameter(ValueFromPipeline)]
		[object[]]
		$InputObject,

		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	begin {
		$sources = Get-HomebrewTap | Croze\Get-HomebrewTapInfo
	}

	process {
		foreach ($package in $InputObject) {
			$name = $package.Token ?? $package.Name
			if ($name) {
				$writePackage = $(
					$version = $_.Version ?? $_.Versions.Stable
					if ($package.Tap) {
						# If source information is provided, construct a source object for inclusion in the results
						$source = $sources | Where-Object Name -EQ $package.Tap
						$location = ($source.Remote ?? $source.Path)
						$source = [PackageSourceInfo]::new($package.Tap, $location, $true, $Request.ProviderInfo)
						[PackageInfo]::new($name, $version, $source, $Request.ProviderInfo)
					} else {
						[PackageInfo]::new($name, $version, $Request.ProviderInfo)
					}
				)

				$Request.WritePackage($writePackage)
			}
		}
	}
}