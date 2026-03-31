# Hibernate ORM Extension for Lucee

## Folder Structure

- `/source/java/src`: Java source code (`org.lucee.extension.orm.hibernate`)
- `/source/java/libs`: Dependency jars (Hibernate 5.6, byte-buddy, jboss-logging, etc.)
- `/source/fld`: Function Library Descriptor files (ORM BIF registration)
- `/tests`: CFML test suite (TestBox, `_InternalRequest` pattern)
- `/test-output`: Test output files (not committed)

## Build & Test

Always pipe output to a file under `/test-output`.

- Build: `ant clean`
- Build + test: `test.bat` (runs `mvn package` then script-runner)
- Build requires Java 11+

## Debugging

Use `aprint.o()` for debug output in Java code — NOT `System.out.println()`.

```java
import org.lucee.extension.orm.hibernate.util.aprint;

aprint.o("debug message: " + someValue);
```

`aprint` writes to Lucee's system output stream, which is captured by script-runner. `System.out.println` goes to the Ant process stdout and is swallowed.

**WARNING**: Do not use `aprint` inside event listeners (`onPreInsert`, `onPreUpdate`, etc.) — it can cause `StackOverflowError` if the output triggers ORM operations. Use CFML `systemOutput()` in test `.cfm` files instead.

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

## Key Architecture

- **EventListenerIntegrator**: Hibernate event → CFC event bridge. Entity events fire before global (LDEV-4561). `persistEntityChangesToState()` syncs CFC mutations back to Hibernate state.
- **CHECK_NULLABILITY=false**: Hibernate's built-in null check is disabled so entity `preInsert`/`preUpdate` handlers can set missing values before our EventListenerIntegrator runs the check.
- **Logging**: JBoss Logging → Lucee bridge (`LuceeJBossLoggerProvider`). Configured via ormSettings: `logSQL`, `logParams`, `logCache`, `logLevel`.
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
