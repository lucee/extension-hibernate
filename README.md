# Ortus Lucee Hibernate Extension

A Hibernate for the rest of us!

## Why

Many improvements in the works:

* Improved logging
* Improved configuration support (both Hibernate and extension-level)
* More utility/helper methods
* better transaction isolation level support
* Better support for entity lock modes
* more Hibernate passthrough
* allow grabbing the current DB connection
* Faster ORM reloads
* Better connection management (fix open connection issues)
* Fix open session issues
* Fix session close at end of transaction issue (LDEV-4017)
* Drop hardcoded Hibernate dependencies from Lucee core
  * drop hardcoded ORM engine def from Lucee core

## Build

Using ant builds (for now):

* `ant clean` - clean build directories
* `ant compile` - compile code
* `ant dist` - Package the `.lex` extension file

## Contributing

First, make sure you have the java JRE and JDK installed.

Then [install ant](https://www.osradar.com/install-apache-ant-ubuntu-20-04/) if not installed.

To get started with this extension:

1. Install this repo - `git clone git@github.com:michaelborn/extension-hibernate-fork.git`
2. Check out the `FORK` branch - `git checkout FORK`
5. Change code...
6. Lint / validate via `ant compile`
7. Build extension via `ant dist`
8. Upload `.lex` to Lucee server admin and test.

## Thanks

Thanks to Lucee for the hard work and original source code. 👋
