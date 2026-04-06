// Table-per-concrete-class base entity (union subclass)
component persistent="true" table="TPC_Shape" accessors="true" {

	property name="id"    fieldtype="id" ormtype="string";
	property name="color" ormtype="string";

}
