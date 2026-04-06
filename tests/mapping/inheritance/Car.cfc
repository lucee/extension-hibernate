// Table-per-hierarchy subclass: discriminated by "car"
component persistent="true" extends="Vehicle" accessors="true"
	discriminatorValue="car" {

	property name="doors" ormtype="integer";

}
