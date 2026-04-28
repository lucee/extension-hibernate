// mutable="false" — entity is read-only after initial insert. Hibernate skips
// dirty-checking and rejects flushes that would modify it.
component persistent="true" table="frozen_entity" mutable="false" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";
}
