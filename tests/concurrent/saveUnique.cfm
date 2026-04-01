<cfscript>
// each concurrent request saves its own entity with a unique ID
id = url.entityId;
auto = entityNew( "Auto", { id: id, make: "Make-#id#", model: "Model-#id#" } );
entitySave( auto );
ormFlush();

// verify our entity was saved
result = queryExecute( "SELECT make FROM Auto WHERE id = :id", { id: id } );
if ( result.recordCount != 1 )
	throw( message="concurrent save: expected 1 row for #id#, got #result.recordCount#" );

echo( "ok" );
</cfscript>
