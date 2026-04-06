// Table-per-hierarchy subclass: discriminated by "truck"
component persistent="true" extends="Vehicle" accessors="true"
	discriminatorValue="truck" {

	property name="payload" ormtype="double";

}
