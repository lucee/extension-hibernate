<cfscript>
	// LDEV-4339: Verify ORM sessions opened in threads get closed automatically
	stats = ORMGetSessionFactory().getStatistics();
	stats.setStatisticsEnabled( true );
	stats.clear();

	threadNames = [];
	for ( i = 1; i <= 5; i++ ) {
		tName = "ormThread#i#";
		threadNames.append( tName );
		thread name="#tName#" {
			entity = entityNew( "LDEV4339Entity" );
			entity.setId( createUUID() );
			entity.setName( "thread-#thread.name#" );
			entitySave( entity );
			ormFlush();
		}
	}
	thread action="join" name="#arrayToList( threadNames )#";

	// check for thread errors
	for ( tName in threadNames ) {
		if ( structKeyExists( cfthread[ tName ], "error" ) ) {
			throw( message="Thread #tName# failed: #cfthread[ tName ].error.message#",
				detail=cfthread[ tName ].error.stacktrace );
		}
	}

	echo( "#stats.getSessionOpenCount()#:#stats.getSessionCloseCount()#" );
</cfscript>
