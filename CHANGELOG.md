<!--
SPDX-FileCopyrightText: 2025 Friedrich von Never <friedrich@fornever.me>

SPDX-License-Identifier: MIT
-->

Changelog
=========
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.1] - 2025-07-26
### Fixed
- [#29](https://github.com/ForNeVeR/VerifyEncoding/issues/29): Error if a file contains only BOM character. Thanks to @kolosovpetro!

## [2.2.0] - 2025-04-13
### Fixed
- Script no longer gets invoked with default arguments after being imported.
- [#15: Fails on deleted files](https://github.com/ForNeVeR/VerifyEncoding/issues/15). Thanks to @kolosovpetro!
- [#13: Breaks on submodules](https://github.com/ForNeVeR/VerifyEncoding/issues/13). Thanks to @kolosovpetro!
- Correct reporting of text file count in repositories with only one text file.
- Various weird issues that were happening when run on a repository with no text files.

### Added
- [#16](https://github.com/ForNeVeR/VerifyEncoding/issues/13): detection and automatic fix for the CR line ending. Thanks to @kolosovpetro!

## [2.1.0] - 2025-04-08
### Changed
- The project has been published to the PowerShell Gallery as a module. Thanks to @kolosovpetro!
- The project has been renamed to VerifyEncoding (to correspond to the published module name).

## [2.0.1] - 2025-02-18
### Fixed
- [#7: Breaks on empty files](https://github.com/ForNeVeR/VerifyEncoding/issues/7).
- No longer incorrectly process repositories with only one file.

## [2.0.0] - 2025-02-09
### Changed
- **(Breaking change! A small one, though.)** The default directory for the source root is now determined through the Git invocation.
- Terminate on Git invocation errors.
- Split files for passing into `git ls-files` into chunks (support huge file lists).

### Added
- Add new parameter: `-ExcludedExtensions`, with a list of file extensions to ignore during the check.

### Fixed
- Fixed file list calculation if running from an alternate source root.

## [1.0.0] - 2025-02-08
This is the initial release as a separate project, after the script has been used in several repositories.

The development was started in 2020,
the earlier history of the script could be [tracked via the xaml-math repository](https://github.com/ForNeVeR/xaml-math/commits/f5a0d9303825337d87f69250152620903c6a37ca/scripts/verify-encoding.ps1).

[Unreleased]: https://github.com/ForNeVeR/VerifyEncoding/compare/v2.2.1...HEAD
[2.2.1]: https://github.com/ForNeVeR/VerifyEncoding/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/ForNeVeR/VerifyEncoding/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/ForNeVeR/VerifyEncoding/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/ForNeVeR/VerifyEncoding/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/ForNeVeR/VerifyEncoding/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/ForNeVeR/VerifyEncoding/releases/tag/v1.0.0
