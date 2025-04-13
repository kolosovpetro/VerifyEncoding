<!--
SPDX-FileCopyrightText: 2025 VerifyEncoding contributors <https://github.com/ForNeVeR/VerifyEncoding>

SPDX-License-Identifier: MIT
-->

VerifyEncoding [![Status Terrid][status-terrid]][andivionian-status-classifier] [![PowerShell Gallery Version][badge.powershell-gallery]][install.powershell-gallery]
==============
This is a script to verify file encodings. It will ensure that none text files in the repository (identified as text by Git) have `\r\n` line endings or UTF-8 BOM attached to them.

Usage
-----
### Installation
#### Option 1: PowerShell Gallery
[Install the module from the PowerShell Gallery][install.powershell-gallery]:
```console
$ Install-Module VerifyEncoding -Repository PSGallery -Scope CurrentUser
```

Then use as a PowerShell function:
```
$ Import-Module VerifyEncoding
$ Test-Encoding [[-SourceRoot] <SourceRoot>] [-Autofix] [[-ExcludeExtensions] <String[]>]
```

#### Option 2: Quick Script Deployment
Copy the `VerifyEncoding/Test-Encoding.ps1` script to your repo (or get from [the Releases section][releases]),
then use from any shell as
```console
$ pwsh Test-Encoding.ps1 [[-SourceRoot] <SourceRoot>] [-Autofix] [[-ExcludeExtensions] <String[]>]
```

#### Option 3: Deploy Module From Sources
Either clone the sources or download the latest module archive from [the Releases section][releases],
and then run the following PowerShell commands:
```console
$ Import-Module ./VerifyEncoding/VerifyEncoding.psd1
$ Test-Encoding [[-SourceRoot] <SourceRoot>] [-Autofix] [[-ExcludeExtensions] <String[]>]
```

### Parameters
- `SourceRoot` is the directory where the script will look for the files. By default (if nothing's passed), the script will try auto-detecting the nearest Git root.
- `-Autofix` will apply fixes to all the problematic files.
- `-ExcludeExtensions` allows passing an array of file extensions (case-insensitive) that will be ignored during the check. The default list is `@('.dotsettings')`

### CI
Add the following block to your CI script (here I'll use GitHub Actions, but it's possible to adapt to any other CI provider):
```yaml
jobs:
  encoding:
    runs-on: ubuntu-latest # or any other runner that has PowerShell installed
    steps:
    # […]
    - name: Verify encoding
      shell: pwsh
      run: Install-Module VerifyEncoding -Repository PSGallery -RequiredVersion 2.2.0 -Force && Test-Encoding <parameters go here>
```
This command will generate a non-zero exit code in case there's a validation error and list all the files with issues.

#### Renovate
If you use [Renovate][renovate] to automatically manage dependencies on CI,
you may set it up to update VerifyEncoding as well.
If you have the previously recommended `Install-Module` command called in your CI setup script,
then add the following into your `renovate.json`, and it will also update VerifyEncoding from the PowerShell Gallery:
```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": "...",
  "customManagers": [
    {
      "customType": "regex",
      "fileMatch": [
        "^\\.github/workflows/.+\\.yml$"
      ],
      "matchStrings": [
        "Install-Module (?<depName>\\S+?) -RequiredVersion (?<currentValue>\\S+)"
      ],
      "datasourceTemplate": "nuget",
      "registryUrlTemplate": "https://www.powershellgallery.com/api/v2/"
    }
  ]
}
```

Documentation
-------------
- [Changelog][docs.changelog]
- [Contributor Guide][docs.contributing]
- [Maintainer Guide][docs.maintaining]

License
-------
The project is distributed under the terms of [the MIT license][docs.license].

The license indication in the project's sources is compliant with the [REUSE specification v3.3][reuse.spec].

[andivionian-status-classifier]: https://andivionian.fornever.me/v1/#status-terrid-
[badge.powershell-gallery]: https://img.shields.io/powershellgallery/v/VerifyEncoding
[docs.changelog]: CHANGELOG.md
[docs.contributing]: CONTRIBUTING.md
[docs.license]: LICENSE.txt
[docs.maintaining]: MAINTAINING.md
[install.powershell-gallery]: https://www.powershellgallery.com/packages/VerifyEncoding
[releases]: https://github.com/ForNeVeR/VerifyEncoding/releases
[renovate]: https://docs.renovatebot.com/
[reuse.spec]: https://reuse.software/spec-3.3/
[status-terrid]: https://img.shields.io/badge/status-terrid-green.svg
