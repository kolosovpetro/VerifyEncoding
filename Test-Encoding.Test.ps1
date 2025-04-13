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
                Set-Content -LiteralPath $fileName -Value $text -NoNewline
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
}

Describe 'Test-Encoding function' {
    It 'Should properly scan an empty file' {
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

    It 'Should properly work on submodules' {
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
}
