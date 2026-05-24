<cfscript>
// Save a Person + PersonDetail, round-trip, verify the shared integer id.
// SF init must succeed (today it dies at FK constraint DDL). Loaded ids
// must be numeric and equal.
try {
	transaction {
		p = entityNew( "Person" );
		p.setName( "Alice" );

		d = entityNew( "PersonDetail" );
		d.setBio( "loves Hibernate" );
		d.setParent( p );
		p.setDetail( d );

		entitySave( p );
	}
	ormFlush();
	ormClearSession();

	loaded = entityLoad( "Person", p.getId(), true );
	if ( isNull( loaded ) )
		throw( message="entityLoad returned null" );
	if ( isNull( loaded.getDetail() ) )
		throw( message="expected linked PersonDetail, got null" );
	if ( !isNumeric( loaded.getId() ) )
		throw( message="expected numeric Person.id, got [#loaded.getId()#] (#getMetadata( loaded.getId() ).getName()#)" );
	if ( !isNumeric( loaded.getDetail().getId() ) )
		throw( message="expected numeric PersonDetail.id, got [#loaded.getDetail().getId()#]" );
	if ( loaded.getId() != loaded.getDetail().getId() )
		throw( message="shared-pk mismatch: person=[#loaded.getId()#] detail=[#loaded.getDetail().getId()#]" );
	echo( "ok" );
}
catch ( any e ) {
	echo( e.message );
}
</cfscript>
