component persistent="true" accessors="true" {

	property name="id" fieldtype="id" ormtype="string";
	// missing elementtype and elementcolumn — should error
	property name="tags"
		fieldtype="collection"
		type="array"
		table="BC_Tags"
		fkcolumn="parentId";

}
