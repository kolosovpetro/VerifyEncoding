# SPDX-FileCopyrightText: 2025 VerifyEncoding contributors <https://github.com/ForNeVeR/VerifyEncoding>
#
# SPDX-License-Identifier: MIT

@{
    RootModule = 'VerifyEncoding.psm1'
    ModuleVersion = '2.1.0'
    GUID = 'b7e60ad7-bfa0-43fa-a7b6-3a06de3f8f74'
    Author = 'Friedrich von Never <friedrich@fornever.me> et. all'
    CompanyName = 'github.com/ForNeVeR/encoding-verifier'
    Description = 'A script to verify text file encodings in a repository.'
    PowerShellVersion = '5.0'
    FunctionsToExport = @(
        'Test-Encoding'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}
