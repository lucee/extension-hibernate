<cfscript>
// Test that ormtype="serializable" correctly stores and retrieves values
// Bug #24: HibernateCaster.toHibernateValue() returns the string "serializable"
// instead of the actual value when type is "serializable"

id = createUUID();
testData = { "foo": "bar", "num": 42 };

sink = entityNew( "KitchenSink", { id: id } );
sink.setBlobData( testData );
entitySave( sink );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "KitchenSink", id );
if ( isNull( loaded ) ) throw( message="entity should be loaded" );

result = loaded.getBlobData();
if ( isNull( result ) ) throw( message="blobData should not be null" );
if ( !isStruct( result ) ) throw( message="blobData should be a struct, got #getMetadata( result ).getName()#" );
if ( result.foo != "bar" ) throw( message="expected foo=bar, got foo=#result.foo#" );
if ( result.num != 42 ) throw( message="expected num=42, got num=#result.num#" );

echo( "ok" );
</cfscript>
