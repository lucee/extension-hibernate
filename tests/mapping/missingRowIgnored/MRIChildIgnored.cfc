// missingRowIgnored=true — missing FK target treated as null, not exception
component persistent="true" table="MRI_ChildIgnored" accessors="true" {

	property name="id"     fieldtype="id" ormtype="string";
	property name="name"   ormtype="string";
	property name="parent"
		fieldtype="many-to-one"
		cfc="MRIParent"
		fkcolumn="parentId"
		missingRowIgnored="true";

}
