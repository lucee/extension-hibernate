# Breaking Changes

Behaviour changes made for ACF parity. These may affect existing Lucee applications that depend on the previous behaviour.

## Property defaults applied on entity load

**Ticket:** LDEV-4121
**Branch:** 5.6

Previously, when an ORM entity property had `default="foo"` and the database column contained NULL, `entityLoad` returned NULL. Now it returns `"foo"`, matching ACF behaviour.

This also means:

- `ormFlush()` after loading such an entity will write the default value to the database, replacing the NULL
- Properties with `insert="false"` are also affected — if the DB column is NULL, the default is returned regardless of insert/update attributes
- Explicitly setting a property to NULL, saving, and reloading will return the default, not NULL

**Migration:** If your code relies on detecting NULL values from the database for properties that have defaults, you will need to remove the `default` attribute or check the database directly via `queryExecute`.
