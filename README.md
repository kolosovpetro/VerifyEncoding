<!--
SPDX-FileCopyrightText: 2025 Friedrich von Never <friedrich@fornever.me>

SPDX-License-Identifier: MIT
-->

encoding-verifier [![Status Terrid][status-terrid]][andivionian-status-classifier]
=================
This is a script to verify file encodings. It will ensure that none text files in the repository (identified as text by Git) have `\r\n` line endings or UTF-8 BOM attached to them.

Usage
-----
### Installation
It is currently recommended to just copy the `Test-Encoding.ps1` script to your repo.

If you seek for a particular released version, go to the [Releases][releases] section.

### Local Run
```console
$ pwsh Test-Encoding.ps1 [[-SourceRoot] <SourceRoot>] [-Autofix] [[-ExcludeExtensions] <String[]>]
```

Where
- `SourceRoot` is the directory where the script will look for the files. By default (if nothing's passed), the script will try auto-detecting the nearest Git root.
- `-Autofix` will apply fixes to all the problematic files.
- `-ExcludeExtensions` allows passing an array of file extensions (case-insensitive) that will be ignored during the check. The default list is `@('.dotsettings')`

### CI
Add the following block to your CI script (here I'll use GitHub Actions, but it's possible to adapt to any other CI provider):
```yaml
jobs:
  encoding:
    runs-on: ubuntu-24.04
    steps:
    # […]
    - name: Verify encoding
      shell: pwsh
      run: scripts/Test-Encoding.ps1
```
Script will generate a non-zero exit code in case there's a validation error, and list all the files with issues.

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
[docs.changelog]: CHANGELOG.md
[docs.contributing]: CONTRIBUTING.md
[docs.license]: LICENSE.txt
[docs.maintaining]: MAINTAINING.md
[releases]: https://github.com/ForNeVeR/encoding-verifier/releases
[reuse.spec]: https://reuse.software/spec-3.3/
[status-terrid]: https://img.shields.io/badge/status-terrid-green.svg
