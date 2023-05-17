# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [5.4.29.24] - 2023-05-17

### Security

* Upgraded dom4j library from 1.6.1 to 2.1.4. This removes two potential vulnerabilities in dom4j's XML parsing capabilities.
  * [See vulnerability info at mvnrepository.com](https://mvnrepository.com/artifact/dom4j/dom4j/1.6.1)

## [5.4.29.23] - 2023-05-15

### Fixed

* ORMExecuteQuery ignores `"unique"` argument if `options` struct is passed

## [5.4.29.22] - 2023-05-11

### Added

* Adds support for `autoGenMap=false` - [LDEV-3525](https://luceeserver.atlassian.net/browse/LDEV-3525)
* Adds javadocs auto-published to [apidocs.ortussolutions.com](https://apidocs.ortussolutions.com/#/lucee/hibernate-extension/)

### Fixed

* ORM events not firing ([LDEV-4308](https://luceeserver.atlassian.net/browse/LDEV-4308))
* Session close on transaction end ([LDEV-4017](https://luceeserver.atlassian.net/browse/LDEV-4017))
* "length" not used on varchar fields ([LDEV-4150](https://luceeserver.atlassian.net/browse/LDEV-4150))

### Changed

* Dramatic improvements in initialization performance
* Cuts ORM reload time by 60%
* Better build/test documentation
* Improved maintenance and build docs