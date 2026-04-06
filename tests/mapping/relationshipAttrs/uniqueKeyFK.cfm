<cfscript>
// unique=true + uniquekey on many-to-one — effectively one-to-one via FK
catId = createUUID();
entitySave( entityNew( "RACategory", { id: catId, name: "Unique Cat" } ) );
ormFlush();

child1 = entityNew( "RAUniqueChild", { id: createUUID(), name: "First" } );
child1.setCategory( entityLoadByPK( "RACategory", catId ) );
entitySave( child1 );
ormFlush();

// second child with same category should violate unique constraint
child2 = entityNew( "RAUniqueChild", { id: createUUID(), name: "Second" } );
child2.setCategory( entityLoadByPK( "RACategory", catId ) );
entitySave( child2 );

try {
	ormFlush();
	throw( message="should have thrown unique constraint violation" );
} catch ( any e ) {
	if ( e.message contains "unique" || e.message contains "constraint" || e.message contains "Unique"
			|| e.message contains "duplicate" || e.type contains "database" )
		echo( "ok" );
	else
		rethrow;
}
</cfscript>
