component persistent="true" table="FS_Article" accessors="true" {

	property name="id"    fieldtype="id" ormtype="string";
	property name="title" ormtype="string";
	property name="author"
		fieldtype="many-to-one"
		cfc="Author"
		fkcolumn="authorId"
		fetch="select";

}
