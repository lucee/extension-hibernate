<cfscript>
	try {
		test = entityNew( "test4150" );
		test.setName( "Steve" );
		test.setAddress( "116 Sunny Ave" );
		test.setId( createUUID() );
		entitySave( test );
		ormFlush();
	
		writeOutput( "success" );
	}
	catch(any e) {
		writeoutput(e.stacktrace);
	}
</cfscript>