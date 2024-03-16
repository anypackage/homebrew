@{
	RootModule = 'AnyPackage.Homebrew.psm1'
	ModuleVersion = '0.0.1'
	CompatiblePSEditions = 'Core'
	GUID = '4de67142-5a15-488f-b51f-9b28d8d16d46'
	Author = 'Ethan Bergstrom'
	Copyright = '(c) 2024 Ethan Bergstrom. All rights reserved.'
	Description = 'AnyPackage provider that facilitates installing Homebrew packages from any compatible repository.'
	PowerShellVersion = '7.0.1'
	FunctionsToExport = @()
	CmdletsToExport = @()
	AliasesToExport = @()
	RequiredModules = @(
		@{
			ModuleName = 'AnyPackage'
			ModuleVersion = '0.5.1'
		},
		@{
			ModuleName = 'Croze'
			ModuleVersion = '0.1.2'
		}
	)
	PrivateData = @{
		AnyPackage = @{
			Providers = 'Homebrew'
		}
		PSData = @{
			Tags = @('AnyPackage','Provider','Homebrew','Windows')
			LicenseUri = 'https://github.com/anypackage/Homebrew/blob/main/LICENSE'
			ProjectUri = 'https://github.com/anypackage/Homebrew'
			ReleaseNotes = 'Please see https://github.com/anypackage/Homebrew/blob/main/CHANGELOG.md for release notes'
		}
	}
    HelpInfoURI = 'https://go.anypackage.dev/help'
}
