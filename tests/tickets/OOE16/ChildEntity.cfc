component persistent="true" extends="BaseEntity" accessors="true" table="OOE16_Child" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

	// Override the parent property and mark it as NOT persistent.
	// ACF respects this; Lucee should too.
	property name="legacyCode" persistent="false";

}
