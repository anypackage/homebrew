[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='PSSA does not understand Pester scopes well')]
param()

BeforeAll {
	$AnyPackageProvider = 'AnyPackage.Homebrew'
	$providerShortName = $AnyPackageProvider.Split('.')[1]
	Import-Module $AnyPackageProvider -Force
}

Describe 'basic package search operations' {
	Context 'formula' {
		BeforeAll {
			$package = 'apng2gif'
			$source = 'homebrew/core'
		}
		It 'searches for the latest version of a package' {
			Find-Package -Name $package -Source $source | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
		}
		It 'searches for the latest version of a package' {
			Find-Package -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'DSC-compliant package installation and uninstallation' {
	Context 'formula' {
		BeforeAll {
			$package = 'apng2gif'
			$source = 'homebrew/core'
		}

		It 'searches for the latest version of a package' {
			Find-Package -Name $package -Source $source | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently installs the latest version of a package' {
			Install-Package -Name $package -Source $source -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds the locally installed package just installed' {
			Get-Package -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently uninstalls the locally installed package just installed' {
			Uninstall-Package -Name $package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
		}

		It 'searches for the latest version of a package' {
			Find-Package -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently installs the latest version of a package' {
			Install-Package -Name $package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds the locally installed package just installed' {
			Get-Package -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'silently uninstalls the locally installed package just installed' {
			Uninstall-Package -Name $package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'pipeline-based package installation and uninstallation' {
	Context 'formula' {
		BeforeAll {
			$package = 'apng2gif'
			$source = 'homebrew/core'
		}

		It 'searches for and silently installs the latest version of a package' {
			Find-Package -Name $package -Source $source | Install-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls the locally installed package just installed' {
			Get-Package -Name $package | Uninstall-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
		}

		It 'searches for and silently installs the latest version of a package' {
			Find-Package -Name $package | Install-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls the locally installed package just installed' {
			Get-Package -Name $package | Uninstall-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'version tests' {
	# Due to Homebrew's version support being very inconsisten between Cask and Formulae, only limited version filtering is supported, and tests are very fragile
	Context 'formula' {
		BeforeAll {
			$package = 'apng2gif'
			$source = 'homebrew/core'
			$version = '1.8'
		}

		It 'retrieves and correctly filters to a specific version' {
			Find-Package -Name $package -Source $source -Version "[$version]" | Where-Object {$_.Name -contains $package} | Should -HaveCount 1
		}
		It 'retrieves and correctly filters versions above a valid minimum' {
			Find-Package -Name $package -Source $source -Version "[$version,]" | Where-Object {$_.Name -contains $package} | Should -HaveCount 1
		}
		It 'retrieves and correctly filters versions below an invalid maximum' {
			Find-Package -Name $package -Source $source -Version "[,$version)" -ErrorAction SilentlyContinue | Where-Object {$_.Name -contains $package} | Should -HaveCount 0
		}
	}
	Context 'cask' {
		BeforeAll {
			$package = 'vlc'
			$version = '3.0.20'
		}

		It 'retrieves and correctly filters to a specific version' {
			Find-Package -Name $package -Version "[$version]" | Where-Object {$_.Name -contains $package} | Should -HaveCount 1
		}
		It 'retrieves and correctly filters versions above a valid minimum' {
			Find-Package -Name $package -Version "[$version,]" | Where-Object {$_.Name -contains $package} | Should -HaveCount 1
		}
		It 'retrieves and correctly filters versions below an invalid maximum' {
			Find-Package -Name $package -Version "[,$version)" -ErrorAction SilentlyContinue | Where-Object {$_.Name -contains $package} | Should -HaveCount 0
		}
	}
}

Describe "multi-source support" {
	BeforeAll {
		$altSource = 'pyroscope-io/brew'
		$altSourceLocation = 'https://github.com/pyroscope-io/homebrew-brew'
		$package = 'pyroscope'

		Unregister-PackageSource -Name $altSource -ErrorAction SilentlyContinue
	}
	AfterAll {
		Unregister-PackageSource -Name $altSource -ErrorAction SilentlyContinue
	}

	It 'refuses to find packages when the specified source does not exist' {
		{Find-Package -Name $package -Source $altSource -ErrorAction Stop} | Should -Throw 'The specified source is not registered with the package provider.'
	}
	It 'refuses to install packages when the specified source does not exist' {
		{Install-Package -Name $package -Source $altSource -ErrorAction Stop} | Should -Throw 'The specified source is not registered with the package provider.'
	}
	It 'registers an alternative package source' {
		Register-PackageSource -Name $altSource -Location $altSourceLocation -Provider $providerShortName -PassThru | Where-Object {$_.Name -eq $altSource} | Should -Not -BeNullOrEmpty
	}
	It 'searches for and installs the latest version of a package from an alternate source' {
		Find-Package -Name $package -Source $altSource | Install-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
	}
	It 'unregisters an alternative package source' {
		Unregister-PackageSource -Name $altSource
		Get-PackageSource | Where-Object {$_.Name -eq $altSource} | Should -BeNullOrEmpty
	}
}
