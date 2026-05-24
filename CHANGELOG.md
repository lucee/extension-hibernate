# Changelog

## 5.6.15.17

- [LDEV-6340](https://luceeserver.atlassian.net/browse/LDEV-6340) — Entities extending a `mappedSuperClass="true"` parent no longer log `failed to resolve parent entity` warnings on every SessionFactory build. Mapped superclasses aren't entities, so "parent not registered" is the expected state, not an error
- [LDEV-1697](https://luceeserver.atlassian.net/browse/LDEV-1697) — Tightened entity resolution for `cfc="ns.Name"` references: a dotted ref now requires the matching `/ns` mapping to be declared in the current application. Previously a silent simple-name fallback resolved any registered `Name` entity regardless of namespace — iteration-order-dependent (passed on Windows, failed on Linux). The new throw on unresolvable refs names the source CFC and property: `Cannot resolve entity reference [ns.Name] on property [foo] of [...]`. Matches ACF behaviour

## 5.6.15.16

- [LDEV-1697](https://luceeserver.atlassian.net/browse/LDEV-1697) — Overlapping `ormSettings.cfclocation` entries (parent + child directory) registered the same CFC twice and triggered an ambiguity error. Now deduped by canonical file path, matching ACF behaviour
- ORM logging settings (`logSQL`, `logParams`, `logCache`, `logVerbose`) now refresh per-request in the `HibernateORMSession` ctor, so changes to `this.logs` apply without `ormReload()`

## 5.6.15.15

- [LDEV-6267](https://luceeserver.atlassian.net/browse/LDEV-6267) — Relocate shaded `net.sf.ehcache` classes to `org.lucee.extension.orm.hibernate.shaded.net.sf.ehcache` to prevent `ClassCastException` when the ehcache Lucee extension is also installed. Both extensions loaded the same ehcache classes from different OSGi `BundleClassLoader` instances

## 5.6.15.14

- [OOE-28](https://ortussolutions.atlassian.net/browse/OOE-28) — `NoClassDefFoundError: javax/validation/ValidatorFactory` on Lucee 7+. Lucee 7 exposes `jakarta.validation` via OSGi boot delegation, causing Hibernate's `BeanValidationIntegrator` to think Bean Validation is available — but `TypeSafeActivator` has hard `javax.validation` imports which then fail. Fixed by shading `javax.validation:validation-api` into the extension jar. This was masked locally because script-runner's `pom-jakarta.xml` was missing `jakarta.jakartaee-api`, making its classpath a subset of the real Lucee runtime

## 5.6.15.13

### Improvements

- ORM logging now respects application-level `this.logs` overrides (Lucee 7.0+). Each application can independently control the orm log level without affecting other apps on the server
- Added lifecycle logging at DEBUG level: "ORM initializing", "ORM initialized" (with entity count and settings), and "ormReload()" messages

## 5.6.15.12

### Performance

- [LDEV-6253](https://luceeserver.atlassian.net/browse/LDEV-6253) — ORM flush 61% faster: replaced `Util.replace()` with `String.replace()` in type conversion hot path (zero-alloc on no match), cached resolved SQL type in `CFCGetter` constructor to eliminate repeated string parsing during dirty checking

### Improvements

- Concurrent ORM init race condition: added static lock for `SessionFactory` construction on Lucee 6.2/7.0 (fixed in core on 7.1+)
- Event listener method cache: cache which event methods exist per entity to avoid repeated `ComponentImpl.get()` lookups on every Hibernate event

## 5.6.15.11

### Bug Fixes

- [LDEV-6241](https://luceeserver.atlassian.net/browse/LDEV-6241) — `Version.getVersionString()` returned `[WORKING]` instead of `5.6.15.Final` because the shaded jar manifest was missing `Implementation-Version`. This broke cbORM's version-dependent code paths (SQLHelper, isDirty, criteria projections)

## 5.6.15.10

Forked from Lucee 5.4 extension. Upgraded Hibernate 5.4 → 5.6, major code modernisation. Incorporates work from the [Ortus Hibernate extension](https://github.com/ortus-solutions/extension-hibernate), including `persistEntityChangesToState` for entity event mutation support and the `ConfigurationBuilder` pattern.

See [BREAKING-CHANGES.md](BREAKING-CHANGES.md) for behaviour changes that may affect existing applications.

### Bug Fixes

- [LDEV-1992](https://luceeserver.atlassian.net/browse/LDEV-1992) — `entityMerge()` after `ormClearSession()` threw "could not initialize proxy - no Session" when the entity had lazy relationships
- [LDEV-119](https://luceeserver.atlassian.net/browse/LDEV-119) — `ORMReload()` leaked connections and caused NPE under concurrent load. Sessions are now tracked, idle sessions closed before factory teardown, mid-transaction sessions invalidated for safe cleanup by owning thread
- [LDEV-6156](https://luceeserver.atlassian.net/browse/LDEV-6156) — Fixed connection leak: removed dead reconnect code that borrowed a second connection per session
- [LDEV-6225](https://luceeserver.atlassian.net/browse/LDEV-6225) — JAXB compatibility for Java 17+
- [LDEV-6044](https://luceeserver.atlassian.net/browse/LDEV-6044) — Removed unused `xml-apis` from `Require-Bundle` (caused conflicts)
- [LDEV-4561](https://luceeserver.atlassian.net/browse/LDEV-4561) — Entity events now fire before global event handler, matching ACF
- [LDEV-4121](https://luceeserver.atlassian.net/browse/LDEV-4121) — Property defaults now apply when loading NULL from DB, matching ACF
- [LDEV-2092](https://luceeserver.atlassian.net/browse/LDEV-2092) — `ORMEvictEntity()`/`ORMEvictCollection()` threw "Unknown entity" with multiple datasources. Two fixes: ehcache CacheManager name collision across datasources, and evict methods now target the correct SessionFactory instead of iterating all
- [LDEV-87](https://luceeserver.atlassian.net/browse/LDEV-87) / OOE-16 — `persistent="false"` on a child entity property now correctly excludes inherited MappedSuperClass properties from the mapping
- [LDEV-3768](https://luceeserver.atlassian.net/browse/LDEV-3768) — Wrong-case HQL column names now throw helpful error instead of NPE
- [LDEV-3525](https://luceeserver.atlassian.net/browse/LDEV-3525) — Missing `.hbm.xml` with `autogenmap=false` now throws clear error
- Schema export was running against empty `MetadataSources`, silently creating nothing
- DDL errors were silently swallowed — now thrown at startup
- `sqlScript` seed data was wiped by `dbcreate="dropcreate"` — now runs after schema creation
- `haltOnError` broke dropcreate on MySQL/MSSQL — DROP errors now filtered, only CREATE failures throw
- `onEvict` global event handler wasn't receiving the entity
- Invalid `collectionType` attribute on relationships was silently ignored — now validated at ORM init
- Invalid `ormtype` values produced a Java ClassCastException at the DB layer — now validated at HBM generation with entity/property context
- `ormtype="serializable"` returned the literal string representation instead of the deserialized value
- `entityToQuery()` with a non-entity gave a generic Lucee cast error — now throws with ORM context and chains the original exception
- OOE-10 — timezone property bug fix, corrected "Los_Angelos" typo to "Los_Angeles"
- Multiple datasource connection overhead — sessions are now opened lazily per datasource instead of eagerly for all datasources on every request
- ~15 empty catch blocks across the codebase now log to `orm.log` instead of silently swallowing exceptions
- Fixed typos in error messages: "defintion" → "definition", "terminate" → "determine"
- All error messages now start with a capital letter

### Transaction Fixes

- [LDEV-6234](https://luceeserver.atlassian.net/browse/LDEV-6234) — `cftransaction` now manages real Hibernate transactions. `begin()` calls `trans.begin()`, `commit()` flushes and commits, `end()` commits or rolls back active transactions. Fixed inverted condition in bulk delete. JPA exceptions unwrapped to `DatabaseException` with full cause chain
- [LDEV-6205](https://luceeserver.atlassian.net/browse/LDEV-6205) — `cftransaction isolation=` is now honoured for ORM connections (Lucee 7.1+ only). On older versions, isolation is not applied (same as before)

### New Features

- [LDEV-6159](https://luceeserver.atlassian.net/browse/LDEV-6159) — Native ORM logging into `orm.log` (when configured at server level), replacing SLF4J/Logback with Lucee native logging. New ormSettings: `logSQL`, `logParams`, `logCache`, `logVerbose`
- [LDEV-6207](https://luceeserver.atlassian.net/browse/LDEV-6207) — `isWithinORMTransaction()` BIF. Returns true when a Hibernate transaction is active
- `GetORMTransactionIsolation()` BIF — returns the ORM connection's JDBC isolation level as a string (e.g. "serializable"). Matches the core `getTransactionIsolation()` convention
- `ORMFlushAll()` BIF — flush all datasource ORM sessions
- [LDEV-6239](https://luceeserver.atlassian.net/browse/LDEV-6239) — `dbcreate="validate"` mode — checks every mapped table exists at startup, throws on mismatch *(requires Lucee 7.0.4+)*
- `ORMIndex()`, `ORMIndexPurge()`, `ORMSearch()`, `ORMSearchOffline()` stub BIFs (Hibernate Search not supported — throw informative errors instead of "function not found")

### Internal / Quality

- Thread safety: double-checked locking on session factory init, ConcurrentHashMap for all shared maps

- Hibernate 5.4.33 → 5.6.15
- Migrated build from Ant to Maven (shaded fat jar)
- Restructured packages to match Ortus layout
- Removed unused internal classes
- CI rewritten: matrix builds across Lucee 6.2/7.0/7.1, Java 11/21/25, MySQL/MSSQL/Postgres
