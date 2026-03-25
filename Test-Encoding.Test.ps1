# SPDX-FileCopyrightText: 2025 VerifyEncoding contributors <https://github.com/ForNeVeR/VerifyEncoding>
#
# SPDX-License-Identifier: MIT

BeforeAll {
    Import-Module "$PSScriptRoot/VerifyEncoding/VerifyEncoding.psd1" -Force

    function PrepareGitRepo($files)
    {
        $repoPath = New-TemporaryFile
        Remove-Item $repoPath
        New-Item -Type Directory $repoPath | Out-Null

        Push-Location $repoPath
        try
        {
            git init . | Out-Host
            if (!$?)
            {
                throw "Error code from git init: $LASTEXITCODE."
            }

            foreach ($fileName in $files.Keys)
            {
                $text = $files[$fileName]
                $dir = Split-Path -Parent $fileName
                if ($dir) { New-Item -Type Directory -Force $dir | Out-Null }
                Set-Content -LiteralPath $fileName -Value $text -NoNewline -Encoding utf8
                git add $fileName
                if (!$?)
                {
                    throw "Error code from git add: $LASTEXITCODE."
                }
            }

            git -c 'user.name=Test User' `
                -c 'user.email=test@example.com' `
                commit --all --message 'Initial commit' | Out-Host
            if (!$?)
            {
                throw "Error code from git commit: $LASTEXITCODE."
            }
        }
        finally
        {
            Pop-Location
        }

        $repoPath
    }

    function Add-Submodule($mainRepo, $submoduleRepo, $submoduleDirectory) {
        Push-Location -LiteralPath $mainRepoPath
        try {
            git -c protocol.file.allow=always submodule add $additionalRepoPath $submoduleDirectory | Out-Host
            if (!$?) {
                throw "Error code from git submodule: $LASTEXITCODE."
            }
            git -c 'user.name=Test User' `
                -c 'user.email=test@example.com' `
                commit --all --message 'Add a submodule' | Out-Host
            if (!$?)
            {
                throw "Error code from git commit: $LASTEXITCODE."
            }
        } finally {
            Pop-Location
        }
    }

    function Assert-FileContent($path, $content) {
        # This is to read UTF-8 BOM correctly:
        $bytes = [IO.File]::ReadAllBytes($path)
        $string = [Text.Encoding]::UTF8.GetString($bytes)

        $string | Should -Be $content
        $string.Length | Should -Be $content.Length # compare length since the comparison above won't trigger on BOM
    }
}

Describe 'Verification' {
    It 'should properly scan an empty file' {
        $repoPath = PrepareGitRepo @{
            'empty-file.txt' = ''
        }
        $output = Test-Encoding -SourceRoot $repoPath
        $? | Should -Be $true
        $output | Should -Be @(
            'Total files in the repository: 1'
            'Split into 1 chunks.'
            'Text files in the repository: 1'
        )
    }

    It 'should properly work on submodules' {
        $mainRepoPath = PrepareGitRepo @{
            'empty-file.txt' = ''
        }
        $additionalRepoPath = PrepareGitRepo @{
            'empty-file.txt' = ''
        }
        Add-Submodule $mainRepoPath $additionalRepoPath 'test-submodule'

        $output = Test-Encoding -SourceRoot $mainRepoPath
        $output | Should -Be @(
            'Total files in the repository: 2'
            'Split into 1 chunks.'
            'Text files in the repository: 2'
        )
    }

    It 'should still work if there are any files deleted' {
        $repoPath = PrepareGitRepo @{
            'empty-file.txt' = ''
        }
        Remove-Item -LiteralPath "$repoPath/empty-file.txt"
        $output = Test-Encoding -SourceRoot $repoPath
        $output | Should -Be @(
            'Total files in the repository: 0'
            'Split into 0 chunks.'
            'Text files in the repository: 0'
        )
    }
}

Describe 'Autofix' {
    It 'should process all different sorts of line endings' {
        $repoPath = PrepareGitRepo @{
            'windows.txt' = "1`r`n2`r`n3`r`n"
            'windows.trailing.txt' = "1`r`n2`r`n3"
            'linux.txt' = "1`n2`n3`n"
            'linux.trailing.txt' = "1`n2`n3"
            'os9.txt' = "1`r2`r3"
            'os9.trailing.txt' = "1`r2`r3`r"
            'mixed.txt' = "1`r2`r`n3`n4"
            'mixed.trailing.txt' = "1`r2`r`n3`n4`r`n"
        }

        Assert-FileContent "$repoPath/windows.txt" "1`r`n2`r`n3`r`n"
        Assert-FileContent "$repoPath/windows.trailing.txt" "1`r`n2`r`n3"
        Assert-FileContent "$repoPath/linux.txt" "1`n2`n3`n"
        Assert-FileContent "$repoPath/linux.trailing.txt" "1`n2`n3"
        Assert-FileContent "$repoPath/os9.txt" "1`r2`r3"
        Assert-FileContent "$repoPath/os9.trailing.txt" "1`r2`r3`r"
        Assert-FileContent "$repoPath/mixed.txt" "1`r2`r`n3`n4"
        Assert-FileContent "$repoPath/mixed.trailing.txt" "1`r2`r`n3`n4`r`n"

        $output = Test-Encoding -SourceRoot $repoPath -Autofix
        $output | Should -Be @(
            'Total files in the repository: 8'
            'Split into 1 chunks.'
            'Text files in the repository: 8'
            'Fixed the line endings for file mixed.trailing.txt'
            'Fixed the line endings for file mixed.txt'
            'Fixed the line endings for file os9.trailing.txt'
            'Fixed the line endings for file os9.txt'
            'Fixed the line endings for file windows.trailing.txt'
            'Fixed the line endings for file windows.txt'
        )

        Assert-FileContent "$repoPath/windows.txt" "1`n2`n3`n"
        Assert-FileContent "$repoPath/windows.trailing.txt" "1`n2`n3"
        Assert-FileContent "$repoPath/linux.txt" "1`n2`n3`n"
        Assert-FileContent "$repoPath/linux.trailing.txt" "1`n2`n3"
        Assert-FileContent "$repoPath/os9.txt" "1`n2`n3"
        Assert-FileContent "$repoPath/os9.trailing.txt" "1`n2`n3`n"
        Assert-FileContent "$repoPath/mixed.txt" "1`n2`n3`n4"
        Assert-FileContent "$repoPath/mixed.trailing.txt" "1`n2`n3`n4`n"
    }

    It 'should empty a file with BOM only' {
        $bom = [System.Text.Encoding]::UTF8.GetString(@(0xEF, 0xBB, 0xBF))
        $repoPath = PrepareGitRepo @{
            'bom.txt' = $bom
        }

        Assert-FileContent "$repoPath/bom.txt" $bom

        $output = Test-Encoding -SourceRoot $repoPath -Autofix
        $output | Should -Be @(
            'Total files in the repository: 1'
            'Split into 1 chunks.'
            'Text files in the repository: 1'
            'Removed UTF-8 BOM from file bom.txt'
        )

        Assert-FileContent "$repoPath/bom.txt" ''
    }
}

Describe 'ExcludePatterns' {
    It 'should exclude files matching a simple glob pattern' {
        $bom = [System.Text.Encoding]::UTF8.GetString(@(0xEF, 0xBB, 0xBF))
        $repoPath = PrepareGitRepo @{
            'Foo.Designer.cs' = $bom
            'Foo.cs'          = $bom
        }

        { Test-Encoding -SourceRoot $repoPath -ExcludePatterns '*.Designer.cs' } | Should -Throw '*Foo.cs*'
    }

    It 'should work additively with -ExcludeExtensions' {
        $bom = [System.Text.Encoding]::UTF8.GetString(@(0xEF, 0xBB, 0xBF))
        $repoPath = PrepareGitRepo @{
            'Foo.Designer.cs' = $bom
            'Foo.cs'          = $bom
            'Foo.txt'         = $bom
        }

        # Exclude .txt via extension, exclude *.Designer.cs via pattern — only Foo.cs should remain and trigger an error
        { Test-Encoding -SourceRoot $repoPath -ExcludeExtensions '.txt' -ExcludePatterns '*.Designer.cs' } | Should -Throw '*Foo.cs*'
    }

    It 'should work when a single string is passed instead of an array' {
        $bom = [System.Text.Encoding]::UTF8.GetString(@(0xEF, 0xBB, 0xBF))
        $repoPath = PrepareGitRepo @{
            'Foo.Designer.cs' = $bom
            'Foo.cs'          = ''
        }

        # Single string (not wrapped in @()) — Foo.Designer.cs excluded, Foo.cs is clean
        $output = Test-Encoding -SourceRoot $repoPath -ExcludePatterns '*.Designer.cs'
        $output | Should -Be @(
            'Total files in the repository: 2'
            'Split into 1 chunks.'
            'Text files in the repository: 2'
        )
    }

    It 'should exclude files in a specific directory matched by a relative glob pattern' {
        $bom = [System.Text.Encoding]::UTF8.GetString(@(0xEF, 0xBB, 0xBF))
        $repoPath = PrepareGitRepo @{
            'foo/Foo.Designer.cs' = $bom
            'foo/Foo.cs'          = ''
        }

        # foo/Foo.Designer.cs excluded by pattern, foo/Foo.cs is clean — no errors expected
        $output = Test-Encoding -SourceRoot $repoPath -ExcludePatterns 'foo/*.Designer.cs'
        $output | Should -Be @(
            'Total files in the repository: 2'
            'Split into 1 chunks.'
            'Text files in the repository: 2'
        )
    }

    It 'should not exclude files in directories whose names merely contain the pattern prefix' {
        $bom = [System.Text.Encoding]::UTF8.GetString(@(0xEF, 0xBB, 0xBF))
        $repoPath = PrepareGitRepo @{
            'foo/Foo.Designer.cs'  = $bom  # should be excluded
            'afoo/Foo.Designer.cs' = $bom  # should NOT be excluded — wrong directory
        }

        # Pattern anchors to 'foo/', so 'afoo/Foo.Designer.cs' is not excluded and triggers an error
        { Test-Encoding -SourceRoot $repoPath -ExcludePatterns 'foo/*.Designer.cs' } |
            Should -Throw '*afoo/Foo.Designer.cs*'
    }
}
