# Changelog

## 5.6 (unreleased)

Forked from Lucee 5.4 extension. Upgraded Hibernate 5.4 → 5.6, major code modernisation. Incorporates work from the [Ortus Hibernate extension](https://github.com/ortus-solutions/extension-hibernate), including `persistEntityChangesToState` for entity event mutation support and the `ConfigurationBuilder` pattern.

See [BREAKING-CHANGES.md](BREAKING-CHANGES.md) for behaviour changes that may affect existing applications.

### Bug Fixes

- [LDEV-6156](https://luceeserver.atlassian.net/browse/LDEV-6156) — Fixed connection leak: removed dead reconnect code that borrowed a second connection per session
- [LDEV-6225](https://luceeserver.atlassian.net/browse/LDEV-6225) — JAXB compatibility for Java 17+
- [LDEV-6044](https://luceeserver.atlassian.net/browse/LDEV-6044) — Removed unused `xml-apis` from `Require-Bundle` (caused conflicts)
- [LDEV-4561](https://luceeserver.atlassian.net/browse/LDEV-4561) — Entity events now fire before global event handler, matching ACF
- [LDEV-4121](https://luceeserver.atlassian.net/browse/LDEV-4121) — Property defaults now apply when loading NULL from DB, matching ACF
- [LDEV-2092](https://luceeserver.atlassian.net/browse/LDEV-2092) — `ORMEvictEntity()`/`ORMEvictCollection()` threw "Unknown entity" with multiple datasources. Two fixes: ehcache CacheManager name collision across datasources, and evict methods now target the correct SessionFactory instead of iterating all
- [LDEV-3768](https://luceeserver.atlassian.net/browse/LDEV-3768) — Wrong-case HQL column names now throw helpful error instead of NPE
- [LDEV-3525](https://luceeserver.atlassian.net/browse/LDEV-3525) — Missing `.hbm.xml` with `autogenmap=false` now throws clear error
- Schema export was running against empty `MetadataSources`, silently creating nothing
- DDL errors were silently swallowed — now thrown at startup
- `sqlScript` seed data was wiped by `dbcreate="dropcreate"` — now runs after schema creation
- `haltOnError` broke dropcreate on MySQL/MSSQL — DROP errors now filtered, only CREATE failures throw
- `onEvict` global event handler wasn't receiving the entity

### New Features

- [LDEV-6159](https://luceeserver.atlassian.net/browse/LDEV-6159) — Native ORM logging into `orm.log` (when configured at server level), replacing SLF4J/Logback with Lucee native logging. New ormSettings: `logSQL`, `logParams`, `logCache`, `logLevel`
- `ORMFlushAll()` BIF — flush all datasource ORM sessions
- `ORMIndex()`, `ORMIndexPurge()`, `ORMSearch()`, `ORMSearchOffline()` stub BIFs (Hibernate Search not supported — throw informative errors instead of "function not found")

### Internal

- Hibernate 5.4.33 → 5.6.15
- Migrated build from Ant to Maven (shaded fat jar)
- Restructured packages to match Ortus layout
- Removed unused internal classes
- CI rewritten: matrix builds across Lucee 6.2/7.0/7.1, Java 11/21/25, MySQL/MSSQL/Postgres
