// Table-per-subclass base entity
component persistent="true" table="TPS_Person" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

}
