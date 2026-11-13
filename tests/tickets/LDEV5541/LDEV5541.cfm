<cfscript>
	test = entityNew( "test5541" );
	test.setName( "51-1" );
	test.setId( 1 );
	entitySave( test );
	res = EntityLoadByPk("test5541", 1);
	result = res.getName();
	writeOutput(result);
</cfscript>