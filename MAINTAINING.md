<!--
SPDX-FileCopyrightText: 2024-2025 VerifyEncoding contributors <https://github.com/ForNeVeR/VerifyEncoding>

SPDX-License-Identifier: MIT
-->

Maintainer Guide
================

Publish a New Version
---------------------
1. Update the project's status in the `README.md` file, if required.
2. Update the copyright statement in the `LICENSE.txt` file, if required.
3. Prepare a corresponding entry in the `CHANGELOG.md` file (usually by renaming the "Unreleased" section).
4. Update the project version using the `scripts/Update-Version.ps1` script.
5. Merge the aforementioned changes via a pull request.
6. Push a tag in form of `v<VERSION>`, e.g. `v0.0.0`.

Release to PowerShell Gallery
-----------------------------
- Set `PWSH_GALLERY_KEY` with your API key
- `Test-ModuleManifest .\VerifyEncoding\VerifyEncoding.psd1`
- `Publish-Module -Path '.\VerifyEncoding' -Repository PSGallery -NuGetApiKey $env:PWSH_GALLERY_KEY -Verbose`
