<cfscript>
// entityLoad with unique=true and composite PK filter
entity = entityLoad( "CompositeEntity", { keyPart1: "a", keyPart2: 1 }, true );
if ( isNull( entity ) )
	throw( message="uniqueLoad: entity not found" );
if ( entity.getLabel() != "first" )
	throw( message="uniqueLoad: expected first, got [#entity.getLabel()#]" );
echo( "ok" );
</cfscript>
