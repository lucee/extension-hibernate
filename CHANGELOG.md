# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [5.4.29.25] - 2023-05-23

## Changed

-   Switched to Maven for a faster, more stable build process
-   Improved entity event listeners for a much speedier ORM startup (8924b58a9058d296e2a783ccfabbf90e26dc9c1b)
-   New and Improved logo for Lucee admin visibility (10bdf56a7a78f0221ab1a6e66a5512a92819e5b7)

## Fixed

-   Entity has no state when listener method (`onPreInsert`, for example) is fired (014814263b5d31b8bac4c17479c2ca731ceb4e7c, [OOE-1](https://ortussolutions.atlassian.net/browse/OOE-1))

## [5.4.29.24] - 2023-05-17

### Security

-   Upgraded dom4j library from 1.6.1 to 2.1.4. This removes two potential vulnerabilities in dom4j's XML parsing capabilities.
    -   [See vulnerability info at mvnrepository.com](https://mvnrepository.com/artifact/dom4j/dom4j/1.6.1)

## [5.4.29.23] - 2023-05-15

### Fixed

-   ORMExecuteQuery ignores `"unique"` argument if `options` struct is passed

## [5.4.29.22] - 2023-05-11

### Added

-   Adds support for `autoGenMap=false` - [LDEV-3525](https://luceeserver.atlassian.net/browse/LDEV-3525)
-   Adds javadocs auto-published to [apidocs.ortussolutions.com](https://apidocs.ortussolutions.com/#/lucee/hibernate-extension/)

### Fixed

-   ORM events not firing ([LDEV-4308](https://luceeserver.atlassian.net/browse/LDEV-4308))
-   Session close on transaction end ([LDEV-4017](https://luceeserver.atlassian.net/browse/LDEV-4017))
-   "length" not used on varchar fields ([LDEV-4150](https://luceeserver.atlassian.net/browse/LDEV-4150))

### Changed

-   Dramatic improvements in initialization performance
-   Cuts ORM reload time by 60%
-   Better build/test documentation
-   Improved maintenance and build docs

[Unreleased]: https://github.com/Ortus-Solutions/extension-hibernate/compare/v5.4.29.25...HEAD

[5.4.29.25]: https://github.com/Ortus-Solutions/extension-hibernate/compare/80d6ad971c06a955ec0e308f2c8149ee7119654d...v5.4.29.25
