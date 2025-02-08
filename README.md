<!--
SPDX-FileCopyrightText: 2025 Friedrich von Never <friedrich@fornever.me>

SPDX-License-Identifier: MIT
-->

encoding-verifier
=================
This is a script to verify file encodings. It will ensure that none text files in the repository (identified as text by Git) have `\r\n` line endings or UTF-8 BOM attached to them.

Usage
-----

### Local Run
```console
$ pwsh Test-Encoding.ps1 [[-SourceRoot] <SourceRoot>] [-Autofix]
```

Where
- `SourceRoot` is the directory where the script will look for the files. By default, the script will consider the parent of the script directory as the source root.
- `-Autofix` will apply fixes to all the problematic files.

### CI
Add the following block to your CI script (here I'll use GitHub Actions, but it's use to adapt to any other CI provider):
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
- [Contributor Guide][docs.contributing]

License
-------
The project is distributed under the terms of [the MIT license][docs.license].

The license indication in the project's sources is compliant with the [REUSE specification v3.3][reuse.spec].

[docs.contributing]: CONTRIBUTING.md
[docs.license]: LICENSE.txt
[reuse.spec]: https://reuse.software/spec-3.3/
