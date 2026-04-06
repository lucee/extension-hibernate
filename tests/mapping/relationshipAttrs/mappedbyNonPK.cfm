<cfscript>
// mappedby on many-to-one: FK references a unique non-PK column
lid = createUUID();
lookup = entityNew( "RALookup", { id: lid, code: "US", label: "United States" } );
entitySave( lookup );
ormFlush();

rid = createUUID();
ref = entityNew( "RARefByCode", { id: rid, name: "US Entity", lookup: lookup } );
entitySave( ref );
ormFlush();
ormClearSession();

// verify the FK column holds the code value, not the PK
loaded = entityLoadByPK( "RARefByCode", rid );
if ( !isObject( loaded.getLookup() ) )
	throw( message="lookup should resolve via mappedby=code" );
if ( loaded.getLookup().getCode() != "US" )
	throw( message="expected US, got #loaded.getLookup().getCode()#" );
if ( loaded.getLookup().getLabel() != "United States" )
	throw( message="expected United States, got #loaded.getLookup().getLabel()#" );

echo( "ok" );
</cfscript>
