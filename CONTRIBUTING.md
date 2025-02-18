<!--
SPDX-FileCopyrightText: 2025 Friedrich von Never <friedrich@fornever.me>

SPDX-License-Identifier: MIT
-->

Contributor Guide
=================
Run Tests
---------
Execute the following steps in a PowerShell Core session.

1. Install [Pester][pester]:
   ```console
   $ Install-Module Pester -Force
   ```
   (see the Pester version we use in `.github/workflows/main.yml`)
2. Import Pester:
   ```console
   $ Import-Module Pester -PassThru
   ```
3. Run the tests:
   ```console
   $ Invoke-Pester -Output Detailed ./Test-Encoding.Test.ps1
   ```

License Automation
------------------
<!-- REUSE-IgnoreStart -->
If the CI asks you to update the file licenses, follow one of these:
1. Update the headers manually (look at the existing files), something like this:
   ```
   # SPDX-FileCopyrightText: %year% %your name% <%your contact info, e.g. email%>
   #
   # SPDX-License-Identifier: MIT
   ```
   (accommodate to the file's comment style if required).
2. Alternately, use [REUSE][reuse] tool:
   ```console
   $ reuse annotate --license MIT --copyright '%your name% <%your contact info, e.g. email%>' %file names to annotate%
   ```

(Feel free to attribute the changes to "encoding-verifier contributors <https://github.com/ForNeVeR/encoding-verifier>" instead of your name in a multi-author file, or if you don't want your name to be mentioned in the project's source: this doesn't mean you'll lose the copyright.)
<!-- REUSE-IgnoreEnd -->

[pester]: https://pester.dev/
[reuse]: https://reuse.software/
