component persistent="true" table="IX_Indexed" accessors="true" {

	property name="id"    fieldtype="id" ormtype="string";
	property name="email" ormtype="string" index="idx_email";

}
