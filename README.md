# Lucee Hibernate Extension (ORM)

[![Java CI](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml/badge.svg?branch=5.4)](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml) 5.4

[![Java CI](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml/badge.svg?branch=3.5.5)](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml) 3.5.5

[![Java CI](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml/badge.svg)](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml) Master

* A [Hibernate ORM](https://hibernate.org/orm/) wrapper for the [Lucee CFML language](https://www.lucee.org/)

* Issues: https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22orm%22
* Documentation: https://docs.lucee.org/categories/orm.html

## Contributing

You will need to install the following for extension development:

* Java 1.8+ (JRE and JDK)
* [ant](https://www.osradar.com/install-apache-ant-ubuntu-20-04/)
* [maven](https://linuxize.com/post/how-to-install-apache-maven-on-ubuntu-20-04/)

### Getting Started

1. Install the repo - `git clone git@github.com:lucee/extension-hibernate.git`
2. Make changes..
3. [Build extension via `ant dist`](#building)
4. Test via `./test.sh` (See [#Testing](#testing) for more info)

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
* `mvn verify` Run OWASP dependency checker to look for vulnerabilities

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