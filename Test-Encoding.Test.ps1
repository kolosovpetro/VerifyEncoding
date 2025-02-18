# SPDX-FileCopyrightText: 2025 Friedrich von Never <friedrich@fornever.me>
#
# SPDX-License-Identifier: MIT

BeforeAll {
    function PrepareGitRepo($files) {
        $repoPath = New-TemporaryFile
        Remove-Item $repoPath
        New-Item -Type Directory $repoPath | Out-Null

        Push-Location $repoPath
        try {
            git init . | Out-Host
            if (!$?) { throw "Error code from git init: $LASTEXITCODE." }

            foreach ($fileName in $files.Keys) {
               $text = $files[$fileName]
               Set-Content -LiteralPath $fileName -Value $text -NoNewline
               git add $fileName
               if (!$?) { throw "Error code from git add: $LASTEXITCODE." }
            }

            git commit --all --message 'Initial commit' | Out-Host
            if (!$?) { throw "Error code from git commit: $LASTEXITCODE." }
        } finally {
            Pop-Location
        }

        $repoPath
    }
}

Describe 'Test-Encoding' {
    It 'Should properly scan an empty file' {
        $repoPath = PrepareGitRepo @{
            'empty-file.txt' = ''
        }
        $output = ./Test-Encoding.ps1 -SourceRoot $repoPath
        $? | Should -Be $true
        $output | Should -Be @(
            'Total files in the repository: 1'
        )
    }
}
