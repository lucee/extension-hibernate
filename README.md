# Ortus Lucee Hibernate Extension

A Hibernate for the rest of us!

## Improvements

### Features and Bug Fixes

* Fix session close at end of transaction issue (LDEV-4017) 🐛🐛🐛
* Fix "String or binary data would be truncated" on `varchar` columns (LDEV-4150) 🐛
* Add support for `this.ormSettings.autogenmap = false` (LDEV-3525) 🤖

### Build Improvements

* API docs are now auto-generated with Maven and committed to `docs/` 📖
* One-liner to build and test the extension, along with README build/test/contribution docs 🔨
* Auto-formatting of all Java source code via `formatter-maven-plugin` 🤖
* Automatic compilation test on java 8, 11 and 17 🤖

### In The Works

* Support for configuring the [Hibernate Flush mode](https://docs.jboss.org/hibernate/orm/5.4/javadocs/org/hibernate/FlushMode.html) (MANUAL, COMMIT, AUTO, ALWAYS)
* Support for [MS SQL's `SNAPSHOT` isolation level](https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/sql/snapshot-isolation-in-sql-server)
* Improved logging
* Improved configuration support (both Hibernate and extension-level)
* allow grabbing the current DB connection
* Faster ORM reloads
* Better connection management (fix open connection issues)
* Fix open/orphaned session issues causing memory leaks
* Drop hardcoded Hibernate dependencies from Lucee core
  * Entire `lucee.runtime.orm` package
  * drop hardcoded ORM engine def from Lucee core
* `getORMEngine()` - CFML method to retrieve the ORM engine
* Better support for entity lock modes
* Reduce use of reflection

## Contributing

### Dependencies

* the Java JRE
* the Java JDK
* [ant](https://www.osradar.com/install-apache-ant-ubuntu-20-04/)
* [maven](https://linuxize.com/post/how-to-install-apache-maven-on-ubuntu-20-04/)

### Getting Started

1. Install this repo - `git clone git@github.com:michaelborn/extension-hibernate-fork.git`
2. Check out the `FORK` branch - `git checkout FORK`
3. Make changes..
4. Lint / validate via `ant compile`
5. [Build extension via `ant dist`](#building)
6. [Test via `./test.sh`](#testing)

**Before you send a PR:**

1. Don't forget to run tests!
   1. (if you can't get tests to pass, ask for help!)
2. Format java source code: `mvn formatter:format`

## Building

Using ant builds (for now):

* `ant clean` - clean build directories
* `ant compile` - compile code
* `ant dist` - Package the extension into a Lucee-installable `.lex` extension file

Using the Maven builds:

* `mvn test` run java-based (junit) tests
* `mvn javadoc:javadoc` generate java docs
* `mvn formatter:format` [format java source](https://code.revelc.net/formatter-maven-plugin/usage.html)

## Testing

See Lucee documentation on [testing-a-lucee-extension-locally](https://docs.lucee.org/guides/working-with-source/building-and-testing-extensions.html#testing-a-lucee-extension-locally).

To run CFML tests against the extension:

1. Check out [lucee/Lucee](https://github.com/lucee/lucee) to the parent directory - `git clone git@github.com:lucee/Lucee.git ../lucee`
2. Check out [lucee/script-runner](https://github.com/lucee/script-runner) to the parent directory - `git clone git@github.com:lucee/Lucee.git ../script-runner`.

Run tests from the extension root:

```bash
./test.sh
```

To build a .lex and test it immediately, chain `ant dist` and `./test.sh`:

```bash
ant dist && ./test.sh
```

### Database Testing

For testing on a specific database platform, create a `.env` file in `tests/` with database credentials:

```bash
cd tests
cp .env.example .env
```

And edit the `MSSQL_*` or `MYSQL_*`, etc. keys to match your database credentials.

This `.env` file will be sourced in as environment variables while running tests via `./test.sh`.

## Thanks

Thanks to Lucee for the hard work and original source code. 👋
