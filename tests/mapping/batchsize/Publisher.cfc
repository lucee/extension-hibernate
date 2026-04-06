component persistent="true" table="BS_Publisher" accessors="true" batchsize="5" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="books"
		fieldtype="one-to-many"
		cfc="Book"
		fkcolumn="publisherId"
		type="array"
		lazy="true"
		batchsize="10";

}
