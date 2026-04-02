# ORM Logging

ORM logging has two filters. Both must pass for a message to appear in `orm.log`.

## 1. ormSettings flags

Boolean flags in `this.ormSettings` in your `Application.cfc` control which categories of
Hibernate logging are enabled. By default everything is off — Hibernate is extremely chatty.

```cfml
this.ormSettings = {
    logSQL      = true,   // SQL statements (SELECT, INSERT, DDL, etc.)
    logParams   = true,   // bound parameter values
    logCache    = true,   // second-level / query cache activity
    formatSQL   = true,   // pretty-print SQL (off by default, has a performance cost)
    logVerbose  = true    // all other Hibernate logging (startup, mapping, session lifecycle)
};
```

These flags are the **muzzle** — they control whether Hibernate even generates the log message.
With all flags off, Hibernate's internal logging is completely silenced.

Notes:

- `logParams` without `logSQL` is pointless — `logParams` implies `logSQL`.
- `formatSQL` reformats every SQL string. Leave it off unless you're actively debugging.
- `logVerbose` is extremely noisy. Only enable it when debugging Hibernate internals.

## 2. Lucee orm log level

The `orm` log in Lucee Admin (or via `Application.cfc` log config) has its own severity level.
This is the **pipe** — messages below the configured level are dropped even if the muzzle is open.

Set the Lucee orm log level to **DEBUG** for SQL and cache logging, or **TRACE** if you also want parameter bindings.

## How they work together

```
logSQL=true, Lucee orm log = DEBUG   →  SQL visible
logSQL=true, Lucee orm log = WARN    →  nothing (DEBUG < WARN, filtered by Lucee)
logParams=true, Lucee orm log = DEBUG →  nothing (params are TRACE, filtered by Lucee)
logParams=true, Lucee orm log = TRACE →  params visible
logSQL=false, Lucee orm log = TRACE   →  nothing (muzzle closed)
```

## Extension logging

The extension itself (not Hibernate) also logs to the orm log. These messages are **not**
controlled by the ormSettings flags — only the Lucee orm log level applies.

| Level | What |
|---|---|
| ERROR | Schema export failures, mapping errors |
| WARN | Missing columns, property mapping issues, type conversion warnings |
| DEBUG | Session lifecycle, connection management |

## Java internals

For contributors and anyone debugging the logging bridge itself:

- Hibernate uses JBoss Logging internally. The extension registers `LuceeJBossLoggerProvider`
  via `META-INF/services`, routing all Hibernate log output to Lucee's `orm` log.
- `LuceeJBossLogger.isEnabled()` checks the ormSettings flags for the current request's
  application context via a ThreadLocal. If the flag is off, the message is dropped before
  Hibernate does any string formatting — this is the performance gate.
- The Hibernate categories map to JBoss Logger names:
  - `org.hibernate.SQL` — SQL statements (`logSQL`)
  - `org.hibernate.type.descriptor.sql` — parameter bindings (`logParams`)
  - `org.hibernate.cache` / `net.sf.ehcache` — cache activity (`logCache`)
  - Everything else — general Hibernate logging (`logVerbose`)
- `formatSQL` maps to Hibernate's `hibernate.format_sql` property on the `SqlStatementLogger`.
  When enabled, every SQL string is reformatted before logging — visible in JFR as CPU overhead.
