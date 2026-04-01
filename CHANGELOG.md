# Changelog

## 5.6 (unreleased)

Forked from Lucee 5.4 extension. Upgraded Hibernate 5.4 → 5.6, major code modernisation. Incorporates significant work from the [Ortus Hibernate extension](https://github.com/ortus-solutions/extension-hibernate), including package restructuring, `persistEntityChangesToState` for entity event mutation support, `CHECK_NULLABILITY` handling, and the `ConfigurationBuilder` pattern.

### Bug Fixes

- **LDEV-6156** — Fixed connection leak: removed dead reconnect code that borrowed a second connection per session
- **LDEV-6044** — Removed unused `xml-apis` from `Require-Bundle` (caused conflicts)
- **Schema export used empty MetadataSources** — `schemaExport()` created `new MetadataSources(serviceRegistry)` without adding XML mappings. Schema export ran against empty metadata, silently creating no tables. Now passes XML mappings to MetadataSources and throws on DDL errors. Same bug exists in Ortus extension.
- **DDL errors silently swallowed** — `printError()` was called with `throwException=false`, so schema creation errors were only logged, never thrown. ORM would start with missing tables.
- **`setHaltOnError(true)` breaks dropcreate on MySQL/MSSQL** — Hibernate throws immediately on the first DDL error (DROP constraint failures) before CREATE runs. Changed to `setHaltOnError(false)` to collect all errors; `printError` filters drop errors and only throws on CREATE failures. Same bug exists in Ortus extension.
- **sqlScript seed data wiped by HBM2DDL_AUTO** — `executeSQLScript` ran during `schemaExport()` before `buildSessionFactory()`. `HBM2DDL_AUTO=create` in `buildSessionFactory()` then dropped and recreated tables, wiping seed data. Moved sqlScript execution to after `buildSessionFactory()`. Same bug exists in Ortus extension.
- **onEvict entity passthrough** — Fixed global event handler `onEvict` not receiving entity

### New Features

- **LDEV-6159** — Lucee native ORM logging via JBoss Logging bridge. Configurable via `ormSettings`: `logSQL`, `logParams`, `logCache`, `logLevel`
- **ORMFlushAll()** — New BIF to flush all datasource ORM sessions
- **ORMIndex(), ORMIndexPurge(), ORMSearch(), ORMSearchOffline()** — Stub BIFs (Hibernate Search not supported — throw informative errors instead of "function not found")

### Code Modernisation

- Upgraded Hibernate 5.4.33 → 5.6.15
- Restructured packages to match Ortus layout (`util/`, `mapping/`, `event/`, `jdbc/`, `logging/`, `naming/`, `tuplizer/`)
- Removed unused classes: `InterceptorImpl`, `EVComponent`, `CFCProxy`, etc.
- Simplified event firing: fire directly on entity, removed listener registry
- Moved constants: events to `EventListenerIntegrator`, cascades to `CFConstants`
- Added `EntityFinder`, `CFConstants`, `DBSchemaLoader`, `ExtensionUtil`
- Ported `persistEntityChangesToState` from Ortus for entity event mutation support
- Replaced deprecated `ThreadDeath`, added private constructors, updated DTD URL
- Rewritten CI to match crypto extension pattern (matrix builds, service containers)
