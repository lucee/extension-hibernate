# Testing ORM behaviour on ACF 2025

Use CommandBox to spin up ACF 2025 for verifying behaviour differences between Lucee and ACF.

## Setup

Test apps live under `test-output/acf-*` directories. Each has:

- `server.json` — CommandBox server config with cfengine and cfpm packages
- `.cfconfig.json` — datasource and server settings
- `Application.cfc` — ORM config
- `*.cfm` — test scripts

## Prerequisites

- [CommandBox](https://www.ortussolutions.com/products/commandbox) installed and on PATH
- `commandbox-cfconfig` module (`box install commandbox-cfconfig`)

## Quick start

```bash
cd test-output/acf-ldev4121
box server start
curl http://127.0.0.1:9121/test.cfm
```

## ACF 2025 requires separate packages

ACF 2025 modularised features into cfpm packages. The `server.json` `onServerInitialInstall` script handles this automatically on first start:

```json
{
    "openBrowser": false,
    "scripts": {
        "onServerInitialInstall": "cfpm install orm && cfpm install derby"
    }
}
```

Common packages needed for ORM testing:

- `orm` — Hibernate ORM support (required)
- `derby` — Apache Derby JDBC driver
- `mysql` — MySQL JDBC driver
- `postgresql` — PostgreSQL JDBC driver

Install manually if needed:

```bash
box cfpm install orm
box cfpm install derby
```

## Datasource config

Datasources are defined in `.cfconfig.json`, not `Application.cfc`:

```json
{
    "datasources": {
        "testdb": {
            "dbdriver": "Other",
            "class": "org.apache.derby.jdbc.EmbeddedDriver",
            "dsn": "jdbc:derby:memory:testdb;create=true",
            "host": "",
            "port": "",
            "database": "",
            "username": "",
            "password": ""
        }
    }
}
```

Key differences from Lucee:

- Use `dsn` for the JDBC URL (not `connectionString`)
- Use `dbdriver: "Other"` for raw JDBC connections
- `this.datasources` in Application.cfc does NOT work on ACF for ORM datasources

## Managing servers

```bash
# Start
box server start

# Stop
box server stop

# Full reset (wipe server home, re-download engine)
box server forget --force
box server start

# Check status
box server status
```

## Error handling tip

ACF returns empty 500 responses when ORM init fails. Always add an `onError` handler to your Application.cfc:

```cfml
function onError( e ) {
	writeOutput( "APPLICATION ERROR: #e.message#<br>#e.detail#<br>" );
	if ( structKeyExists( e, "cause" ) && !isNull( e.cause ) ) {
		writeOutput( "CAUSE: #e.cause.message#<br>" );
	}
	writeDump( var: e, output: "console" );
}
```

Without this, you get a blank page and no clue what went wrong.

## Existing test apps

- `test-output/acf-ldev4121/` — property defaults vs DB NULLs (port 9121)
- `test-output/acf-ldev4339/` — ORM sessions in threads (port 9339)
- `test-output/acf-ldev4067/` — closures/lambdas in ORM entities (port 9067) — PASSES on ACF
- `test-output/acf-mappedby/` — mappedby attribute (port 9501) — FAILS on ACF same as Lucee: "property named team must exist in CFC Team"
- `test-output/acf-flush-before-sql/` — entitySave auto-flush before queryExecute (port 9502) — ACF does NOT auto-flush, same as Lucee
