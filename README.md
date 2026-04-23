# Lucee Hibernate Extension (ORM)

[![Java CI](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml/badge.svg?branch=5.6)](https://github.com/lucee/extension-hibernate/actions/workflows/main.yml)

Built using [Hibernate ORM 5.6](https://hibernate.org/orm/)

Install via Lucee Admin, or pin in your environment:

```bash
# Lucee 7.0+ (Maven coordinates, auto-updates to latest snapshot)
LUCEE_EXTENSIONS=org.lucee:hibernate-extension:5.6.15.15-RC

# Lucee 6.2 (extension GUID, pinned version)
LUCEE_EXTENSIONS=FAD1E8CB-4F45-4184-86359145767C29DE;version=5.6.15.15-RC
```

## History

1. **Lucee core (Hibernate 3.5)** — ORM was originally built into Lucee core
2. **Extension extraction** — ORM was pulled out of core into a standalone extension
3. **Lucee 5.4 (beta)** — Lucee began upgrading to Hibernate 5.4 but it only reached beta
4. **Ortus fork** — Ortus Solutions forked the extension, completed the Hibernate 5.4 upgrade, and maintained it
5. **Lucee 5.6 (current)** — Lucee resumed active development, merging the Ortus work and upgrading to Hibernate 5.6 with native logging, transaction integration, and expanded test coverage

## Lucee Compatibility

- **Lucee 6.2.5.48+** — full support for core ORM functionality
- **Lucee 7.0.4+** — adds `dbcreate` modes: `create`, `create-drop`, `validate`
- **Lucee 7.1+** — adds `cftransaction` isolation level support for ORM

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

See [CHANGELOG.md](CHANGELOG.md) for the full list of bug fixes, new features, and improvements in 5.6.

See [BREAKING-CHANGES.md](BREAKING-CHANGES.md) for behaviour changes that may affect existing applications.

## Issues

https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22orm%22
