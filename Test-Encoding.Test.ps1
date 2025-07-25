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
