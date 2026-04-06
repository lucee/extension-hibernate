<cfscript>
// delete entity with composite PK
entity = entityLoad( "CompositeEntity", { keyPart1: "a", keyPart2: 1 }, true );
if ( isNull( entity ) )
	throw( message="deleteByPK: entity not found before delete" );
entityDelete( entity );
ormFlush();
ormClearSession();

deleted = entityLoad( "CompositeEntity", { keyPart1: "a", keyPart2: 1 }, true );
if ( !isNull( deleted ) )
	throw( message="deleteByPK: entity still exists after delete" );
echo( "ok" );
</cfscript>
