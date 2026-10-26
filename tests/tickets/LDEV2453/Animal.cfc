component persistent="true" table="ldev2453_animal" {
	property name="id" fieldtype="id" ormtype="integer" generator="increment";
	property name="name" ormtype="string";
	property name="notStored" persistent="false";
}
