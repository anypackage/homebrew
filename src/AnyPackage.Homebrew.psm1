using module AnyPackage
using namespace AnyPackage.Provider

# Current script path
[string]$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Definition -Parent

# Dot sourcing private script files
Get-ChildItem $ScriptPath/private -Recurse -Filter '*.ps1' -File | ForEach-Object {
	. $_.FullName
}

[PackageProvider("Homebrew")]
class HomebrewProvider : PackageProvider, IGetSource, ISetSource, IGetPackage, IFindPackage, IInstallPackage, IUninstallPackage {
	[void] GetSource([SourceRequest] $Request) {
		Get-HomebrewTap | Where-Object {$_.Name -Like $Request.Name} | Croze\Get-HomebrewTapInfo | ForEach-Object {
			$source = [PackageSourceInfo]::new($_.Name, ($_.Remote ?? $_.Path), $true, $this.ProviderInfo)
			$Request.WriteSource($source)
		}
	}

	[void] RegisterSource([SourceRequest] $Request) {
		Croze\Register-HomebrewTap -Name $Request.Name -Location $Request.Location
		# Homebrew doesn't return anything after source operations, so we make up our own output object
		$source = [PackageSourceInfo]::new($Request.Name, $Request.Location.TrimEnd("\"), $Request.Trusted, $this.ProviderInfo)
		$Request.WriteSource($source)
	}

	[void] UnregisterSource([SourceRequest] $Request) {
		Get-HomebrewTap | Where-Object {$_.Name -Like $Request.Name} | Get-HomebrewTapInfo | ForEach-Object {
			Croze\Unregister-HomebrewTap -Name $_.Name
			$sourceInfo = [PackageSourceInfo]::new($_.Name, ($_.Remote ?? $_.Path), $this.ProviderInfo)
			$Request.WriteSource($sourceInfo)
		}
	}

	[void] SetSource([SourceRequest] $Request) {
		$this.RegisterSource($Request)
	}

	[void] GetPackage([PackageRequest] $Request) {
		Get-HomebrewPackage | Write-Package
	}

	[void] FindPackage([PackageRequest] $Request) {
		Find-HomebrewPackage | Write-Package
	}

	[void] InstallPackage([PackageRequest] $Request) {
		# Run the package request first through Find-HomebrewPackage to determine which source to use, and filter by any version requirements
		$package = Find-HomebrewPackage

		$installArgs = @{
			Name = "$($package.Tap)/$($package.Name)"
		}

		switch ($package) {
			{$_.Cask} {$installArgs.Cask = $true}
			{$_.Formula} {$installArgs.Formula = $true}
		}

		Croze\Install-HomebrewPackage @installArgs | Croze\Get-HomebrewPackageInfo | Write-Package
	}

	[void] UninstallPackage([PackageRequest] $Request) {
		# Run the package request first through Get-HomebrewPackage to filter by any version requirements and save it off for later use
		$package = Get-HomebrewPackage

		$uninstallArgs = @{
			Name = $package.Token ?? $package.Name
		}

		switch ($package) {
			{$_.Cask} {$uninstallArgs.Cask = $true}
			{$_.Formula} {$uninstallArgs.Formula = $true}
		}

		Croze\Uninstall-HomebrewPackage @uninstallArgs

		# Homebrew doesn't return any output on successful uninstallation, so we have to make up a new object to satisfy AnyPackage
		Write-Package $package
	}
}

[guid] $id = '4de67142-5a15-488f-b51f-9b28d8d16d46'
[PackageProviderManager]::RegisterProvider($id, [HomebrewProvider], $MyInvocation.MyCommand.ScriptBlock.Module)
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { [PackageProviderManager]::UnregisterProvider($id) }
