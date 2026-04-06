<cfscript>
// load by composite PK — use entityLoad with struct filter + unique
entity = entityLoad( "CompositeEntity", { keyPart1: "a", keyPart2: 1 }, true );
if ( isNull( entity ) )
	throw( message="loadByPK: entity not found" );
if ( entity.getLabel() != "first" )
	throw( message="loadByPK: expected label first, got [#entity.getLabel()#]" );
echo( "ok" );
</cfscript>
