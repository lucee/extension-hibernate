<cfscript>
// save new entity with composite PK
entity = entityNew( "CompositeEntity" );
entity.setKeyPart1( "c" );
entity.setKeyPart2( 1 );
entity.setLabel( "new-entry" );
entitySave( entity );
ormFlush();
ormClearSession();

loaded = entityLoad( "CompositeEntity", { keyPart1: "c", keyPart2: 1 }, true );
if ( isNull( loaded ) )
	throw( message="saveNew: entity not found after save" );
if ( loaded.getLabel() != "new-entry" )
	throw( message="saveNew: expected new-entry, got [#loaded.getLabel()#]" );
echo( "ok" );
</cfscript>
