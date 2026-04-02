component accessors="true" persistent="true" table="gen_sequence" {
	property name="id"   fieldtype="id" ormtype="long" generator="sequence" sequence="gen_sequence_seq";
	property name="name" ormtype="string";
}
