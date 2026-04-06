// This CFC extends a non-existent base class — should fail to load
component persistent="true" table="SKIP_Broken" accessors="true"
	extends="NonExistentBaseClass" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

}
