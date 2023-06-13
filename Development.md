# Developing the Ortus ORM Extension

You will need to install the following for extension development:

* Java 1.8+ (JRE and JDK)
* [maven](https://linuxize.com/post/how-to-install-apache-maven-on-ubuntu-20-04/) (for other automated tooling)
* Optional: [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) (for managing test database servers)

## Getting Started

1. Install the repo - `git clone git@github.com:ortus-solutions/extension-hibernate.git`
1. Set up an environment/secrets file - `cp .env.template .env`
3. [Build extension via `mvn package`](#building)
4. Test via `box run-script deploy.local && server restart && testbox run` (See [#Testing](#testing) for more info)

**Before you send a PR:**

1. [Run the test suite](#testing)
   1. (if you can't get tests to pass, ask for help!)
2. Add a note to `CHANGELOG.md` under `## Unreleased` with a summary of the change

## Building

* `mvn clean` clean build directories
* `mvn package` Package the extension into a Lucee-installable `.lex` extension file
* `mvn test` run java-based (junit) tests
* `mvn javadoc:javadoc` generate java docs
* `mvn verify` Run OWASP dependency checker to look for vulnerabilities

## Testing

See Lucee documentation on [testing-a-lucee-extension-locally](https://docs.lucee.org/guides/working-with-source/building-and-testing-extensions.html#testing-a-lucee-extension-locally).

To run CFML tests against the extension:

1. Start the test server using `box server start`
2. Build and deploy the extension source via `box run-script deploy.local`
3. Restart the server to pick up the new extension - `box server restart`
4. Run tests from the extension root with `box testbox run`

For "full" database suite tests, you'll want to start the test databases using Docker-compose `docker-compose up -d`. This will start up MSSQL, MySQL, and Postgres database instances for database-specific tests.
## Publishing a Release

Releasing is *mostly* automated. You will need to, at a minimum:

1. Update `CHANGELOG.md` to move release notes from the `## [Unreleased]` section to a new `### [1.2.3.4] - YYYY-MM-DD` section
2. Run `bump.sh` with a version number to merge to master and push a release commit: `./bump.sh 5.4.29.25`

Once `bump.sh` pushes to `master`, the `release` GitHub workflow will kick in and:

1. compile and test the extension
2. create javadocs
3. push up the built artifact, javadocs, and the logo to S3
4. publish the extension to Forgebox
5. create a git tag
6. create a GitHub release with changelog release notes

## Java IDE

I highly recommend [VS Code](https://code.visualstudio.com/) for java development. More experienced Java developers may appreciate a java-specific IDE like [Intellij](https://www.jetbrains.com/idea/). For VS Code Java support, check out:

* [Extension Pack for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack) - a must for java language support, easy refactoring tools, etc.
* [Refactoring Java](https://code.visualstudio.com/docs/java/java-refactoring) documentation - Keyboard shortcuts for moving methods, renaming variables, the works.