<cfscript>
// fetch="subselect" on a one-to-many. SF builds, parent + children round-trip,
// touching one parent's collection should trigger an IN-subselect that loads
// collections for all loaded parents in the session.
try {
	transaction {
		p1 = entityNew( "SubselectParent" );
		p1.setName( "ParentOne" );
		entitySave( p1 );

		c1 = entityNew( "SubselectChild" );
		c1.setName( "Kid1" );
		c1.setParent( p1 );
		entitySave( c1 );

		p2 = entityNew( "SubselectParent" );
		p2.setName( "ParentTwo" );
		entitySave( p2 );

		c2 = entityNew( "SubselectChild" );
		c2.setName( "Kid2" );
		c2.setParent( p2 );
		entitySave( c2 );
	}
	ormFlush();
	ormClearSession();

	parents = ormExecuteQuery( "FROM SubselectParent ORDER BY name" );
	if ( arrayLen( parents ) != 2 )
		throw( message="Expected 2 parents, got [#arrayLen( parents )#]" );

	firstKids = parents[ 1 ].getChildren();
	if ( arrayLen( firstKids ) != 1 )
		throw( message="Expected 1 child on ParentOne, got [#arrayLen( firstKids )#]" );

	secondKids = parents[ 2 ].getChildren();
	if ( arrayLen( secondKids ) != 1 )
		throw( message="Expected 1 child on ParentTwo, got [#arrayLen( secondKids )#]" );

	echo( "ok" );
} catch ( any e ) {
	echo( e.message );
}
</cfscript>
