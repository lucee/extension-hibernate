component persistent="true" table="HqlBook" accessors="true" {

	property name="id"    fieldtype="id" ormtype="integer" generator="assigned";
	property name="title" ormtype="string";
	property name="price" ormtype="big_decimal";
	property name="author"
		fieldtype="many-to-one"
		cfc="HqlAuthor"
		fkcolumn="authorId";

}
