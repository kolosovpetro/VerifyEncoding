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
3. Update the copyright statement in the `VerifyEncoding/VerifyEncoding.psd1` module manifest file, if required.
4. Prepare a corresponding entry in the `CHANGELOG.md` file (usually by renaming the "Unreleased" section).
5. Update the project version using the `scripts/Update-Version.ps1` script.
6. Merge the aforementioned changes via a pull request.
7. Push a tag in form of `v<VERSION>`, e.g. `v0.0.0`. The automation will do the rest.

Rotate the PowerShell Gallery Publishing Key
--------------------------------------------
1. Sign in onto https://www.powershellgallery.com/.
2. Go to the [API Keys][powershell-gallery.api-keys] section.
3. Update the existing or create a new key named `verify-encoding.github` with a permission to **Push only new package versions** and only allowed to publish the package **VerifyEncoding**.

   (If this is the first publication of a new package,
   upload a temporary short-living key with permission to add new packages
   and rotate it afterward.)
4. Paste the generated key to the `POWERSHELL_GALLERY_KEY` variable on the [action secrets][github.secrets] section of GitHub settings.

[github.secrets]: https://github.com/ForNeVeR/VerifyEncoding/settings/secrets/actions
[powershell-gallery.api-keys]: https://www.powershellgallery.com/account/apikeys
