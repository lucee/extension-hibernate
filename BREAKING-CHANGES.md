# Breaking Changes

Behaviour changes in 5.6 that may affect existing Lucee applications.

## Property defaults applied on entity load ([LDEV-4121](https://luceeserver.atlassian.net/browse/LDEV-4121))

When a property has `default="foo"` and the DB column is NULL, `entityLoad` now returns `"foo"` instead of NULL, matching ACF. This means `ormFlush()` will write the default to the database, replacing the NULL. Properties with `insert="false"` are also affected.

**Migration:** Remove the `default` attribute from properties where you need to detect NULLs.

## Hibernate 5.4 → 5.6

- **Stricter HQL parsing** — some HQL that 5.4 accepted loosely may now throw
- **H2 dialect targets v1.x** — Lucee bundles H2 v2.x which changed FK constraint handling. Use `dbcreate="dropcreate"` or add `MODE=LEGACY` to your H2 JDBC URL
- **Updated dependencies** — dom4j, commons-collections (3.x → 4.x), byte-buddy, jboss-logging

## Entity events fire before global event handler ([LDEV-4561](https://luceeserver.atlassian.net/browse/LDEV-4561))

Entity-level events now fire before the global `ormSettings.eventHandler`, matching ACF. Previously the global handler fired first.

## DDL errors now throw at startup

Schema creation/update errors were previously logged and silently swallowed — ORM would start with missing tables. Now they throw. For `dbcreate="dropcreate"`, DROP errors are still ignored.

## Schema export fixed

`schemaExport()` was running against empty `MetadataSources` and silently doing nothing. It now correctly includes all entity mappings.

## sqlScript seed data no longer wiped

`sqlScript` previously ran before `buildSessionFactory()`, so `dbcreate="dropcreate"` would wipe the seed data. Now runs after. Remove any workarounds for this — they may double-insert.

## Lazy session opening for multiple datasources

ORM sessions are now opened lazily per datasource — only when that datasource is first used in a request. Previously, the `HibernateORMSession` constructor eagerly opened a Hibernate Session for every configured datasource. If you relied on all sessions being open immediately (e.g. checking `isOpen()` before any ORM operation), that code may need adjustment.

## Connection leak fixed ([LDEV-6156](https://luceeserver.atlassian.net/browse/LDEV-6156))

Removed dead reconnect code that borrowed a second connection per session. If you'd increased your pool size to compensate for leaks, you can reduce it.

## ORM logging overhauled ([LDEV-6159](https://luceeserver.atlassian.net/browse/LDEV-6159))

`logSQL: true` was broken. ORM logging now routes through Lucee's native logging via a JBoss Logging bridge. New ormSettings: `logSQL`, `logParams`, `logCache`, `logLevel`.

The Lucee "orm" log level must be set to DEBUG or TRACE for output to appear. SLF4J/Logback configuration no longer applies.
