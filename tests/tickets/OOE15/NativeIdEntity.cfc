component persistent="true" accessors="true" table="OOE15_NativeId" {

	// No explicit ormtype — Lucee's internal "numeric" type should map to "integer"
	// for native generator IDs, not "double"
	property name="id" fieldtype="id" generator="native" notnull="true" default="0" unsavedvalue="0";
	property name="name" ormtype="string";

}
