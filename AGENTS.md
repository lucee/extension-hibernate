# Hibernate ORM Extension for Lucee

## Folder Structure

- `/source/java/src`: Java source code (`org.lucee.extension.orm.hibernate`)
- `/source/java/libs`: Dependency jars (Hibernate 5.6, byte-buddy, jboss-logging, etc.)
- `/source/fld`: Function Library Descriptor files (ORM BIF registration)
- `/tests`: CFML test suite (TestBox, `_InternalRequest` pattern)
- `/test-output`: Test output files (not committed)

## Build & Test

Always pipe output to a file under `/test-output`.

- Build: `mvn package`
- Build + test: `test.bat` (runs `mvn package` then script-runner)
- Build requires Java 21+

## Accesing JIRA

to read a jira ticket like https://luceeserver.atlassian.net/browse/LDEV-4339
rewrite it as xml https://luceeserver.atlassian.net/si/jira.issueviews:issue-xml/LDEV-4339/LDEV-4339.xml

## Debugging

Use `aprint.o()` for debug output in Java code — NOT `System.out.println()`.

```java
import org.lucee.extension.orm.hibernate.util.aprint;

aprint.o("debug message: " + someValue);
```

`aprint` writes to Lucee's system output stream, which is captured by script-runner. `System.out.println` goes to the Ant process stdout and is swallowed.

**WARNING**: Do not use `aprint` inside event listeners (`onPreInsert`, `onPreUpdate`, etc.) — it can cause `StackOverflowError` if the output triggers ORM operations. Use CFML `systemOutput()` in test `.cfm` files instead.

## Verbose Hibernate logging

To see Hibernate's internal logging (schema tools, session lifecycle, etc.):

1. Set `logVerbose: true` in `this.ormSettings` — enables the extension's muzzle for all Hibernate categories
2. Set the orm log to TRACE level via `configImport` in beforeAll() (see `tests/logging/logging.cfc` for the pattern)
3. Set `LUCEE_LOGGING_FORCE_APPENDER=console` in the test bat file to redirect orm.log to console output

Both logVerbose (muzzle) and trace level (pipe) must be set — one without the other won't produce output.

Use the marker pattern from `tests/logging/logging.cfc` to find relevant log sections: write a UUID marker via `cflog(log:"orm")`, then read the orm.log file and extract everything after the marker.

## running tests

all these batch files take test name as the first argument, so you can just run one test if needed for quick turn arounds

`./test7.bat <testfilter>` just runs with 7.0
`./test.bat <testfilter>` runs with 6.2, 7.0 and 7.1 (Slower)
`./testJar.bat <path-to-lucee.jar>` runs with a custom Lucee JAR build

use test7.bat for initial dev, use test.bat to check finally

## H2 limitations

Do NOT use H2 for transaction tests — H2's transaction isolation behaviour differs from real databases. Transaction tests (isolation, rollback-after-flush, mixed ORM+SQL, error rollback) belong in `tests/db/mysql/` and `tests/db/postgres/`. H2 tests in `tests/session/transactions/` are basic plumbing smoke tests only.

## Test Approach

Tests use the `_InternalRequest` pattern with isolated `Application.cfc` per test group.

- Each test `.cfm` echoes `"ok"` on success or throws on failure
- Test specs extend `org.lucee.cfml.test.LuceeTestCase` with `labels="orm"`
- H2 in-memory databases for isolation
- `onRequestStart` cleanup, not teardown — artifacts left for inspection
- Tests run via `lucee/script-runner` or CI (`lucee/script-runner@main` GitHub Action)

## CI

Follows the crypto extension pattern: build → test (matrix) → deploy (manual).

- Lucee versions: 7.0/snapshot/light, 7.1/snapshot/light
- MySQL service container for DB tests
- Deploy only via `workflow_dispatch` with `deploy=true`

When a run fails, download all the logs to a temp dir and grep that

## Key Architecture

- **EventListenerIntegrator**: Hibernate event → CFC event bridge. Entity events fire before global (LDEV-4561). `persistEntityChangesToState()` syncs CFC mutations back to Hibernate state.
- **CHECK_NULLABILITY=false**: Hibernate's built-in null check is disabled so entity `preInsert`/`preUpdate` handlers can set missing values before our EventListenerIntegrator runs the check.
- **Logging**: JBoss Logging → Lucee bridge (`LuceeJBossLoggerProvider`). Configured via ormSettings: `logSQL`, `logParams`, `logCache`, `formatSQL`. See `LOGGING.md`.
- **ConnectionProviderImpl**: Single connection per session via Lucee's datasource pool. No double-borrow (LDEV-6156).

## Package Layout (matches Ortus structure)

```
org.lucee.extension.orm.hibernate
├── event/          # Hibernate event listeners
├── functions/      # ORM BIF implementations (EntitySave, EntityLoad, etc.)
├── jdbc/           # ConnectionProviderImpl, DataSourceConfig
├── logging/        # JBoss Logging → Lucee bridge
├── mapping/        # HBMCreator, CFConstants, DBSchemaLoader
├── naming/         # Naming strategies
├── tuplizer/       # Entity tuplizer (CFC ↔ Hibernate)
└── util/           # CommonUtil, ExceptionUtil, HibernateUtil, etc.
```
