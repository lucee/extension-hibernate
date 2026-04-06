component persistent="true" table="OL_Versioned" accessors="true"
	optimisticlock="all" dynamicupdate="true" {

	property name="id"    fieldtype="id" ormtype="string";
	property name="name"  ormtype="string";
	property name="notes" ormtype="string" optimisticlock="false";

}
