component persistent="true" extends="BaseEntity" accessors="true" table="OOE16_Keeps" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

	// Does NOT override legacyCode — should inherit it as persistent
}
