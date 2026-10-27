# Breaking Changes

Behaviour changes that may affect existing Lucee applications.

## Hibernate 5.6 → 7.3.2 (extension 7.0)

### Java 21 required

The extension targets Java 21. Java 11 and 17 are no longer supported.

### Lucee 7.1+ required

Hibernate 7.3's strict JDBC holdability check trips a long-standing bug in Lucee's `DatasourceConnectionImpl.prepareStatement(sql, type, concur)`. Fixed in Lucee 7.1.0.107+ ([LDEV-6291](https://luceeserver.atlassian.net/browse/LDEV-6291)). The extension will not run on earlier Lucee versions.

### HQL identifiers are case-sensitive

Hibernate 7.3's HQL parser is strict on identifier case. Property and entity references must match the case declared in the CFC. HQL like `where userName = :n` against a property `UserName` now throws `Could not interpret path expression`.

**Migration:** Match the case in your HQL to the property/entity declarations. Hibernate 5.x was tolerant; this is now an error.

### Dialect aliases collapsed

H7.3 removed all version-specific dialects (`MySQL8Dialect`, `Oracle12cDialect`, `PostgreSQL10Dialect`, etc.). Version detection is now metadata-driven on a single `MySQLDialect`/`OracleDialect`/`PostgreSQLDialect`/etc.

The extension routes the historical aliases to the new version-agnostic class. 24 community-only dialects (Derby, Firebird, HSQL, Informix, Ingres, etc.) are no longer bundled.

**Migration:** Drop the version suffix from `ormSettings.dialect`. Setting `dialect="MySQL"` is now equivalent to `dialect="MySQL8Dialect"`.

### `<bag>` no longer dedups `select distinct ... join fetch`

CFML `property type="array"` maps to Hibernate `<bag>`. H7 stopped de-duplicating the result list for `select distinct ... join fetch <bag>` queries — duplicates from the join are returned as-is.

**Migration:** Apply distinct in your CFML code, or restructure the query to avoid the join-fetch + distinct combo.

### Read-only enforced on collections

H5.6 honoured `readOnly` on scalar properties but silently mutated read-only collections. H7.3 enforces it on both. Code that wrote to a read-only collection used to silently succeed; it now throws.

**Migration:** Remove `readOnly="true"` from collections you actually write to.

### `scale` not allowed on `ormtype="double"`

H7.3 rejects `scale` on `double`/`float` properties at SF-build time. Pre-7.3 silently accepted it.

**Migration:** Remove the `scale` attribute, or change the type to `big_decimal` (where scale applies).

### `org.hibernate.Criteria` removed

H6+ removed the legacy `org.hibernate.Criteria` API entirely. Only JPA `CriteriaBuilder` remains.

**Migration:** Anyone calling `session.createCriteria()` from CFML directly must rewrite using `session.getCriteriaBuilder()`. CFML BIFs (`entityLoad`, `entityLoadByExample`) are unaffected — they're rebuilt on the JPA API internally.

### EHCache 2 → Caffeine via JCache

The bundled L2 cache provider changed from EHCache 2 to Caffeine via `hibernate-jcache`. Existing `ehcache.xml` configurations are no longer read. Per-region defaults are wired through Caffeine's `reference.conf` (10000 entries, 120s TTL/TTI).

**Migration:** Tune via `reference.conf` overrides if the defaults don't suit. Don't bundle EHCache 3 alongside — single JCache provider per OSGi extension.

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
