# Developing the Ortus ORM Extension

You will need to install the following for extension development:

* Java 1.8+ (JRE and JDK)
* [ant](https://www.osradar.com/install-apache-ant-ubuntu-20-04/) (for building the extension `.lex` file)
* [maven](https://linuxize.com/post/how-to-install-apache-maven-on-ubuntu-20-04/) (for other automated tooling)
* Optional: [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) (for managing test database servers)

## Getting Started

1. Install the repo - `git clone git@github.com:ortus-solutions/extension-hibernate.git`
2. Make changes..
3. [Build extension via `mvn package`](#building)
4. Test via `./test.sh` (See [#Testing](#testing) for more info)

**Before you send a PR:**

1. Don't forget to run tests!
   1. (if you can't get tests to pass, ask for help!)
2. Format java source code: `mvn formatter:format`

## Building

* `mvn clean` clean build directories
* `mvn package` Package the extension into a Lucee-installable `.lex` extension file
* `mvn test` run java-based (junit) tests
* `mvn javadoc:javadoc` generate java docs
* `mvn formatter:format` [format java source](https://code.revelc.net/formatter-maven-plugin/usage.html)
* `mvn verify` Run OWASP dependency checker to look for vulnerabilities

## Testing

See Lucee documentation on [testing-a-lucee-extension-locally](https://docs.lucee.org/guides/working-with-source/building-and-testing-extensions.html#testing-a-lucee-extension-locally).

To run CFML tests against the extension:

1. Check out [lucee/Lucee](https://github.com/lucee/lucee) to the parent directory - `git clone git@github.com:lucee/Lucee.git ../lucee`
2. Check out [lucee/script-runner](https://github.com/lucee/script-runner) to the parent directory - `git clone git@github.com:lucee/Lucee.git ../script-runner`.

Next, start the test databases using the Docker-compose setup:

```bash
cd tests && docker-compose up
```

This will start Postgres, MySQL, and MSSQL containers using the credentials specified in `tests/.env`.

Finally, you can run tests from the extension root:

```bash
./test.sh
```

To build a .lex and test it immediately, chain `mvn clean package` and `./test.sh`:

```bash
mvn clean package && ./test.sh
```

## Publishing a Release

Releasing is *mostly* automated. You will need to, at a minimum:

1. Merge all changes to `master`
2. Add changelog notes to `CHANGELOG.md`
3. Bump the build number
4. Commit `build.number` and `CHANGELOG.md` changes
5. Create a git tag with the new version number
6. Push up the tag via `git push --tags`

The `bump.sh` program automates the above steps. To use it, simply:

1. Add changelog notes to `CHANGELOG.md`
2. Run `bump.sh 1.2.3.4` where `1.2.3.4` is the version you wish to release.

Once the git tag is pushed, the `release` GitHub workflow will kick in and:

1. compile and test the extension
2. format all java source code
3. create javadocs
4. push up the built artifact to S3
5. push up javadocs to S3
6. publish the extension to Forgebox
7. create a GitHub release with changelog release notes