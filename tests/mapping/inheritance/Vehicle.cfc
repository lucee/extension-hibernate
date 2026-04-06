// Table-per-hierarchy base entity
component persistent="true" table="TPH_Vehicle" accessors="true"
	discriminatorColumn="vehicle_type" discriminatorValue="vehicle" {

	property name="id"    fieldtype="id" ormtype="string";
	property name="make"  ormtype="string";
	property name="model" ormtype="string";

}
