# SPDX-FileCopyrightText: 2025 Friedrich von Never <friedrich@fornever.me>
#
# SPDX-License-Identifier: MIT

param(
    [string] $NewVersion = '2.2.0',
    [string] $RepositoryRoot = "$PSScriptRoot/.."
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Update-VersionInModuleManifest {
    $manifestFilePath = "$RepositoryRoot/VerifyEncoding/VerifyEncoding.psd1"
    $oldContent = Get-Content -LiteralPath $manifestFilePath -Raw
    $content = $oldContent -Replace "ModuleVersion = '(?:.*?)'", "ModuleVersion = '$NewVersion'"
    if ($oldContent -eq $content) {
        throw "Unable to update version in file `"$manifestFilePath`"."
    }

    Set-Content -LiteralPath $manifestFilePath $content -NoNewline
}

function Update-VersionInReadme {
    $readMeFilePath = "$RepositoryRoot/README.md"
    $oldContent = Get-Content -LiteralPath $readMeFilePath -Raw
    $content = $oldContent -Replace "-RequiredVersion (?:.*?) ", "-RequiredVersion $NewVersion "

    if ($oldContent -eq $content) {
        throw "Unable to update version in file `"$readMeFilePath`"."
    }
    Set-Content -LiteralPath $readMeFilePath $content -NoNewline
}

Update-VersionInModuleManifest
Update-VersionInReadme
