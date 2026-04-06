component persistent="true" table="HqlAuthor" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="assigned";
	property name="name" ormtype="string";
	property name="books"
		fieldtype="one-to-many"
		cfc="HqlBook"
		fkcolumn="authorId"
		type="array"
		lazy="true";

}
