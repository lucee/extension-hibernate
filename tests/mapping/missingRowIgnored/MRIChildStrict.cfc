// missingRowIgnored=false (default) — missing FK target throws exception
component persistent="true" table="MRI_ChildStrict" accessors="true" {

	property name="id"     fieldtype="id" ormtype="string";
	property name="name"   ormtype="string";
	property name="parent"
		fieldtype="many-to-one"
		cfc="MRIParent"
		fkcolumn="parentId"
		missingRowIgnored="false";

}
