// generator="foreign" params={property='nonexistent'} but the entity has no
// property called "nonexistent". After LDEV-6343 lands, ORM init should throw
// a localized error naming this entity + the bad property reference.
component persistent="true" table="bad_property" accessors="true" {
	property name="id"   fieldtype="id" generator="foreign" params="{property='nonexistent'}";
	property name="name" ormtype="string" length="100";
}
