component persistent="true" table="FS_Author" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="articles"
		fieldtype="one-to-many"
		cfc="Article"
		fkcolumn="authorId"
		type="array"
		fetch="join";

}
