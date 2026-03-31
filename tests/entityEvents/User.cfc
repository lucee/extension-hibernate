component persistent="true" table="Users" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="name"     type="string";
	property name="username" type="string" notnull="true";
	property name="password" type="string" notnull="true";
	property name="dateCreated" ormType="timestamp";
	property name="dateUpdated" ormType="timestamp";

	function preInsert() {
		setDateCreated( now() );
		if ( isNull( getPassword() ) )
			setPassword( createUUID() );
	}

	function preUpdate() {
		setDateUpdated( now() );
		if ( isNull( getPassword() ) )
			setPassword( createUUID() );
	}

}
