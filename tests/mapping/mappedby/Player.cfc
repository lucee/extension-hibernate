component persistent="true" table="MB_Player" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="team"
		fieldtype="many-to-one"
		cfc="Team"
		fkcolumn="teamId";

}
