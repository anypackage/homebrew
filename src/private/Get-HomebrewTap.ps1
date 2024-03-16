function Get-HomebrewTap {
	(Croze\Get-HomebrewTap) + @([pscustomobject]@{Name='homebrew/cask'},[pscustomobject]@{Name='homebrew/core'})
}
