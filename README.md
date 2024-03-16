# AnyPackage.Homebrew

[![gallery-image]][gallery-site]
[![build-image]][build-site]
[![cf-image]][cf-site]

[gallery-image]: https://img.shields.io/powershellgallery/dt/AnyPackage.Homebrew
[build-image]: https://img.shields.io/github/actions/workflow/status/anypackage/Homebrew/ci.yml
[cf-image]: https://img.shields.io/codefactor/grade/github/anypackage/Homebrew
[gallery-site]: https://www.powershellgallery.com/packages/AnyPackage.Homebrew
[build-site]: https://github.com/anypackage/homebrew/actions/workflows/CI.yml
[cf-site]: https://www.codefactor.io/repository/github/anypackage/Homebrew

AnyPackage.Homebrew is an AnyPackage provider that facilitates installing Homebrew packages from any compatible repository.

## Requirements

In addition to PowerShell 7+ and an Internet connection on a MacOS or Linux machine, [Homebrew](https://brew.sh/) must also be installed.

## Install AnyPackage.Homebrew

```PowerShell
Install-Module AnyPackage.Homebrew -Force
```

## Import AnyPackage.Homebrew

```PowerShell
Import-Module AnyPackage.Homebrew
```

## Sample usages

### Search for a package

```PowerShell
Find-Package -Name node -Repository homebrew/core

Find-Package -Name firefox
```

### Install a package

```PowerShell
Find-Package -Name node -Repository homebrew/core | Install-Package

Install-Package -Name firefox
```

### Get list of installed packages (with wildcard search support)

```PowerShell
Get-Package lib*
```

### Uninstall a package

```PowerShell
Get-Package node | Uninstall-Package

Uninstall-Package firefox
```

### Manage package sources

```PowerShell
Register-PackageSource privateRepo -Provider Homebrew -Location 'https://somewhere/out/there/cache'
Find-Package node -Source privateRepo | Install-Package
Unregister-PackageSource privateRepo
```

AnyPackage.Homebrew integrates with `brew` to manage and store source information.

## Known Issues

### Stability

Homebrew does not currently have an official module available on PowerShell Gallery, therefore this provider currently depends on a  Cresendo module that is a best-effort attempt at parsing Homebrew's output. Due to Homebrew's output patterns fluctuating regularly, making a Cresdendo-based implementation is very brittle. As such, currently this provider **should not** be used in production scenarios.

## Legal and Licensing

AnyPackage.Homebrew is licensed under the [MIT license](./LICENSE.txt).
