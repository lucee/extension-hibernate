<cfscript>
// Probe: shared-PK one-to-one via generator="foreign". Person assigns id natively;
// PersonDetail picks up the same id from its Person reference. Verify SF builds
// + the linked rows survive a round-trip with matching ids.
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
	if ( loaded.getName() != "Alice" )
		throw( message="expected Alice, got [#loaded.getName()#]" );
	if ( isNull( loaded.getDetail() ) )
		throw( message="expected linked PersonDetail, got null" );
	if ( loaded.getDetail().getBio() != "loves Hibernate" )
		throw( message="expected detail bio [loves Hibernate], got [#loaded.getDetail().getBio()#]" );
	if ( loaded.getId() != loaded.getDetail().getId() )
		throw( message="expected shared id; person=[#loaded.getId()#] detail=[#loaded.getDetail().getId()#]" );
	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
