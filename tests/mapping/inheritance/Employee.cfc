// Table-per-subclass: joined subclass
component persistent="true" extends="Person" accessors="true"
	joincolumn="person_id" table="TPS_Employee" {

	property name="salary" ormtype="double";

}
