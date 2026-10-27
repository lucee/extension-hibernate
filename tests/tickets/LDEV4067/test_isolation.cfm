<cfscript>
	a = entityNew( "Person4067" );
	a.setId( "iso-a" );
	a.setName( "Alice" );
	b = entityNew( "Person4067" );
	b.setId( "iso-b" );
	b.setName( "Bob" );

	result = {
		newA: a.memento.mappers[ "theName" ](),
		newB: b.memento.mappers[ "theName" ]()
	};

	// mutating one instance's memento must not leak into another instance
	a.memento.marker = true;
	result.markerOnB = structKeyExists( b.memento, "marker" );
	result.mementoShared = a.memento === b.memento;

	entitySave( a );
	entitySave( b );
	ormFlush();
	ormClearSession();

	loadedA = entityLoadByPK( "Person4067", "iso-a" );
	loadedB = entityLoadByPK( "Person4067", "iso-b" );
	result.loadedA = loadedA.memento.mappers[ "theName" ]();
	result.loadedB = loadedB.memento.mappers[ "theName" ]();

	echo( serializeJSON( result ) );
</cfscript>
