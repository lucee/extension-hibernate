component persistent="true" table="MB_Team" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="players"
		fieldtype="one-to-many"
		cfc="Player"
		mappedby="team"
		type="array";

}
