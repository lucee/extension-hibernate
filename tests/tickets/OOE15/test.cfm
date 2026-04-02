<cfscript>
// OOE-15 / LDEV-305: ID property without explicit ormtype + generator="native"
// Should use integer type, not double. "Bad identifier type: double" = bug.

// Save a new entity — if the ID mapped as "double", Hibernate throws
// "Bad identifier type: double" during schema generation or flush
entity = entityNew( "NativeIdEntity" );
entity.setName( "test" );
entitySave( entity );
ormFlush();

// Native generator should produce an auto-incremented integer ID
if ( entity.getId() <= 0 )
	throw( message="Expected auto-generated ID > 0, got [#entity.getId()#]" );

// Round-trip: verify the entity persisted and can be loaded by PK
loaded = entityLoadByPK( "NativeIdEntity", entity.getId() );
if ( loaded.getName() != "test" )
	throw( message="Expected name [test], got [#loaded.getName()#]" );

echo( "ok" );
</cfscript>
