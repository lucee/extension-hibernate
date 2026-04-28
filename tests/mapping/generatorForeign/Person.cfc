// Owning side — generates its own ID natively.
component persistent="true" table="person_entity" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// PersonDetail shares the same id (one-to-one shared primary key).
	property name="detail" fieldtype="one-to-one" cfc="PersonDetail" cascade="all";
}
