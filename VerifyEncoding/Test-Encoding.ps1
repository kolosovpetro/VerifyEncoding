# SPDX-FileCopyrightText: 2020-2025 VerifyEncoding contributors <https://github.com/ForNeVeR/VerifyEncoding>
#
# SPDX-License-Identifier: MIT

<#
.SYNOPSIS
    This function will verify that there's no UTF-8 BOM or CRLF line endings in the files inside of the project.
#>

param (
    [string] $SourceRoot,
    [switch] $Autofix,
    [string[]] $ExcludeExtensions = @(
        '.dotsettings'
    )
)

function Test-Encoding
{
    param (
        # Path to the repository root. All text files under the root will be checked for UTF-8 BOM and CRLF.
        #
        # By default (if nothing's passed), the script will try auto-detecting the nearest Git root.
        [string] $SourceRoot,

        # Makes the script to perform file modifications to bring them to the standard.
        [switch] $Autofix,

        # List of file extensions (with leading dots) to ignore. Case-insensitive.
        [string[]] $ExcludeExtensions = @(
            '.dotsettings'
        )
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    if (!$SourceRoot)
    {
        $SourceRoot = git rev-parse --show-toplevel
        if (!$?)
        {
            throw "Cannot call `"git rev-parse`": exit code $LASTEXITCODE."
        }
    }

    # For PowerShell to properly process the UTF-8 output from git ls-tree we need to set up the output encoding:
    [Console]::OutputEncoding = [Text.Encoding]::UTF8

    try
    {
        # run ci
        Push-Location $SourceRoot
        [array]$allFiles = git -c core.quotepath=off ls-tree -r HEAD --name-only
        if (!$?)
        {
            throw "Cannot call `"git ls-tree`": exit code $LASTEXITCODE."
        }

#        $submodulesPath = "$SourceRoot/.gitmodules"
#
#        if (Test-Path $submodulesPath) {
#            Write-Host "Filtering submodules ..."
#            $submodules = (Get-Content $submodulesPath -Raw).Trim()
#            $allFiles = $allFiles | Where-Object { $submodules -notmatch [Regex]::Escape($_) }
#        }

        $totalFiles = $allFiles.Length
        Write-Output "Total files in the repository: $totalFiles"

        $counter = [pscustomobject]@{ Value = 0 }
        $groupSize = 50
        [array]$chunks = $allFiles | Group-Object -Property { [math]::Floor($counter.Value++ / $groupSize) }
        Write-Output "Split into $( $chunks.Count ) chunks."

        # https://stackoverflow.com/questions/6119956/how-to-determine-if-git-handles-a-file-as-binary-or-as-text#comment15281840_6134127
        $nullHash = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'
        $textFiles = $chunks | ForEach-Object {
            $chunk = $_.Group
            $filePaths = git -c core.quotepath=off diff --numstat $nullHash HEAD -- @chunk
            if (!$?)
            {
                throw "Cannot call `"git diff`": exit code $LASTEXITCODE."
            }
            $filePaths |
                Where-Object { -not $_.StartsWith('-') } |
                ForEach-Object { [Regex]::Unescape($_.Split("`t", 3)[2]) }
        }

        Write-Output "Text files in the repository: $( $textFiles.Length )"

        $bom = @(0xEF, 0xBB, 0xBF)
        $bomErrors = @()
        $lineEndingErrors = @()

        foreach ($file in $textFiles)
        {
            if ($ExcludeExtensions -contains [IO.Path]::GetExtension($file).ToLowerInvariant())
            {
                continue
            }

            $fileExists = Test-Path -Path $file

            if ($fileExists -eq $False)
            {
                Write-Host "File $file is deleted. Skipping ..."
                continue
            }

            $fileIsFolder = (Get-Item $file).PSIsContainer

            if($fileIsFolder -eq $True)
            {
                Write-Host "File $file is folder. Skipping ..."
                continue
            }

            $fullPath = Resolve-Path -LiteralPath $file

            $bytes = [IO.File]::ReadAllBytes($fullPath) | Select-Object -First $bom.Length

            if (!$bytes)
            {
                continue
            } # filter empty files

            $bytesEqualsBom = @(Compare-Object $bytes $bom -SyncWindow 0).Length -eq 0

            if ($bytesEqualsBom -and $Autofix)
            {
                $fullContent = [IO.File]::ReadAllBytes($fullPath)
                $newContent = $fullContent | Select-Object -Skip $bom.Length
                [IO.File]::WriteAllBytes($fullPath, $newContent)
                Write-Output "Removed UTF-8 BOM from file $file"
            }
            elseif ($bytesEqualsBom)
            {
                $bomErrors += @($file)
            }

            $text = [IO.File]::ReadAllText($fullPath)

            $crlf = "`r`n"
            $lf = "`n"
            $cr = "`r"

            $containsCrlf = $text.Contains($crlf)

            if ($containsCrlf -and $Autofix)
            {
                $newText = $text -replace $crlf, $lf
                [IO.File]::WriteAllText($fullPath, $newText)
                Write-Output "Fixed the line endings for file $file"
            }
            elseif ($containsCrlf)
            {
                $lineEndingErrors += @($file)
            }

            $containsCr = $text.Contains($cr)

            if ($containsCr -and $Autofix)
            {
                $newText = $text -replace $cr, $lf
                [IO.File]::WriteAllText($fullPath, $newText)
                Write-Output "Fixed the line endings for file $file"
            }
            elseif ($containsCr)
            {
                $lineEndingErrors += @($file)
            }
        }

        if ($bomErrors.Length)
        {
            throw "The following $( $bomErrors.Length ) files have UTF-8 BOM:`n" + ($bomErrors -join "`n")
        }
        if ($lineEndingErrors.Length)
        {
            throw "The following $( $lineEndingErrors.Length ) files have CRLF instead of LF:`n" + ($lineEndingErrors -join "`n")
        }
    }
    finally
    {
        Pop-Location
    }
}

# Convenience launch mode when not invoked as part of a module:
if (!$MyInvocation.PSCommandPath -or !$MyInvocation.PSCommandPath.EndsWith('.psm1')) {
    Write-Output "Direct script launcher mode.$(if ($MyInvocation.PSCommandPath) {
        ' Launched from "' + $MyInvocation.PSCommandPath + '".'
    })"
    Test-Encoding -SourceRoot:$SourceRoot -Autofix:$Autofix -ExcludedExtensions:$ExcludeExtensions
}
