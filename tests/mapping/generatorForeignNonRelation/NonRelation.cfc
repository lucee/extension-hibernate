// generator="foreign" params={property='name'} — the `name` property exists
// but it's a plain string column, not a one-to-one relation (no cfc= attribute).
// After LDEV-6343 lands, ORM init should throw a localized error.
component persistent="true" table="non_relation" accessors="true" {
	property name="id"   fieldtype="id" generator="foreign" params="{property='name'}";
	property name="name" ormtype="string" length="100";
}
