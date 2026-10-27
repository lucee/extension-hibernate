# Lucee Hibernate Extension (ORM)

[![Java CI](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml/badge.svg?branch=7.4)](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml)

Built using [Hibernate ORM 7.4.14](https://hibernate.org/orm/) on Java 21.

> **Heads up:** this is the `7.4` migration branch (Hibernate 7.4.14). The
> shipping LTS is the `5.6` branch (Hibernate 5.6, Lucee 6.2.5.48+). See
> [History](#history) below.

Install via Lucee Admin, or pin in your environment:

```bash
# Maven coordinates, auto-updates to latest snapshot
LUCEE_EXTENSIONS=org.lucee:hibernate-extension:7.4.14.0-SNAPSHOT
```

See [Lucee Compatibility](#lucee-compatibility) for minimum supported versions.

## History

- **Hibernate 7.4 (branch `7.4`, this branch)** — major upgrade. Hibernate 7 completes the **`javax.persistence` → `jakarta.persistence`** namespace migration (Jakarta Persistence 3.2), requires Java 21, and reshapes large parts of the API surface. Criteria rewritten to JPA `CriteriaBuilder`, schema work moved to `SchemaManager`, EHCache dropped in favour of Caffeine/JCache, dialect aliases collapsed to version-agnostic families, HQL parser is now strict on identifier casing, and several `SessionFactory` metadata APIs were removed (the extension restores a compat shim for cborm/ColdBox/Slatwall). **Not backwards-compatible** — see [BREAKING-CHANGES.md](BREAKING-CHANGES.md). Tracked under [LDEV-6292](https://luceeserver.atlassian.net/browse/LDEV-6292).
- **Hibernate 5.6 (branch `5.6`, current LTS)** — Lucee resumed active development, merging the Ortus work and upgrading 5.4 → 5.6 with native logging, transaction integration, and expanded test coverage. Bug fixes and minor features land here.
- **Ortus fork** — Ortus Solutions forked the extension, completed the Hibernate 5.4 upgrade, and maintained it.
- **Lucee 5.4 (beta)** — Lucee began upgrading to Hibernate 5.4 but it only reached beta.
- **Extension extraction** — ORM was pulled out of Lucee core into a standalone extension.
- **Lucee core (Hibernate 3.5)** — ORM was originally built into Lucee core.

> Hibernate 7.3 deleted a lot of API surface that CFML libraries depend on. Where Lucee can transparently keep your code working, we will (`SessionFactory` metadata methods, `Session` legacy methods via opt-in shim CFCs). Where Hibernate's behaviour itself changed, we document it in [BREAKING-CHANGES.md](BREAKING-CHANGES.md) and you'll need to adapt.

## Lucee Compatibility

Lucee 7.0 or newer is required. The extension declares `luceeCoreVersion: 7.0.4.34` in `build.properties`.

| Lucee line | Minimum release |
| ---------- | --------------- |
| 7.0        | 7.0.4.34        |
| 7.1        | 7.1.0.204       |

The extension and its libraries are loaded as Maven libraries instead of an OSGi bundle, which needs Lucee 7.0. The minimum releases are the first ones with the [LDEV-6291](https://luceeserver.atlassian.net/browse/LDEV-6291) fix for `DatasourceConnectionImpl.prepareStatement`, which Hibernate 7.3's strict JDBC holdability check trips on.

Lucee 6.2 and earlier Lucee 7 patches are not supported on this branch — use the `5.6` branch of the extension instead.

## Using Hibernate classes from CFML

The extension and Hibernate are Maven libraries, not an OSGi bundle anymore. `createObject("java", "org.hibernate...")` without a Maven coordinate no longer finds Hibernate classes. Pass the Maven coordinate of the installed extension, so you get the same classes the ORM uses:

```cfml
hibernateVersion = createObject( "java", "org.hibernate.Version", { maven: [ "org.lucee:hibernate-extension:7.4.14.0" ] } );
writeOutput( hibernateVersion.getVersionString() );
```

The coordinate has to match the installed extension version. To avoid hard-coding it:

```cfml
for ( ext in extensionList() ) {
	if ( ext.id == "FAD1E8CB-4F45-4184-86359145767C29DE" ) hibernateMaven = "org.lucee:hibernate-extension:" & ext.version;
}
criteriaBuilder = createObject( "java", "org.hibernate.query.criteria.HibernateCriteriaBuilder", { maven: [ hibernateMaven ] } );
```

The third argument must be a struct with a `maven` array. A plain string is treated as an OSGi bundle name and fails.

See [Configuration](https://docs.lucee.org/recipes/orm-configuration.html) and [Migration Guide](https://docs.lucee.org/recipes/orm-migration-guide.html) for details.

## Documentation

- [Getting Started](https://docs.lucee.org/recipes/orm-getting-started.html)
- [Configuration](https://docs.lucee.org/recipes/orm-configuration.html)
- [Entity Mapping](https://docs.lucee.org/recipes/orm-entity-mapping.html)
- [Relationships](https://docs.lucee.org/recipes/orm-relationships.html)
- [Session & Transactions](https://docs.lucee.org/recipes/orm-session-and-transactions.html)
- [Querying (HQL & Criteria)](https://docs.lucee.org/recipes/orm-querying.html)
- [Events](https://docs.lucee.org/recipes/orm-events.html)
- [Caching](https://docs.lucee.org/recipes/orm-caching.html)
- [Logging](https://docs.lucee.org/recipes/orm-logging.html)
- [Migration Guide (ACF to Lucee)](https://docs.lucee.org/recipes/orm-migration-guide.html)
- [Troubleshooting](https://docs.lucee.org/recipes/orm-troubleshooting.html)

Full category listing: https://docs.lucee.org/categories/orm.html

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full list of bug fixes, new features, and improvements.

See [BREAKING-CHANGES.md](BREAKING-CHANGES.md) for behaviour changes that may affect existing applications — the Hibernate 5.6 → 7.4 jump introduces several.

## Issues

https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22orm%22
