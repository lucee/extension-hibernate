<cfscript>
// OOE-15 / LDEV-305: ID property without explicit ormtype + generator="native"
// Should use integer type, not double. "Bad identifier type: double" = bug.

entity = entityNew( "NativeIdEntity" );
entity.setName( "test" );
entitySave( entity );
ormFlush();

if ( entity.getId() <= 0 )
	throw( message="expected auto-generated ID > 0, got #entity.getId()#" );

// Verify round-trip
loaded = entityLoadByPK( "NativeIdEntity", entity.getId() );
if ( loaded.getName() != "test" )
	throw( message="expected name=test, got #loaded.getName()#" );

echo( "ok" );
</cfscript>
