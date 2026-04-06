// Table-per-concrete-class subclass (union)
component persistent="true" extends="Shape" accessors="true"
	table="TPC_Circle" {

	property name="radius" ormtype="double";

}
