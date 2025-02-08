# SPDX-FileCopyrightText: 2024-2025 Friedrich von Never <friedrich@fornever.me>
#
# SPDX-License-Identifier: MIT

param(
    [string] $RefName,
    [string] $RepositoryRoot = "$PSScriptRoot/.."
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "Determining version from ref `"$RefName`"…"
if ($RefName -match '^refs/tags/v') {
    $version = $RefName -replace '^refs/tags/v', ''
    Write-Host "Pushed ref is a version tag, version: $version"
} else {
    $version = 'next'
    Write-Host "Pushed ref is a not version tag, using version $version"
}

Write-Output $version
