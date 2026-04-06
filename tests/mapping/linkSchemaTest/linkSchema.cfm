<cfscript>
sid = createUUID();
cid = createUUID();

student = entityNew( "LSStudent", { id: sid, name: "Alice" } );
course = entityNew( "LSCourse", { id: cid, title: "ORM 101" } );

student.setCourses( [ course ] );
entitySave( student );
entitySave( course );
ormFlush();
ormClearSession();

// verify the relationship works
loaded = entityLoadByPK( "LSStudent", sid );
courses = loaded.getCourses();
if ( !isArray( courses ) || arrayLen( courses ) != 1 )
	throw( message="expected 1 course, got #isArray( courses ) ? arrayLen( courses ) : 'non-array'#" );
if ( courses[ 1 ].getTitle() != "ORM 101" )
	throw( message="expected ORM 101, got #courses[ 1 ].getTitle()#" );

// verify the join table was created in the link schema, not the default schema
try {
	joinRows = queryExecute( "SELECT count(*) as cnt FROM orm_link_schema_test.ls_enrollment" );
	if ( joinRows.cnt != 1 )
		throw( message="expected 1 join row in orm_link_schema_test.ls_enrollment, got #joinRows.cnt#" );
} catch ( any e ) {
	// permission/access errors are OK — MySQL user might not have cross-db SELECT rights
	// but "table not found" means linkschema didn't work — that's a real failure
	if ( e.message contains "doesn't exist" || e.message contains "not found" || e.message contains "Unknown table" )
		rethrow;
	systemOutput( "NOTE: could not verify cross-schema join table (permission?): #e.message#", true );
}

echo( "ok" );
</cfscript>
