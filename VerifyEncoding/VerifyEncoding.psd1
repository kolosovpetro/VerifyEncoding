# SPDX-FileCopyrightText: 2025 VerifyEncoding contributors <https://github.com/ForNeVeR/VerifyEncoding>
#
# SPDX-License-Identifier: MIT

# REUSE-IgnoreStart
@{
    RootModule = 'VerifyEncoding.psm1'
    ModuleVersion = '2.2.0'
    GUID = 'b7e60ad7-bfa0-43fa-a7b6-3a06de3f8f74'
    Author = 'VerifyEncoding contributors'
    CompanyName = 'VerifyEncoding contributors'
    Copyright = '2020-2025 VerifyEncoding contributors <https://github.com/ForNeVeR/VerifyEncoding>'
    Description = 'A script to verify text file encodings in a repository.'
    PowerShellVersion = '6.0'
    FunctionsToExport = @(
        'Test-Encoding'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('encoding', 'ci')
            LicenseUri = 'https://spdx.org/licenses/MIT.html'
            ProjectUri = 'https://github.com/ForNeVeR/VerifyEncoding'
        }
    }
}
# REUSE-IgnoreEnd
