component persistent="true" table="FKN_Child" accessors="true" {

	property name="id"     fieldtype="id" ormtype="string";
	property name="parent"
		fieldtype="many-to-one"
		cfc="FKParent"
		fkcolumn="parentId"
		foreignkey="FK_child_parent";

}
